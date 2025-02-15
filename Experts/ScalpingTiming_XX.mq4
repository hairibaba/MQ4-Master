//+------------------------------------------------------------------------------------+
//|   Coder             : hairibaba                                                    |
//|   Coder's Telegram  : @hairibaba (Telegram ID)                                     |
//|   Coder's email     : zulhairibaba@gmail.com                                       |
//|   Coder's mql site  : https://www.mql5.com/en/users/hairi                          |
//|   Coder's location  : Kuala Lumpur, Malaysia (GMT+8)                               |
//|   Release date      : xx-xxx-xxxx                                                  |
//+------------------------------------------------------------------------------------+

#property copyright     "Coded by hairibaba © 2018"
#property link          "https://www.mql5.com/en/users/hairi"
#property version       "1.0"
#property description   "Scalping Timing"
#property strict

#define TIME_ADD_MINUTE    60
#define TIME_ADD_HOUR      3600
#define TIME_ADD_DAY	      86400
#define TIME_ADD_WEEK      604800
#define IDENTIFIER_TRADE   6553656
#define RETRY_DELAY        2000
#define MAXRISK            10
#define MAXSPREAD          30
#define MAX_RETRIES        3

#import "stdlib.ex4"
string ErrorDescription(int error_code);
#import

// --- Standard Global Variable ---------------------------------------------------------
       bool NotiEnable;
     string Acc_Broker,Acc_Currency,Market_Symbol,
            SymbolCurr1,SymbolCurr2,SymbolCurrPrefix,SymbolCurrSuffix,SymbolCurrMid;
       int  Acc_Leverage,Acc_Login,Acc_MarginCall,Acc_StopOut,Acc_Pips,Acc_Slippage,
            Acc_MaxOrder,Acc_MarginLevel,Market_Spread,Market_CalcMode;
     double Acc_Balance,Acc_Equity,Acc_FreeMargin,Acc_Drawdown,Market_ContractSize,
            Market_VolumeLimit,Market_MaxLot,Market_MinLot,Market_LotStep,Market_MarginHedge,
            Market_TickValue,Market_TickSize,Market_StopLevel,Market_FreezeLevel;
     string NewLine = "\n",
            sInput  = "%s";
        
// --- System Global Variable -----------------------------------------------------------        
string      ObjIdentifier  = "EXX_",
            gSignalBuy     = "Signal_Buy",
            gSignalSell    = "Signal_Sell";
int         Magic_BS_1,Magic_BS_2,Magic_BS_3,Magic_BS_4,Magic_BS_5,Magic_BS_6,
            Magic_SS_1,Magic_SS_2,Magic_SS_3,Magic_SS_4,Magic_SS_5,Magic_SS_6,
            Magic_Revenge,
            Magic_BS_1R,Magic_BS_2R,Magic_BS_3R,Magic_BS_4R,Magic_BS_5R,Magic_BS_6R,
            Magic_SS_1R,Magic_SS_2R,Magic_SS_3R,Magic_SS_4R,Magic_SS_5R,Magic_SS_6R;
int         TradeFilter       = 100,
            ReverseType       = 100,
            StopLoss          = 200,
            TakeProfit        = 50,
            PendingDistance   = 50,
            RevTP             = 10;
double      RiskPerTrade      = 0.75,
            RevengeFactor     = 3.5;

// --- EA Operation Start ---------------------------------------------------------------
int OnInit(){
   if(!InitFailed()) return INIT_FAILED;
   ulong  ul=0, ul_res=0;
   ul = GetMicrosecondCount();
   // Account Inilization Start
   AccountParameter_Symbol();
   AccountParameter_Fixed();
   // Assigning Magic Number
   MagicNum(IDENTIFIER_TRADE,
            Magic_BS_1,Magic_BS_2,Magic_BS_3,Magic_BS_4,Magic_BS_5,Magic_BS_6,
            Magic_SS_1,Magic_SS_2,Magic_SS_3,Magic_SS_4,Magic_SS_5,Magic_SS_6,
            Magic_Revenge,
            Magic_BS_1R,Magic_BS_2R,Magic_BS_3R,Magic_BS_4R,Magic_BS_5R,Magic_BS_6R,
            Magic_SS_1R,Magic_SS_2R,Magic_SS_3R,Magic_SS_4R,Magic_SS_5R,Magic_SS_6R
            );
   ChartSetting();
   if(SymShort(3,4,5)=="JPY") {
      StopLoss = 320;
      RevTP    = 15;
      PendingDistance = 100;
   }
   ul_res = GetMicrosecondCount()-ul;
   string ms = DoubleToString((ul_res/1000.0),2);
   if(!IsTesting()) PrintFormat("Initilized in %s ms.",ms);
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){
   ObjectDeleteAll(ObjIdentifier); //--- Delete All Drawings
   Print(getUninitReasonText(reason));
}

