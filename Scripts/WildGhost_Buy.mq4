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
#property description   "Buy Script"
#property script_show_inputs
#property strict

#import "stdlib.ex4"
string ErrorDescription(int error_code);
#import

#define MAXRISK            10
#define MAXSPREAD          35
#define IDENTIFIER_TRADE   111111111

enum ENUM_INPUT { NO_EXPIRY,
                  END_OF_TODAY,
                  END_OF_TOMORROW,
                  EXPIRY_HOUR,
                  EXPIRY_MINUTES
                };

// --- Input Variable -------------------------------------------------------------------
input bool     UseRiskManagement = true;
input double   StartLot          = 0.01,
               RiskPercent       = 1.0,
               RiskMoney         = 0.0;
extern double  EntryPrice        = 0.0,
               StopLevel         = 0.0,
               TakeLevel         = 0.0;
input int      StopLoss          = 200,
               TakeProfit        = 300,
               CommPerStdLot     = 4;
input ENUM_INPUT ExpiredType     = END_OF_TODAY;   // Pending Order expired type
input int      ExpiredTypeValue  = 1;              // Pending order expired value
input bool     UseStop           = true,
               UseTakeProfit     = true; 
input string   TradeComment      = "Long";

// --- Standard Global Variable ---------------------------------------------------------
        string Acc_Broker,Acc_Currency,Acc_Type,Market_Symbol,Acc_DrawdownText,
               SymbolCurr1,SymbolCurr2,SymbolCurrPrefix,SymbolCurrSuffix;
           int Acc_Leverage,Acc_Login,Acc_MarginCall,Acc_StopOut,Acc_Pips,Acc_Slippage,
               Acc_MaxOrder,Acc_MarginLevel,Market_Spread,Market_CalcMode;
        double Acc_Balance,Acc_Equity,Acc_MarginUsed,Acc_FreeMargin,Acc_Drawdown,Market_ContractSize,
               Market_VolumeLimit,Market_MaxLot,Market_MinLot,Market_LotStep,Market_MarginHedge,
               Market_TickValue,Market_TickSize,Market_StopLevel,Market_FreezeLevel,Market_StopFreeze;

// --- Global Variable ------------------------------------------------------------------  
static int  counter     = 0;
double      UseLot      = 0;
datetime    Expired     = 0;
int         Type        = OP_BUY;
string      msgChk,msgX;
int         MagicNumber,chkmin;
double      SL_Level,TP_Level,
            pointStop,pointTake,pointMaxSp,pointSpread;

// --- Script Initialized ---------------------------------------------------------------
int OnInit(){
   if(!InitFailed()) return INIT_FAILED;
   ulong  ul=0, ul_res=0;
   ul = GetMicrosecondCount();
   
   // Account Inilization Start
   ChartHistory();
   AccountParameter_Symbol();
   AccountParameter_Fixed();
   
   // Assigning variable
   chkmin      = ExpiredTypeValue;
   pointStop   = NumToPoint(StopLoss);
   pointTake   = NumToPoint(TakeProfit);
   pointMaxSp  = NumToPoint(MAXSPREAD);
   
   // Assigning Magic Number and Property
   MagicNumber = IDENTIFIER_TRADE;
   ul_res = GetMicrosecondCount()-ul;
   msString("Script initilized",ul_res);
   return(INIT_SUCCEEDED);
}