void OnTick(){
   AllowTrading();
   ChartHistory();
   AccountParameter_Var();
   
   double UseLot = LotManagement(RiskPerTrade,StopLoss);
   SystemRevengeOrder(UseLot);
   
   // To Manage order
   if(!NoOrder()) OrderManagement();
   TradeFilter = StochFilter();
   
   // Global Signal
   int SetupBuyTime  = GetSignalTime(gSignalBuy);
   int SetupSellTime = GetSignalTime(gSignalSell);
   
   // Trade order operation
   if(SetupBuyTime>0) {
      int MASetup = MAFilter(SetupBuyTime);
      if(MASetup==OP_SELL) {
         if(BetweenTimeRange(SetupBuyTime,30)) TradeSwitch(OP_SELL,TradeFilter,Magic_BS_1,UseLot,Market_Symbol+"-BMA_BS_S1");
         else if(BetweenTimeRange(SetupBuyTime,50)) {
            if(ReverseOrder(Magic_BS_1,22,ReverseType) && CountPosition(Magic_BS_2)==0) OpenSell(Magic_BS_2,UseLot,Market_Symbol+"-BMA_BS_B1");
            else TradeSwitch(OP_SELL,TradeFilter,Magic_BS_2,UseLot,Market_Symbol+"-BMA_BS_S2");
         }
         else if(BetweenTimeRange(SetupBuyTime+1,0)) {
            if(ReverseOrder(Magic_BS_2,12,ReverseType) && CountPosition(Magic_BS_3)==0) OpenOrder(ReverseType,Magic_BS_3,UseLot,Market_Symbol+"-BMA_BS_B1");
            else TradeSwitch(OP_BUY,TradeFilter,Magic_BS_3,UseLot,Market_Symbol+"-BMA_BS_B1");
         }
      }
      else if(MASetup==OP_BUY) {
         if(BetweenTimeRange(SetupBuyTime,30)) TradeSwitch(OP_BUY,TradeFilter,Magic_BS_4,UseLot,Market_Symbol+"-AMA_BS_B1");
         else if(BetweenTimeRange(SetupBuyTime,50)) {
            if(ReverseOrder(Magic_BS_4,22,ReverseType) && CountPosition(Magic_BS_5)==0) OpenBuy(Magic_BS_5,UseLot,Market_Symbol+"-AMA_BS_S1");
            else TradeSwitch(OP_SELL,TradeFilter,Magic_BS_5,UseLot,Market_Symbol+"-AMA_BS_S1");
         }
         else if(BetweenTimeRange(SetupBuyTime+1,40)) {
            if(ReverseOrder(Magic_BS_5,70,ReverseType) && CountPosition(Magic_BS_6)==0) OpenOrder(ReverseType,Magic_BS_6,UseLot,Market_Symbol+"-AMA_BS_B2");
            else {
               int checkloc = RangePeriod(50);
               if(checkloc==OP_BUY) TradeSwitch(OP_BUY,TradeFilter,Magic_BS_6,UseLot,Market_Symbol+"-AMA_BS_B2");
               else if(checkloc==OP_SELL) TradeSwitch(OP_SELL,TradeFilter,Magic_BS_6,UseLot,Market_Symbol+"-AMA_BS_B2_Rev");
            }
         }
      }
   }
   if(SetupSellTime>0) { 
      int MASetup = MAFilter(SetupSellTime);
      if(MASetup==OP_SELL) {
         if(BetweenTimeRange(SetupSellTime,30)) TradeSwitch(OP_SELL,TradeFilter,Magic_SS_1,UseLot,Market_Symbol+"-BMA_SS_S1");
         else if(BetweenTimeRange(SetupSellTime,50)) {
            if(ReverseOrder(Magic_SS_1,22,ReverseType) && CountPosition(Magic_SS_2)==0) OpenSell(Magic_SS_2,UseLot,Market_Symbol+"-BMA_SS_B1");
            else TradeSwitch(OP_BUY,TradeFilter,Magic_SS_2,UseLot,Market_Symbol+"-BMA_SS_B1");
         }
         else if(BetweenTimeRange(SetupSellTime+1,40)) {
            if(ReverseOrder(Magic_SS_2,70,ReverseType) && CountPosition(Magic_SS_3)==0) OpenOrder(ReverseType,Magic_SS_3,UseLot,Market_Symbol+"-BMA_SS_S2");
            else {
               int checkloc = RangePeriod(50);
               if(checkloc==OP_SELL) TradeSwitch(OP_SELL,TradeFilter,Magic_SS_3,UseLot,Market_Symbol+"-BMA_SS_S2");
               else if(checkloc==OP_BUY) TradeSwitch(OP_BUY,TradeFilter,Magic_SS_3,UseLot,Market_Symbol+"-BMA_SS_S2_Rev");
            }
         }
      }
      else if(MASetup==OP_BUY) {
         if(BetweenTimeRange(SetupSellTime,30)) TradeSwitch(OP_BUY,TradeFilter,Magic_SS_4,UseLot,Market_Symbol+"-AMA_BS_B1");
         else if(BetweenTimeRange(SetupSellTime,50)) {
            if(ReverseOrder(Magic_SS_4,22,ReverseType) && CountPosition(Magic_SS_5)==0) OpenBuy(Magic_SS_5,UseLot,Market_Symbol+"-AMA_BS_B2");
            else TradeSwitch(OP_BUY,TradeFilter,Magic_SS_5,UseLot,Market_Symbol+"-AMA_BS_B2");
         }
         else if(BetweenTimeRange(SetupSellTime+1,0)) {
            if(ReverseOrder(Magic_SS_5,22,ReverseType) && CountPosition(Magic_SS_6)==0) OpenOrder(ReverseType,Magic_SS_6,UseLot,Market_Symbol+"-AMA_BS_S1");
            else TradeSwitch(OP_SELL,TradeFilter,Magic_SS_6,UseLot,Market_Symbol+"-AMA_BS_S1");
         }
      }
   }

   Comment(
   "\n\n Scalping Precision Entry",
   "\n\n Scalping Lot : ",StringLot(UseLot),
   "\n\n------------------------------------",
   "\n\n Setup Buy at : ",SetupBuyTime," hour",
   "\n\n Setup Sell at : ",SetupSellTime," hour"
   );
   
   DrawVSignal();
}

void RevengeOrder(int magic, double lot) {
   int historyType = 100;
   if(OrderProperty_JustClose(magic) && OrderProperty_OrderHistoryPL_Scalping(magic,2,historyType)<0) {
      double revengeLot = NormLot(lot*RevengeFactor);
      if(CountPosition(Magic_Revenge)==0 && historyType!=100) OpenOrder(historyType,Magic_Revenge,revengeLot,Market_Symbol+"_RRR");
   }
}

void SystemRevengeOrder(double lot) {
   RevengeOrder(Magic_BS_1,lot);
   RevengeOrder(Magic_BS_2,lot);
   RevengeOrder(Magic_BS_3,lot);
   RevengeOrder(Magic_BS_4,lot);
   RevengeOrder(Magic_BS_5,lot);
   RevengeOrder(Magic_BS_6,lot);
   RevengeOrder(Magic_SS_1,lot);
   RevengeOrder(Magic_SS_2,lot);
   RevengeOrder(Magic_SS_3,lot);
   RevengeOrder(Magic_SS_4,lot);
   RevengeOrder(Magic_SS_5,lot);
   RevengeOrder(Magic_SS_6,lot);
}

void TradeSwitch(int trade, int filter, int magic, double lot, string comment) {
   if(trade==OP_SELL) {
      if(filter==OP_SELL) OpenSell(magic,lot,comment);
      else OpenSellLimit(magic,lot,comment);
   }
   else if(trade==OP_BUY) {
      if(filter==OP_BUY) OpenBuy(magic,lot,comment);
      else OpenBuyLimit(magic,lot,comment);
   }
}

void CloseTradeBuyTimer(int magic, int minuteLimit) {
   if(CountPosition(magic)>0) {
      datetime OT = OrderProperty_OrderOpenTime(magic);
      if(TimeCurrent()>=OT+minuteLimit*TIME_ADD_MINUTE) ProtectingTargetScalp(magic);
   }
}

bool NoOrder() {
   bool x = false;
   bool bs = false;
   bool ss = false;
   bool rr = false;
   if(CountPosition(Magic_BS_1)==0 && CountPosition(Magic_BS_2)==0 && CountPosition(Magic_BS_3)==0 && CountPosition(Magic_BS_4)==0 && CountPosition(Magic_BS_5)==0 && CountPosition(Magic_BS_6)==0) bs = true;
   if(CountPosition(Magic_SS_1)==0 && CountPosition(Magic_SS_2)==0 && CountPosition(Magic_SS_3)==0 && CountPosition(Magic_SS_4)==0 && CountPosition(Magic_SS_5)==0 && CountPosition(Magic_SS_6)==0) ss = true;
   if(CountPosition(Magic_Revenge)==0) rr = true;
   if(bs && ss && rr) x = true;
   return x;
}

void OrderManagement() {
   CloseTradeBuyTimer(Magic_BS_1,30);
   CloseTradeBuyTimer(Magic_BS_2,10);
   CloseTradeBuyTimer(Magic_BS_3,40);
   CloseTradeBuyTimer(Magic_SS_2,50);
   CloseTradeBuyTimer(Magic_SS_3,11);
   CloseTradeBuyTimer(Magic_SS_4,30);
   CloseTradeBuyTimer(Magic_SS_5,10);
   CloseTradeBuyTimer(Magic_SS_6,40);
   CloseTradeBuyTimer(Magic_BS_5,50);
   CloseTradeBuyTimer(Magic_BS_6,11);
   
   HiddenSLTP(Magic_BS_1,StopLoss,TakeProfit-15);
   HiddenSLTP(Magic_BS_2,StopLoss,TakeProfit);
   HiddenSL(Magic_BS_3,StopLoss);
   HiddenSLTP(Magic_SS_1,StopLoss,TakeProfit);
   HiddenSL(Magic_SS_2,StopLoss);
   HiddenSL(Magic_SS_3,StopLoss);
   
   HiddenSLTP(Magic_BS_4,StopLoss,TakeProfit);
   HiddenSL(Magic_BS_5,StopLoss);
   HiddenSL(Magic_BS_6,StopLoss);
   HiddenSLTP(Magic_SS_4,StopLoss,TakeProfit-15);
   HiddenSLTP(Magic_SS_5,StopLoss,TakeProfit);
   HiddenSL(Magic_SS_6,StopLoss);
   
   ProtectSwingScalp(Magic_BS_3);
   ProtectSwingScalp(Magic_BS_2);
   ProtectSwingScalp(Magic_SS_3);
   ProtectSwingScalp(Magic_BS_5);
   ProtectSwingScalp(Magic_BS_6);
   ProtectSwingScalp(Magic_SS_6);
   
   // Revenge Trade
   HiddenSLTP(Magic_Revenge,StopLoss,TakeProfit+RevTP);
}

void ProtectSwingScalp(int magic) {
   BreakEven(magic,75);
   if(HiddenTP_Trail(magic,190)) ProtectingTargetScalp(magic);
}

int MAFilter(int hour) {
   int x = 100;
   int shift = iBarShift(_Symbol,PERIOD_M15,HourMin(hour),true);
   if(shift>0) {
      double ma = iMA(_Symbol,PERIOD_M15,100,0,MODE_EMA,PRICE_CLOSE,shift);
      double close = iClose(_Symbol,PERIOD_M15,shift);
      
      if(close<ma) x = OP_SELL;
      else if(close>ma) x = OP_BUY;      
   }
   return x;
}

// --- Utilities Code -------------------------------------------------------------------

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

double ask(string pSymbol=NULL){
   if(pSymbol==NULL) pSymbol=_Symbol;
   return(SymbolInfoDouble(pSymbol,SYMBOL_ASK));
}

void AccountParameter_Var() {
   // Account Info
   Acc_Balance       = AccountInfoDouble(ACCOUNT_BALANCE);
   Acc_Equity        = AccountInfoDouble(ACCOUNT_EQUITY);
   Acc_FreeMargin    = AccountInfoDouble(ACCOUNT_FREEMARGIN);
   Acc_MarginLevel   = int(AccountInfoDouble(ACCOUNT_MARGIN_LEVEL));
   Market_TickValue  = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   Market_Spread     = int(MarketInfo(_Symbol,MODE_SPREAD));
   Acc_Drawdown      = 0;
   NotiEnable        = TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED);
   if(Acc_Balance>Acc_Equity && Acc_Balance>0) {
      Acc_Drawdown = StringToDouble(DoubleToString((1-(Acc_Equity/Acc_Balance))*100,1));
   }
}

void AccountParameter_Symbol() {   
   Market_CalcMode   = int(MarketInfo(Symbol(),MODE_PROFITCALCMODE));
   Market_Symbol     = _Symbol;
   SymbolCurr1       = StringSubstr(_Symbol,0,3);
   SymbolCurr2       = StringSubstr(_Symbol,3,3);
   SymbolCurrPrefix  = "";
   SymbolCurrSuffix  = "";
   SymbolCurrMid     = "";
   
   if(Market_CalcMode==0 && StringLen(_Symbol)>6) {
      string symbolTest = "EURUSD";
      getPrefixSuffix(SymbolCurrPrefix,SymbolCurrSuffix,symbolTest);
      int len = StringLen(symbolTest);
      
      if(len==6) {
         if(SymbolCurrPrefix=="") {
            Market_Symbol   = StringSubstr(_Symbol,0,6);
            SymbolCurr1     = StringSubstr(_Symbol,0,3);
            SymbolCurr2     = StringSubstr(_Symbol,3,3);
         }
         else {
            int x    = StringLen(SymbolCurrPrefix);
            Market_Symbol   = StringSubstr(_Symbol,x,6);
            SymbolCurr1     = StringSubstr(_Symbol,x,3);
            SymbolCurr2     = StringSubstr(_Symbol,x+3,3);
         }
      }
      else if(len==7) {
         if(SymbolCurrPrefix=="") {
            SymbolCurr1     = StringSubstr(_Symbol,0,3);
            SymbolCurr2     = StringSubstr(_Symbol,4,3);
            SymbolCurrMid      = StringSubstr(_Symbol,3,1);
            Market_Symbol   = SymbolCurr1+SymbolCurr2;
         }
         else {
            int x    = StringLen(SymbolCurrPrefix);
            SymbolCurr1     = StringSubstr(_Symbol,x,3);
            SymbolCurr2     = StringSubstr(_Symbol,x+4,3);
            SymbolCurrMid      = StringSubstr(_Symbol,x+3,1);
            Market_Symbol   = SymbolCurr1+SymbolCurr2;
         }
      }
   }
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
   Acc_MarginCall       = int(AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL));
   Acc_StopOut          = int(AccountInfoDouble(ACCOUNT_MARGIN_SO_SO));
   Acc_Pips             = 1;

   if(_Digits == 3 || _Digits == 5) {
      Acc_Slippage    = 15;
      Acc_Pips = 10;
   }
}

void getPrefixSuffix(string& prefix, string& suffix, string& accSymbol){ 
   int SectorSize = 1936;
   prefix=""; suffix="";

   int retry = 0;
   int fileHandle = -1;
   while(retry <= MAX_RETRIES) {   
      fileHandle = FileOpenHistory("symbols.raw",FILE_BIN|FILE_READ);
      if (fileHandle != -1) break;
      else {
         retry++;
         Sleep(1000);
      }
   }
   if (fileHandle == -1) {
      Alert("File opening error: ",ErrorDescription(GetLastError()));
      ResetLastError();
      return; //HFILE Error
   }
   else {
      for(int i=0;; i++){
         int pos;
         FileSeek(fileHandle, SectorSize*i, SEEK_SET); 
         if (FileIsEnding(fileHandle)) { prefix="err"; break; }
         string symbolName = FileReadString(fileHandle,12);
         
         symbolName = StringSubstr(symbolName,0);
         pos = StringFind(symbolName,"EURUSD",0);
         if (pos > -1){
            if (pos>0) prefix = StringSubstr(symbolName,0,pos);
            if ((pos+6)<StringLen(symbolName)) suffix = StringSubstr(symbolName,(pos+6),0);
            accSymbol = "EURUSD";
            break;
         }
         else {
            pos = StringFind(symbolName,"EUR/USD",0);
            if (pos > -1){
               if (pos>0) prefix = StringSubstr(symbolName,0,pos);
               if ((pos+7)<StringLen(symbolName)) suffix = StringSubstr(symbolName,(pos+7),0);
               accSymbol = "EUR/USD";
               break;
            }
            else {
               pos = StringFind(symbolName,"EUR.USD",0);
               if (pos > -1){
                  if (pos>0) prefix = StringSubstr(symbolName,0,pos);
                  if ((pos+7)<StringLen(symbolName)) suffix = StringSubstr(symbolName,(pos+7),0);
                  accSymbol = "EUR.USD";
                  break;
               }
            }
         } 
      } 
      FileClose(fileHandle);
   }
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
         refSym=="BTCUSD" || refSym=="ETHUSD" || refSym=="XRPUSD") RefPrice = ask(ThisSym1);
         else RefPrice = 1/(ask(ThisSym2));
      }
      //else RefPrice = 1; // need to refine this code for deposit currency other than USD
   }
   
   return RefPrice+buffer;
}