// --- Script Execute -------------------------------------------------------------------
void OnStart() {
   AccountParameter_Var();
   
   // Server Check
   bool toolong;
   ServerCheck(toolong);
   if(toolong) return;
   
   MqlTick tick;
   SymbolInfoTick(_Symbol,tick);

   // Defining Entry Level -------------------------------------------------------------
   if(EntryPrice>0) {
      pointSpread = NumToPoint(Market_Spread);
      
      // pending Entry price
      if(EntryPrice>tick.ask+Market_StopFreeze) Type = OP_BUYSTOP;
      else if(EntryPrice<tick.bid-Market_StopFreeze) {
         Type = OP_BUYLIMIT;
         EntryPrice -= NumToPoint(Market_Spread);
      }
      else EntryPrice = tick.ask;
      
      if(EntryPrice==tick.ask || ExpiredType==NO_EXPIRY) Expired = 0;
      else if(ExpiredType==END_OF_TODAY) {
         if(TimeCurrent()<HourMin(23,41)) Expired = HourMin(23,54);
         else Expired = TimeCurrent()+(12*PeriodSeconds(PERIOD_M1));
      }
      else if(ExpiredType==END_OF_TOMORROW) Expired = HourMin(23,54)+PeriodSeconds(PERIOD_D1);
      else if(ExpiredType==EXPIRY_HOUR) {
         if(chkmin<1) chkmin = 1;
         Expired = TimeCurrent()+(chkmin*PeriodSeconds(PERIOD_H1));
      }
      else if(ExpiredType==EXPIRY_MINUTES) {
         chkmin = ExpiredTypeValue;
         if(chkmin<12) {
            msgX = Market_Symbol+" Script Pending Order: Minimum expired is 12 minutes. Re-adjust expiry to 12 minutes!";
            Alert(msgX);
            chkmin = 12;
         }
         Expired = TimeCurrent()+(chkmin*PeriodSeconds(PERIOD_M1));
      }

      if(StopLevel>0) {
         if(StopLevel>EntryPrice-pointSpread) {
            msgX = Market_Symbol+" Script : Invalid stopLoss price";
            Alert(msgX);
            return;
         }
         else if(StopLevel>EntryPrice-pointSpread-pointMaxSp) SL_Level = EntryPrice-pointSpread-pointMaxSp;
         else SL_Level = StopLevel;
      }
      else SL_Level = fmin(EntryPrice-pointSpread-pointStop,EntryPrice-pointSpread-pointMaxSp);
      
      if(TakeLevel>0) {
         if(TakeLevel<EntryPrice) {
            msgX = Market_Symbol+" Script : Invalid takeProfit price";
            Alert(msgX);
            return;
         }
         else if(TakeLevel<EntryPrice+pointMaxSp) TP_Level = EntryPrice+pointMaxSp;
         else TP_Level = TakeLevel;
      }
      else TP_Level = fmax(EntryPrice+pointTake,EntryPrice+pointMaxSp);
   }
   else {
      EntryPrice = tick.ask;
      if(StopLevel>0) {
         if(StopLevel>tick.bid) {
            msgX = Market_Symbol+" Script : Invalid stopLoss price";
            Alert(msgX);
            return;
         }
         else if(StopLevel>tick.bid-pointMaxSp) SL_Level = tick.bid-pointMaxSp;
         else SL_Level = StopLevel;
      }
      else SL_Level = fmin(tick.bid-pointStop,tick.bid-pointMaxSp);
      
      if(TakeLevel>0) {
         if(TakeLevel<tick.ask) {
            msgX = Market_Symbol+" Script : Invalid takeProfit price";
            Alert(msgX);
            return;
         }
         else if(TakeLevel<tick.ask+pointMaxSp) TP_Level = tick.ask+pointMaxSp;
         else TP_Level = TakeLevel;
      }
      else TP_Level = fmax(tick.bid+pointTake,tick.ask+pointMaxSp);
   }
    
   // Money Management -----------------------------------------------------------------
   int StopMM = PointToInt(EntryPrice-pointSpread-SL_Level);
   if(StopMM<150) StopMM = 150;
   UseLot = LotManagement(UseRiskManagement,RiskPercent,RiskMoney,StopMM,CommPerStdLot);
   
   // Order Entry ----------------------------------------------------------------------
   if(!NewOrderChk(UseLot,msgChk)) {
      NotifySetting(msgChk);
      return;
   }
   else {
      if (!UseStop)        SL_Level = 0;
      if (!UseTakeProfit)  TP_Level = 0;
      ulong  ul=0, ul_res=0;
      ul = GetMicrosecondCount();
      int Ticket = OrderSend(_Symbol, Type, UseLot, EntryPrice, Acc_Slippage, SL_Level, TP_Level, Market_Symbol+"_"+TradeComment+" ", MagicNumber, Expired, clrGreen);
      if(Ticket == -1) OrderSendError("Script");
      else {
         ul_res = GetMicrosecondCount()-ul;
         string ordertype = "Pending";
         if(Type==OP_BUY || Type==OP_SELL) ordertype = "Market";
         msString(ordertype+" order execute",ul_res);
      }
   }
}

// --- Trade Function -------------------------------------------------------------------
bool NewOrderChk(double lot, string& retMsg) {
   bool chk             = true;
   int maxOrder         = int(AccountInfoInteger(ACCOUNT_LIMIT_ORDERS));
   double maxLot        = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   double minLot        = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double limitVol      = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_LIMIT);

   if(!EnoughFund(lot) || !MarginLevelProcced(110)) {
      retMsg = StringConcatenate(_Symbol+" : Not enough funds to open order with  ",lot," lot!");
      return false;
   }
   else if(maxOrder>0 && maxOrder==OrdersTotal()) {
      retMsg = _Symbol+" : Reaching Maximum order!";
      chk = false;
   }
   else if(lot<minLot || lot>maxLot) {
      retMsg = _Symbol+" : Invalid lot! - "+DoubleToString(lot,5);
      chk = false;
   }
   else if(limitVol>0) {
      if(TotalLotSymbol()+lot > limitVol) {
         retMsg = _Symbol+" : Reaching max volume!";
         chk = false;
      }
   }
   return chk;
}

double TotalLotSymbol(){
   double lot = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(SymbolAll(order)) lot += OrderLots();
   }
   return lot;
}

bool SymbolAll(int i, int mode = MODE_TRADES){
   return (OrderSelect(i,SELECT_BY_POS, mode) && OrderSymbol() == _Symbol);
}