double LotManagement(double risk, int stop = 150, double CommPerStdLot = 0) {
   double RefPrice               = LotReferencePrice(),
          LotSize                = Market_MinLot,
          CommissionCost         = 0,
          CommPerStdLotRoundTurn = fmax(CommPerStdLot,OrderCommissionChk());
   
   if(risk>0 && stop>0) {
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
   }
   return LotSize;
}

double VerifyLotMinMax(double lot) {
   double uselot = lot;
   if(uselot>Market_MaxLot) uselot = Market_MaxLot;
   else if(uselot<Market_MinLot) uselot = Market_MinLot;
   return uselot;
}

double TotalMarginRequired(int leverage, int spread, double lotsize, int CommPerStdLotRoundTurn=0) {
   int margin              = spread*2;
   double marginRequired   = 0, CommissionCost = 0;
   double referencePrice   = LotReferencePrice();
   string sym1             = SymShort(0,1,2);
   
   // Account Multiplier
   double multiplier = (Market_ContractSize/leverage)*lotsize;
   // Margin Required
   if(sym1==Acc_Currency) marginRequired = multiplier;
   else marginRequired = multiplier*referencePrice;
   // Commission Cost
   if(CommPerStdLotRoundTurn>0) CommissionCost = referencePrice*lotsize*CommPerStdLotRoundTurn;
   // Spread Cost
   if(Market_Spread<=15) margin = 15;
   else if(Market_Spread<=20) margin = 20;
   else if(Market_Spread<=25) margin = 25;
   else if(Market_Spread<=30) margin = 30;
   double SpreadCost = margin*lotsize*Market_TickValue;
   double raw = marginRequired+CommissionCost+SpreadCost;
   return ceil(raw/0.01)*0.01;
}

string getletter(int pos) {
   string x = "";
   ushort loc = StringGetCharacter(Market_Symbol,pos);
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

bool InitFailed() {
   string login = IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN));
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
      Alert("Automated trading is forbidden for the account ",login," at the trade server side");
      x = false;
   }
   else if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED)) {
      Alert("Trading is forbidden for the account ",login,
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

void ObjectDrawDelete(string objIdentifier, string name) {
   ObjectDelete(0,objIdentifier+name);
}

bool SpreadFilterPair() {
   return Market_Spread<=MAXSPREAD;
}

bool VariableSpreadFilter(){
   bool allow = true;
   int MaxSpread = MAXSPREAD;
   string sym = Market_Symbol;
   if(sym=="EURUSD" || sym=="USDJPY" || sym=="GBPUSD") MaxSpread = 20;
   else if(sym=="AUDUSD" || sym=="NZDUSD" || sym=="EURJPY") MaxSpread = 24;
   else if(sym=="USDCAD" || sym=="USDCHF") MaxSpread = 26;
   if(Market_Spread>MaxSpread) allow=false;
   return allow;
}

bool StopLevel(double pPrice) {
   bool x = true;
   double res = fmax(Market_StopLevel,Market_FreezeLevel);
   RefreshRates();
   double uppermargin = Ask + res;
   double lowermargin = Bid - res;
   if(pPrice<=uppermargin && pPrice>=lowermargin) x = false;
   return x;
}

double NormPrice(double price) {
   double ticksize = Market_TickSize*_Point;
   return round(price/ticksize)*ticksize;
}

string StringPrice(double price) {
   return DoubleToString(NormPrice(price),_Digits);
}

double NormDollar(double dollarValue) {
   return round(dollarValue/0.01)*0.01;
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

double NormLot(double lot) {
   double useLot  = Market_MinLot;
   if(lot>Market_MaxLot) useLot = Market_MaxLot;
   else if(lot>Market_MinLot) useLot = floor(lot/Market_LotStep)*Market_LotStep;
   return useLot;
}

string StringLot(double lot) {
   double step = Market_LotStep;
   int x = 0;
   if(step==0.01) x = 2;
   else if(step==0.1) x = 1;
   
   return DoubleToString(lot,x);
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

int CountPosition(int Magic){
   int count = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);
      if(select && OrderMagicNumber() == Magic && OrderSymbol()==_Symbol && OrderType()<2) count++;
   }
   return count;
}

int CountPending(int Magic){
   int count = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--) {
      bool select = OrderSelect(order,SELECT_BY_POS);
      if(select && OrderMagicNumber() == Magic && OrderSymbol()==_Symbol && OrderType()>=2 && OrderType()<=5) count++;
   }
   return count;
}

int CountPositionAndPending(int magic){
   int x = CountPosition(magic)+ CountPending(magic);
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

bool EnoughFund(double lot, int commission = 4) {
   return Acc_FreeMargin >= TotalMarginRequired(Acc_Leverage,Market_Spread+50,lot,commission);
}

void OpenOrder(int type, int magic, double lot, string comment){
   string msg;
   if(type==OP_BUYLIMIT || type==OP_BUYSTOP || type==OP_SELLLIMIT || type==OP_SELLSTOP) {
      msg = _Symbol+" Market Order: Invalid order type!";
      NotifySetting(msg);
      return;
   }
   else if(Acc_MaxOrder>0 && Acc_MaxOrder==OrdersTotal()) {
      msg = _Symbol+" Market Order: Reaching Maximum order!";
      NotifySetting(msg);
      return;
   }
   else if(lot<Market_MinLot || lot>Market_MaxLot) {
      msg = _Symbol+" Market Order: Invalid lot!";
      NotifySetting(msg);
      return;
   }
   else if(!EnoughFund(lot) || !MarginLevelProcced(105)) {
      msg = StringConcatenate(_Symbol+" Market Order: Not enough funds to open order with  ",lot," lot!");
      NotifySetting(msg);
      Sleep(5000);
      return;
   }
   else if(type==OP_BUY || type==OP_SELL){
      ulong  ul=0, ul_res=0;
      ul = GetMicrosecondCount();
      TickData(); // Updating Latest Tick Data
      double price = Bid;
      color arrow  = clrRed;
      if(type==OP_BUY) {price = Ask;arrow = clrGreen;}
      int ticket = OrderSend(_Symbol,type,lot,price,Acc_Slippage,0,0,comment,magic,0,arrow);
      if(ticket == -1) OrderSendError("Market");
      else {
         ul_res = GetMicrosecondCount()-ul;
         string ms = DoubleToString((ul_res/1000.0),2);
         if(!IsTesting()) PrintFormat("Market order execute in %s ms.",ms);
      }
   }
}

void OpenPendingOrder(int type, int magic, double lot, double pPricePending, string comment, int expiredMinutes){
   bool     proceed  = false;
   color    arrow    = clrGreen;
   datetime Expired  = 0;
   string   msg;
   if(expiredMinutes>0) {
      if(expiredMinutes<12) {
         msg = _Symbol+" Pending Order: Minimum expired is 12 minutes. Re-adjust expiry to 12 minutes!";
         NotifySetting(msg);
         Expired = TimeCurrent()+12*TIME_ADD_MINUTE;
      }
      else Expired = TimeCurrent()+expiredMinutes*TIME_ADD_MINUTE;
      if(Expired>HourMin(23,54) && TimeCurrent()<HourMin(23,40)) Expired = HourMin(23,54);   // expired end of the day
   }
   
   RefreshRates();
   if(type==OP_BUY || type==OP_SELL) {
      msg = _Symbol+" Pending Order: Invalid order type!";
      NotifySetting(msg);
      return;
   }
   else if((type==OP_BUYLIMIT || type==OP_SELLSTOP) && Bid>pPricePending+Market_StopLevel) proceed = true;
   else if((type==OP_SELLLIMIT || type==OP_BUYSTOP)) {
      arrow = clrRed;
      if(Ask<pPricePending-Market_StopLevel) proceed = true;
   }
   
   else if(Acc_MaxOrder>0 && Acc_MaxOrder==OrdersTotal()) {
      msg = _Symbol+" Pending Order: Reaching Maximum order!";
      NotifySetting(msg);
      return;
   }
   else if(!proceed || pPricePending<=0 || !StopLevel(pPricePending)) {
      msg = _Symbol+" Pending Order: Invalid pending price placement!";
      NotifySetting(msg);
      return;
   }
   else if(lot<Market_MinLot || lot>Market_MaxLot) {
      msg = _Symbol+" Pending Order: Invalid lot!";
      NotifySetting(msg);
      return;
   }
   else if(!EnoughFund(lot) || !MarginLevelProcced(102)) {
      msg = StringConcatenate(_Symbol," Pending Order: Not enough funds to open order with  ",lot," lot!");
      NotifySetting(msg);
      Sleep(5000);
      return;
   }
   else if(proceed){
      int retry = 0;
      int ticket = -1;
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

void OpenBuy(int magic, double lot, string comment){
   if(CountPositionAndPending(magic)==0 && SpreadFilterPair() && !OrderProperty_JustClose(magic)) OpenOrder(OP_BUY,magic,lot,comment);
}

void OpenSell(int magic, double lot, string comment){
   if(CountPositionAndPending(magic)==0 && SpreadFilterPair() && !OrderProperty_JustClose(magic)) OpenOrder(OP_SELL,magic,lot,comment);
}

void OpenBuyLimit(int magic, double lot, string comment){
   RefreshRates();
   if(CountPositionAndPending(magic)==0) OpenPendingOrder(OP_BUYLIMIT,magic,lot,Bid-NumToPoint(PendingDistance),comment,12);
}

void OpenSellLimit(int magic, double lot, string comment){
   RefreshRates();
   if(CountPositionAndPending(magic)==0) OpenPendingOrder(OP_SELLLIMIT,magic,lot,Ask+NumToPoint(PendingDistance),comment,12);
}

void CloseOrder(int magic){
   if(CountPosition(magic)>0) {
      for(int order = OrdersTotal()-1; order >= 0; order--){
         bool select = OrderSelect(order,SELECT_BY_POS);
         if(select && OrderMagicNumber()==magic && OrderSymbol()==_Symbol && OrderType()<2){
            bool proceed = true;     
            if(OrderTakeProfit()>0 && !StopLevel(OrderTakeProfit())) proceed = false;
            else if(OrderStopLoss()>0 && !StopLevel(OrderStopLoss())) proceed = false;
            if(proceed) {
               ulong  ul=0, ul_res=0;
               ul = GetMicrosecondCount();
               int retry = 0;
               bool closeorder = false;
               while(retry <= MAX_RETRIES) {
                  TickData(); // Updating Latest Tick Data
                  double ClosePrice = Bid;
                  if(OrderType()==OP_SELL) ClosePrice = Ask;
                  closeorder = OrderClose(OrderTicket(),OrderLots(),ClosePrice,Acc_Slippage,clrRed);
                  if(closeorder) {
                     ul_res = GetMicrosecondCount()-ul;
                     string ms = DoubleToString((ul_res/1000.0),2);
                     if(IsTesting()) Print("Order #",OrderTicket()," closed.");
                     else PrintFormat("Order ticket %d closed in %s ms.",OrderTicket(),ms);
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

void HiddenSL(int magic, int SLPoint){
   bool     ChkCondition   = false;
   double   bufferSL       = NumToPoint(SLPoint);
   double   stopLoss;

   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);
      if(select && OrderMagicNumber()==magic && OrderSymbol()==_Symbol && OrderType()<2 && SLPoint!=0){
         RefreshRates();
         double ClosingBuy = Bid;
         double ClosingSell = Ask;
         if(!VariableSpreadFilter()){
            ClosingBuy = Ask;
            ClosingSell = Bid;
         }
         
         if(OrderType()==OP_BUY) {
            stopLoss    = OrderOpenPrice() - bufferSL;
            if(ClosingBuy<=stopLoss) ChkCondition = true;
         }
         else if(OrderType()==OP_SELL){
            stopLoss    = OrderOpenPrice() + bufferSL;
            if(ClosingSell>=stopLoss) ChkCondition = true;
         }
         
         if(ChkCondition) CloseOrder(magic);
      }
   }
}

void HiddenTP(int magic, int TPPoint){
   bool     ChkCondition   = false;
   double   bufferTP       = NumToPoint(TPPoint);
   double   takeProfit;

   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);
      if(select && OrderMagicNumber()==magic && OrderSymbol()==_Symbol && OrderType()<2 && TPPoint!=0){
         RefreshRates();
         double ClosingBuy = Bid;
         double ClosingSell = Ask;         
         if(OrderType()==OP_BUY) {
            takeProfit    = OrderOpenPrice() + bufferTP;
            if(ClosingBuy>=takeProfit) ChkCondition = true;
         }
         else if(OrderType()==OP_SELL){
            takeProfit    = OrderOpenPrice() - bufferTP;
            if(ClosingSell<=takeProfit) ChkCondition = true;
         }
         
         if(ChkCondition) CloseOrder(magic);
      }
   }
}

bool HiddenTP_Trail(int magic, int TPPoint){
   bool     ChkCondition   = false;
   double   bufferTP       = NumToPoint(TPPoint);
   double   takeProfit;

   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);
      if(select && OrderMagicNumber()==magic && OrderSymbol()==_Symbol && OrderType()<2 && TPPoint!=0){
         RefreshRates();
         double ClosingBuy = Bid;
         double ClosingSell = Ask;         
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
   
   return ChkCondition;
}

void HiddenSLTP(int magic, int SLPoint, int TPPoint, bool trail = false){
   HiddenSL(magic,SLPoint);
   if(TPPoint>0) {
      if(!trail) HiddenTP(magic,TPPoint);
      else if(HiddenTP_Trail(magic,TPPoint)) ProtectingTargetScalp(magic);
   }
}

void ModifyStopLoss(int magic, double pPriceSL) { 
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);
      if(select && OrderMagicNumber()==magic && OrderSymbol()==_Symbol && pPriceSL>=0){
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
            }
            if(!modify) ModifyError(OrderTicket());
         }
      }
   }
}

bool AcceptableDifference(double price, double pricecompare) {
   bool x = true;
   double buffer = NumToPoint(2);
   double range_u = pricecompare+buffer,
          range_b = pricecompare-buffer;
   if(price==pricecompare || (price<range_u && price>range_b)) x = false;
   return x;
}

void BreakEven(int magic, int distance = 100, int lock = 10){
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);
      if(select && OrderMagicNumber()==magic && OrderSymbol()==_Symbol && OrderType()<2 && distance>0 && lock>=0){         
         double TrailingLevel,LockBE;
         double buffer_distance = NumToPoint(distance);
         double buffer_lock = NumToPoint(lock);
         RefreshRates();
         if(OrderType() == OP_SELL){
            TrailingLevel = OrderOpenPrice() - buffer_distance;
            LockBE = OrderOpenPrice() - buffer_lock;
            if(Ask<TrailingLevel && (OrderStopLoss()==0 || OrderStopLoss()>OrderOpenPrice())) ModifyStopLoss(magic,LockBE);
         }
         else if(OrderType() == OP_BUY){
            TrailingLevel = OrderOpenPrice() + buffer_distance;
            LockBE = OrderOpenPrice() + buffer_lock;
            if(Bid>TrailingLevel && (OrderStopLoss()==0 || OrderStopLoss()<OrderOpenPrice())) ModifyStopLoss(magic,LockBE);
         }
      } 
   } 
}

void TrailingStop(int magic, int distance, int step = 10){
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);  
      if(select && OrderMagicNumber()==magic && OrderSymbol()==_Symbol && OrderType()<2 && OrderStopLoss()>0 && distance>0 && step>0){
         double TrailingLevel,StepLevel;
         double buffer_distance = NumToPoint(distance);
         double buffer_step = NumToPoint(step);
         RefreshRates();
         if(OrderType() == OP_SELL && OrderStopLoss()<=OrderOpenPrice()){
            TrailingLevel = OrderStopLoss() - buffer_distance;
            StepLevel     = OrderStopLoss() - buffer_step;
            if(Ask<TrailingLevel) ModifyStopLoss(magic,StepLevel);
         }
         else if(OrderType() == OP_BUY && OrderStopLoss()>=OrderOpenPrice()){
            TrailingLevel = OrderStopLoss() + buffer_distance;
            StepLevel     = OrderStopLoss() + buffer_step;
            if(Bid>TrailingLevel) ModifyStopLoss(magic,StepLevel);
         }
      } 
   } 
}