bool EnoughFund(double lot, int commission = 4) {
   return Acc_FreeMargin >= MarginRequired(Acc_Leverage,Market_Spread+(5*Acc_Pips),lot,commission);
}

void ServerCheck(bool& ret){
   ret = false;
   if(LiveOperation()) {
      while(!TerminalInfoInteger(TERMINAL_CONNECTED) || IsTradeContextBusy() || !SpreadFilterPair() || !RefreshRates()) {
         Sleep(1);
         counter++;
         if(counter>5000) {
            string msg = "Server wait is too long. Terminating the script";
            Alert(msg);
            Print(msg);
            ret = true;
            return;
         }
      }
   }
   else RefreshRates();
}

bool SpreadFilterPair() {
   return Market_Spread<=MAXSPREAD;
}

bool MarginLevelProcced(int margin){
   return Acc_MarginLevel==0 || Acc_MarginLevel>=margin;
}

void OrderSendError(string ordertype){
   string NewLine = "\n", sInput  = "%s", space = " ";
   string output_string = StringConcatenate("Acc #%d - Symbol : ",sInput,space,
                                             NewLine,sInput," order failed!",space,
                                             NewLine,"Reason : ",sInput
                                           );
   string msg = StringFormat(output_string,Acc_Login,_Symbol,ordertype,ErrorDescription(GetLastError()));
   NotifySetting(msg);
}

void NotifySetting(string msg) {
   string NewLine = "\n", sInput  = "%s";
   string output_string = StringConcatenate("[",__FILE__,"] ",NewLine,sInput);
   string acc = StringFormat(output_string,msg);
   Alert(acc);
   Print(acc);
   ResetLastError();
}

double LotManagement(bool pRiskManagement, double riskpercent, double riskmoney, int stop = 150, double Comm_StdLot = 0) {
   double RefPrice               = getReferencePrice(),
          LotSize                = Market_MinLot,
          CommissionCost         = 0,
          CommPerStdLotRoundTurn = fmax(Comm_StdLot,OrderCommissionChk());
   
   if(!pRiskManagement) LotSize = VerifyLotMinMax(StartLot);
   else if(stop>0 && (riskpercent>0 || riskmoney>0)) {
      // Delta per lot
      double deltaLot = ZeroDivided(Market_TickValue/double(Market_TickSize));
      // CommissionPer1MilContract =  $4/roundtrip/1StdLot. for most broker = $20 per 1 million traded lot per turn
      if(CommPerStdLotRoundTurn>0) CommissionCost = RefPrice*CommPerStdLotRoundTurn;

      // Risk Amount Calculation
      double AmountAtRisk;
      if(riskmoney>0) AmountAtRisk = riskmoney;
      else {
         if(riskpercent>MAXRISK) riskpercent = MAXRISK; // Limit the max risk to 10%
         AmountAtRisk  = Acc_Balance * (riskpercent / 100.0);
      }

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

double MarginRequired(int leverage, int spread, double lotsize, int CommPerStdLotRoundTurn=0) {
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

int OrderCommissionChk() {
   int x = 4; // Equivalent $20 per 1million trade / direction ~ 
   for(int order = OrdersHistoryTotal() -1; order >= 0; order--){
      if(SymbolTrade(order,MODE_HISTORY) && OrderCommission()==0) {
         x = 0;
         break;
      }
   }
   return x;
}

bool SymbolTrade(int i, int mode = MODE_TRADES){
   return (OrderSelect(i,SELECT_BY_POS, mode) && OrderSymbol() == _Symbol && (OrderType()==OP_BUY || OrderType()==OP_SELL));
}

double getReferencePrice() {
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

double VerifyLotMinMax(double lot) {
   double maxLot  = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   double minLot  = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double lotStep = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   
   if(lot>maxLot) return maxLot;
   else if(lot<minLot) return minLot;
   else return Round(lot,lotStep);
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

double ZeroDivided(double value) {
   double tempVal = 1.0;
   if(value!=0) tempVal = value;
   return tempVal;
}

// --- Standard Function ----------------------------------------------------------------
bool LiveOperation() {
   return !(MQLInfoInteger(MQL_TESTER) || MQLInfoInteger(MQL_VISUAL_MODE));
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

double RoundUp(double value, double rounding) {
   return ceil(value/rounding)*rounding;
}

double RoundDn(double value, double rounding) {
   return floor(value/rounding)*rounding;
}

double Round(double value, double rounding) {
   return round(value/rounding)*rounding;
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
   Acc_Slippage         = 3;
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
      Acc_Slippage    = 25;
      Acc_Pips = 10;
   }
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

datetime HourMin(int pHour = 0, int pMinute = 0){
   MqlDateTime timeStruct;
   TimeToStruct(TimeCurrent(),timeStruct);
   timeStruct.hour   = pHour;
   timeStruct.min    = pMinute;
   return StructToTime(timeStruct);
}