void SystemTrailing(int magic, int distance = 100, int step = 10){
   if(CountPosition(magic)>0){
      BreakEven(magic,distance,step-5);
      TrailingStop(magic,distance+50,step);
   }
}

bool BetweenPriceRange(double above, double below) {
   bool x = false;
   RefreshRates();
   if(Bid<=above && Bid>=below) x = true;   
   return x;
}

bool BetweenTimeRange(int hour, int minutes) {
   bool x = false;
   if(TimeCurrent()>=HourMin(hour,minutes) && TimeCurrent()<=HourMin(hour,minutes+1)) x = true;
   return x;
}

bool BetweenTimeRangeSec(int hour, int minutes) {
   bool x = false;
   if(TimeCurrent()>=HourMinSec(hour,minutes,0) && TimeCurrent()<=HourMinSec(hour,minutes,10)) x = true;
   return x;
}

void ProtectingTargetScalp(int magic, int lock = 10) {
   if(CountPosition(magic)>0) {
      int type = OrderProperty_OrderType(magic);
      double SL = OrderProperty_OrderStopLoss(magic);
      double TriggerSL;
      double dis_lock = NumToPoint(lock)+Market_StopLevel;

      RefreshRates();
      if(type==OP_BUY) {
         TriggerSL = Bid-dis_lock;
         if(SL<TriggerSL||SL==0) ModifyStopLoss(magic,TriggerSL);
      }
      else if(type==OP_SELL) {
         TriggerSL = Ask+dis_lock;
         if(SL>TriggerSL||SL==0) ModifyStopLoss(magic,TriggerSL);
      }
   }
}

void OrderSendError(string ordertype){
   string output_string = StringConcatenate("Symbol : ",sInput,
                                             NewLine,sInput," order failed!",
                                             NewLine,"Reason : ",sInput
                                           );
                                           
   string msg = StringFormat( output_string,_Symbol,ordertype,ErrorDescription(GetLastError()));
   NotifySetting(msg);
}

void ModifyError(int ticket){
   string output_string = StringConcatenate("Acc #",sInput," - Symbol : ",sInput,
                                             NewLine,"Order ticket #",sInput," modify failed!",
                                             NewLine,"Reason : ",sInput
                                           );
      
   string msg = StringFormat(output_string,IntegerToString(Acc_Login),_Symbol,IntegerToString(ticket),ErrorDescription(GetLastError()));
   NotifySetting(msg);
}

void OrderCloseError(int ticket, string action){
   string output_string = StringConcatenate("Symbol : ",sInput,
                                             NewLine,"Order ticket #",sInput," failed to ",sInput,
                                             NewLine,"Reason : ",sInput
                                           );
                               
   string msg = StringFormat(output_string,_Symbol,IntegerToString(ticket),action,ErrorDescription(GetLastError()));
   NotifySetting(msg);
}

void NotifySetting(string msg) {
   string output_string = StringConcatenate("[",__FILE__,"] ",NewLine,sInput);
   string acc = StringFormat(output_string,msg);
   Alert(acc);
   Print(msg);
   if(NotiEnable) SendNotification(acc);
   ResetLastError();
}

datetime HourMin(int pHour = 0, int pMinute = 0){
   MqlDateTime timeStruct;
   TimeToStruct(TimeCurrent(),timeStruct);
   timeStruct.hour   = pHour;
   timeStruct.min    = pMinute;
   return StructToTime(timeStruct);
}

datetime HourMinSec(int pHour = 0,int pMinute = 0,int pSec = 0) {
   MqlDateTime timeStruct;
   TimeToStruct(TimeCurrent(),timeStruct);
   timeStruct.hour   = pHour;
   timeStruct.min    = pMinute;
   timeStruct.sec    = pSec;
   return StructToTime(timeStruct);
}

bool VerifyHistory(string symbol) {
   bool x = true;
   datetime times[];
   ResetLastError();
   ArrayCopySeries(times,MODE_TIME,symbol,PERIOD_M1);
   if(_LastError==ERR_HISTORY_WILL_UPDATED || _LastError==ERR_NO_HISTORY_DATA) x = false; // Error ERR_HISTORY_WILL_UPDATED
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

datetime OrderProperty_OrderOpenTime(int magic){
   datetime time = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);   
      if(select && OrderMagicNumber()==magic && OrderSymbol()==_Symbol) time = OrderOpenTime();  
   }
   return time;
}

int OrderProperty_OrderType(int magic){   
   int type = 100;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);
      if(select && OrderMagicNumber() == magic && OrderSymbol()==_Symbol) type = OrderType();
   }
   return type;
}

double OrderProperty_OrderStopLoss(int magic){
   double ChkLevel = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);   
      if(select && OrderMagicNumber()==magic && OrderSymbol()==_Symbol) ChkLevel = OrderStopLoss();  
   }
   return ChkLevel;
}

bool OrderProperty_JustClose(int magic, int minutesAgo = 2){
   bool x = false;
   datetime HistoryRange = TimeCurrent()-(minutesAgo*TIME_ADD_MINUTE);
   for(int order = OrdersHistoryTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS,MODE_HISTORY);
      if(select && OrderCloseTime()>HistoryRange && OrderType()<2 && OrderSymbol()==_Symbol && OrderMagicNumber()==magic) {
         x = true;
         break;
      }
   }
   return x;
}

double OrderProperty_OrderHistoryPL(int magic, int dayHistory = 30){
   double ProfitLoss = 0, Commission = 0, Swap = 0;
   datetime HistoryRange = TimeCurrent()-(dayHistory*TIME_ADD_DAY);
   for(int order = OrdersHistoryTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS,MODE_HISTORY);
      if(select && TimeDay(OrderCloseTime())==Day() && OrderCloseTime()>HistoryRange && OrderType()<2 && OrderSymbol()==_Symbol && OrderMagicNumber()==magic) {
         ProfitLoss  += OrderProfit();
         Commission  += OrderCommission();
         Swap        += OrderSwap();
      }
   }
   return NormDollar(ProfitLoss+Commission+Swap);
}

double OrderProperty_OrderHistoryPL_Scalping(int magic, int minutesAgo, int& type){
   double ProfitLoss = 0, Commission = 0, Swap = 0;
   datetime HistoryRange = TimeCurrent()-(minutesAgo*TIME_ADD_MINUTE);
   for(int order = OrdersHistoryTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS,MODE_HISTORY);
      if(select && TimeDay(OrderCloseTime())==Day() && OrderCloseTime()>HistoryRange && OrderType()<2 && OrderSymbol()==_Symbol && OrderMagicNumber()==magic) {
         ProfitLoss  += OrderProfit();
         type        = OrderType();
      }
   }
   return NormDollar(ProfitLoss);
}

bool ReverseOrder(int magic, int minutesAgo, int& type){
   double ProfitLoss = 0;
   double open = 0,close = 0;
   int distance = 0;
   bool x = false;
   datetime HistoryRange = TimeCurrent()-(minutesAgo*TIME_ADD_MINUTE);
   for(int order = OrdersHistoryTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS,MODE_HISTORY);
      if(select && TimeDay(OrderCloseTime())==Day() && OrderCloseTime()>HistoryRange && OrderType()<2 && OrderSymbol()==_Symbol && OrderMagicNumber()==magic && minutesAgo>0) {
         ProfitLoss = OrderProfit();
         close = OrderClosePrice();
         open = OrderOpenPrice();
         type = OrderType();
      }
   }
   distance = PointToInt(fabs(close-open));
   if(ProfitLoss<0 && distance>50) x = true;
   return x;
}

int OrderProperty_OrderTypeHistory(int magic, int minutesAgo = 2){ 
   int type = 100;
   datetime HistoryRange = TimeCurrent()-(minutesAgo*TIME_ADD_MINUTE);
   for(int order = OrdersHistoryTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS,MODE_HISTORY);
      if(select && OrderMagicNumber() == magic && OrderSymbol()==_Symbol) type = OrderType();
   }
   return type;
}

int OrderCommissionChk() {
   int x = 4;
   datetime HistoryRange = TimeCurrent()-(30*TIME_ADD_DAY);
   for(int order = OrdersHistoryTotal() -1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS,MODE_HISTORY);
      if(select && OrderType()<2 && OrderCloseTime()>HistoryRange && OrderCommission()==0) {
         x = 0;
         break;
      }
   }
   return x;
}

int Identifier(int identifier){
   int x = 50;
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
   else if(sym=="AUDUSD") x = 17;
   else if(sym=="AUDJPY") x = 18;
   else if(sym=="AUDCHF") x = 19;
   else if(sym=="AUDCAD") x = 20;
   else if(sym=="NZDUSD") x = 21;
   else if(sym=="NZDJPY") x = 22;
   else if(sym=="NZDCHF") x = 23;
   else if(sym=="NZDCAD") x = 24;
   else if(sym=="CADJPY") x = 25;
   else if(sym=="CADCHF") x = 26;
   else if(sym=="AUDNZD") x = 27;
   else if(sym=="CHFJPY") x = 28;
   else if(sym=="XAUUSD") x = 29;   // Gold
   else if(sym=="XAGUSD") x = 30;   // Silver
   else if(sym=="BTCUSD") x = 31;   // Bitcoin
   else if(sym=="ETHUSD") x = 32;   // Ethrium
   else if(sym=="XRPUSD") x = 33;   // XRP
   else if(sym=="BCHUSD") x = 34;   // BCH
   else if(sym=="DCHUSD") x = 35;   // DCH
   else if(sym=="LTCUSD") x = 36;   // LTC
   else if(sym=="BRENT")  x = 37;   // BRENT
   else if(sym=="WTI")    x = 38;   // WTI

   return x * IDENTIFIER_TRADE;
}

void MagicNum(int identifier, 
               int& Mag1, int& Mag2, int& Mag3, int& Mag4, int& Mag5,
               int& Mag6, int& Mag7, int& Mag8, int& Mag9, int& Mag10, 
               int& Mag11, int& Mag12, int& Mag13, int& Mag14, int& Mag15,
               
               int& Mag16, int& Mag17, int& Mag18, int& Mag19, int& Mag20,
               int& Mag21, int& Mag22, int& Mag23,int& Mag24,int& Mag25
             ){
   int x = Identifier(identifier);
   Mag1 = x + 1;
   Mag2 = x + 2;
   Mag3 = x + 3;
   Mag4 = x + 4;
   Mag5 = x + 5;
   Mag6 = x + 6;
   Mag7 = x + 7;
   Mag8 = x + 8;
   Mag9 = x + 9;
   Mag10 = x + 10;
   Mag11 = x + 11;
   Mag12 = x + 12;
   Mag13 = x + 13;
   
   Mag14 = x + 14;
   Mag15 = x + 15;
   Mag16 = x + 16;
   Mag17 = x + 17;
   Mag18 = x + 18;
   Mag19 = x + 19;
   Mag20 = x + 20;
   Mag21 = x + 21;
   Mag22 = x + 22;
   Mag23 = x + 23;
   Mag24 = x + 24;
   Mag25 = x + 25;
}

bool ServerError(int pErrorCode){
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

bool MarginLevelProcced(int margin){
   bool proceed = false;
   if(Acc_MarginLevel==0 || Acc_MarginLevel>=margin) proceed = true;
   return proceed;
}

string SignalComment(int sig) {
   string x = "None";
   if(sig==OP_BUY)            x = "BUY";
   else if(sig==OP_BUYLIMIT)  x = "BUY LIMIT";
   else if(sig==OP_BUYSTOP)   x = "BUY STOP";
   else if(sig==OP_SELL)      x = "SELL";
   else if(sig==OP_SELLLIMIT) x = "SELL LIMIT";
   else if(sig==OP_SELLSTOP)  x = "SELL STOP";
   return x;
}

void ChartSetting(bool setcolor = true)
{
   ChartSetInteger(0,CHART_MODE,1);
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
      ChartSetInteger(0,CHART_COLOR_FOREGROUND,clrLightSlateGray);
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
   MqlDateTime tm;
   TimeToStruct(TimeCurrent(),tm);
   
   string x = "";
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
   if(!IsTesting()) {
      long width = ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);   // Chart's width
      long heigh = ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);  // Chart's hight
      
      // Assign name
      string explicitdirectory = directory+"/"+DirectoryMonthYear()+"/"+Market_Symbol;
      string FolderDirectory = "//"+explicitdirectory+"/";
      string pairscreen = Market_Symbol+"_"+ChartTimeframe()+"_"+TimeStamp()+".gif";
      string ScreenShotName = FolderDirectory+pairscreen;
   
      //Making ScreenShot
      if(!WindowScreenShot(ScreenShotName,int(width),int(heigh))) Alert(GetLastError());
      else Print("Screenshot taken on folder /MQL4/Files/",explicitdirectory);
   }
}

string ChartTimeframe() {
   return StringSubstr(EnumToString((ENUM_TIMEFRAMES)_Period),7);
}

int RangePeriod(int startbar){
   int x = 100;
   int shiftHighest  = iHighest(_Symbol,PERIOD_M1,MODE_HIGH,20,startbar);
   int shiftLowest   = iLowest(_Symbol,PERIOD_M1,MODE_LOW,20,startbar);
   double pricehigh  = iHigh(_Symbol,PERIOD_M1,shiftHighest);
   double pricelow   = iLow(_Symbol,PERIOD_M1,shiftLowest);
   double avg        = ((pricehigh+pricelow)/2)+pricelow;
   
   RefreshRates();
   if(Bid>avg) x = OP_SELL;
   else if(Ask<avg) x = OP_BUY;
   return x;
}

bool Not(int type) {
   bool x   = false;
   int sig  = StochFilter();
   if(type!=sig) x = true;

   return x;
}

int StochFilter() {
   int x    = 100;
   int OB   = 80;
   int OS   = 20;
   double stoch_now  = iStochastic(_Symbol,PERIOD_M1,15,1,3,MODE_SMA,1,MODE_MAIN,0);
   double stoch      = iStochastic(_Symbol,PERIOD_M1,15,1,3,MODE_SMA,1,MODE_MAIN,1);
   double stoch_prev = iStochastic(_Symbol,PERIOD_M1,15,1,3,MODE_SMA,1,MODE_MAIN,2);
   if(stoch>=OB || stoch_prev>=OB || stoch_now>=OB) x = OP_SELL;
   else if(stoch<=OS || stoch_prev<=OS || stoch_now<=OS) x = OP_BUY;
   return x;
}

bool SignalPeriod(int min_range, double& pricehigh, double& pricelow, int& sig){
   int shiftHighest  = iHighest(_Symbol,PERIOD_M1,MODE_HIGH,20,1);
   int shiftLowest   = iLowest(_Symbol,PERIOD_M1,MODE_LOW,20,1);
   pricehigh  = iHigh(_Symbol,PERIOD_M1,shiftHighest);
   pricelow   = iLow(_Symbol,PERIOD_M1,shiftLowest);
   int range         = PointToInt(pricehigh-pricelow);
   
   if(shiftHighest > shiftLowest) sig = OP_SELL;
   else if(shiftHighest < shiftLowest) sig = OP_BUY;

   return range>=min_range;
}

void DrawVSignal() {
   int hour = Hour();
   int signal = 100;
   int MinRange = 223;
   string rename = "";
   double lasthour = 0;
   double thishour = 0;
   double price_upper, price_lower;
   color boxcol = clrLimeGreen;
   
   if(hour>=4 && hour<=21) {
      if(BetweenTimeRangeSec(hour,11) && SignalPeriod(MinRange,price_upper,price_lower,signal)){
         if(signal==OP_BUY) rename = gSignalBuy;
         else if(signal==OP_SELL) {
            rename = gSignalSell;
            boxcol = clrTomato;
         }
         datetime StartDraw = iTime(_Symbol,PERIOD_H1,0);
         double buffer = NumToPoint(2)*1000;
         double upper_limit = price_upper+buffer;
         double lower_limit = price_lower-buffer;
         
         if(ObjectFind(rename)!=0) {
            ObjectCreate(0,rename, OBJ_TREND, 0, StartDraw, upper_limit, StartDraw, lower_limit);
            string msg = StringConcatenate(Market_Symbol," scalping ",rename," created.");
            NotifySetting(msg);
         }
         ObjectSetInteger(0,rename,OBJPROP_STYLE,STYLE_SOLID);
         ObjectSetInteger(0,rename,OBJPROP_COLOR,clrWhite);
         ObjectSetInteger(0,rename,OBJPROP_WIDTH,6);
         ObjectSetInteger(0,rename,OBJPROP_RAY,false);
         ObjectSetInteger(0,rename,OBJPROP_BACK,true);
         
         datetime rec1 = iTime(_Symbol,PERIOD_M1,21);
         datetime rec2 = iTime(_Symbol,PERIOD_M1,1);
         
         DrawRectangle(TimeStamp(),rec1,price_upper,rec2,price_lower,boxcol);
         if(TickCount(PERIOD_M1)==1) ScreenShot("Scalping");
      }
   }
}

void DrawRectangle(string name, datetime pTime1, double pPrice1, datetime pTime2, double pPrice2, color Col)
{
   if (ObjectFind(0,name) != 0)
      ObjectCreate(0,name,OBJ_RECTANGLE,0,pTime1,pPrice1,pTime2,pPrice2);    
   ObjectSetInteger(0,name,OBJPROP_COLOR,Col);
   ObjectSetInteger(0,name,OBJPROP_BACK,true);
}

int GetSignalTime(string name) {
   datetime ret = 0;
   datetime TimeLastHour = iTime(_Symbol,PERIOD_H1,1);
   datetime TimeThisHour = iTime(_Symbol,PERIOD_H1,0);
   double lasthour = 0;
   double thishour = 0;
   double exacthourshift = 0;
   int shift = 0;
   
   if(ObjectFind(0,name)==0) {
      ret = ObjectGetTimeByValue(0,name,Ask);
      shift = iBarShift(_Symbol,PERIOD_H1,ret,true);
      if(shift>1) {
         ObjectDelete(0,name);
         string msg = StringConcatenate(Market_Symbol," scalping ",name," deleted.");
         NotifySetting(msg);
         return 0;
      }
   }
   if(ret>0) return TimeHour(ret);
   else return 0;
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