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
#property description   "M1 Scalping"
#property strict

#define TIME_ADD_MINUTE    60
#define TIME_ADD_HOUR      3600
#define TIME_ADD_DAY	      86400
#define TIME_ADD_WEEK      604800
#define IDENTIFIER_TRADE   34567
#define RETRY_DELAY        2000
#define MAXRISK            10
#define MAXSPREAD          30
#define MAX_RETRIES        3

#import "stdlib.ex4"
string ErrorDescription(int error_code);
#import

// --- Input Variable ------------------------------------------------------------------
input bool     ActivateEA        = true;
input double   StartLot          = 0.01;
input string   TradeComment      = "Scalping";

// --- Standard Global Variable ---------------------------------------------------------
   datetime ArrayTime[], LastTime;
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
string      ObjIdentifier = "EXX_";
int         MagicEntry,Magic1,Magic2,Magic3,Magic4,Magic5,Magic6,Magic7,Magic8,
            Magic9,Magic10,Magic11,Magic12,Magic13,Magic14,Magic15;
double      Multiplier     = 1.15; // 1.295
int         TotalPosition  = 0,
            GridDistance   = 40;
double      CurrentStartLot,TotalLot;

// --- EA Operation Start ---------------------------------------------------------------
int OnInit(){
   if(!InitFailed()) return INIT_FAILED;
   ulong  ul=0, ul_res=0;
   ul = GetMicrosecondCount();
   // Account Inilization Start
   AccountParameter_Symbol();
   AccountParameter_Fixed();
   
   // Assigning Magic Number
   MagicNum(IDENTIFIER_TRADE,MagicEntry,Magic1,Magic2,Magic3,Magic4,Magic5,Magic6,Magic7,Magic8,Magic9,Magic10,Magic11,Magic12,Magic13,Magic14,Magic15);
   ChartSetting();
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
   
   // Running Order Properties
   AllOrderProperty(TotalLot,TotalPosition);
   ClearOrder();
   TradeClose();
   SecuringAllOrder();
   ManagePendingOrder();
   
   // --- New Order Code Start
   if(TotalPosition>0) {
      int dir = OrderProperty_OrderType(MagicEntry);
      double OP = OrderProperty_OrderOpenPrice(MagicEntry);
      
      RefreshRates();
      if(Ask<OP && dir==OP_BUY) System_SequenceOrder(OP_BUY);
      else if(Bid>OP && dir==OP_SELL) System_SequenceOrder(OP_SELL);
   }
   else if(ActivateEA && CountPositionAndPending(MagicEntry)==0 && LimitOrder() && !OrderProperty_JustClose(MagicEntry,15) && TimeCurrent()>=HourMin(1) && TimeCurrent()<=HourMin(22,15)){
      int ScalpingEntry = TradeEntry();
      string comment = Market_Symbol+" - 1"+" ";
      double PendingOrder = PendingPrice();
      if(ScalpingEntry<2) {
         OpenOrder(ScalpingEntry,MagicEntry,StartLot,comment);
         ScreenShot();
      }
      else if(ScalpingEntry==OP_BUYLIMIT) OpenBuyLimit(MagicEntry,StartLot,PendingOrder,comment,120);
      else if(ScalpingEntry==OP_SELLLIMIT) OpenSellLimit(MagicEntry,StartLot,PendingOrder,comment,120);
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

double bid(string pSymbol=NULL){
   if(pSymbol==NULL) pSymbol=_Symbol;
   return(SymbolInfoDouble(pSymbol,SYMBOL_BID));
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
   bool allow = true;
   if(Market_Spread>MAXSPREAD) allow=false;
   return allow;
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
   string p1 = "";
   string p2 = "";
   string p3 = "";
   string comma = ",";
   string currency = "$";

   string x = DoubleToString(NormDollar(dollaValue),2);
   string ret = x;
   
   if(Acc_Currency!="USD") currency = Acc_Currency;
   
   int z = StringLen(x);
   int shift = 0;
   if(dollaValue<0)  shift = 1;
   
   if(z>6+shift && z<10+shift) {
      if(z==7+shift) {
         p1 = StringSubstr(x,0,1+shift);
         p2 = StringSubstr(x,1+shift);
      }
      else if(z==8+shift) {
         p1 = StringSubstr(x,0,2+shift);
         p2 = StringSubstr(x,2+shift);
      }
      else if(z==9+shift) {
         p1 = StringSubstr(x,0,3+shift);
         p2 = StringSubstr(x,3+shift);
      }
      ret = p1+comma+p2;
   }
   else if(z>=10+shift && z<13+shift) {
      if(z==10+shift) {
         p1 = StringSubstr(x,0,1+shift);
         p2 = StringSubstr(x,1+shift,3+shift);
         p3 = StringSubstr(x,4+shift);
      }
      else if(z==11+shift) {
         p1 = StringSubstr(x,0,2+shift);
         p2 = StringSubstr(x,2+shift,4+shift);
         p3 = StringSubstr(x,5+shift);
      }
      else if(z==12+shift) {
         p1 = StringSubstr(x,0,3+shift);
         p2 = StringSubstr(x,3+shift,5+shift);
         p3 = StringSubstr(x,6+shift);
      }
      ret = p1+comma+p2+comma+p3;
   }
   return currency+" "+ret;
}

double NormLot(double lot) {
   double useLot  = Market_MinLot;
   if(lot>Market_MaxLot) useLot = Market_MaxLot;
   else if(lot>Market_MinLot) useLot = MathFloor(lot/Market_LotStep)*Market_LotStep;
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

int CountPosition(int magic){
   int count = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);
      if(select && OrderMagicNumber() == magic && OrderSymbol()==_Symbol && OrderType()<2) count++;
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

int CountOtherPair(){
   int count = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);
      if(select && OrderSymbol()!=_Symbol && OrderType()<2) count++;
   }
   return count;
}

bool LimitOrder() {
   bool x = true;
   if(CountOtherPair()>0 && Acc_Balance<=1000) x = false;
   return x;
}

double CountLot(int magic){
   double UseLot  = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);
      if(select && OrderMagicNumber()== magic && OrderSymbol()==_Symbol && OrderType()<2) UseLot = OrderLots();
   }   
   return UseLot;
}

void TickData(){
   if(!IsTesting()){
      while(!IsConnected()) Sleep(1);
      while(IsTradeContextBusy()) Sleep(1);
      while(!RefreshRates()) Sleep(1);
   }
   else RefreshRates();
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
   else if(!MarginLevelProcced(105)) {
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
   string   msg      = "";
   if(expiredMinutes>0) {
      if(expiredMinutes<12) {
         msg = _Symbol+" Pending Order: Minimum expired is 12 minutes. Readjust expiry to 12 minutes!";
         NotifySetting(msg);
         Expired = TimeCurrent()+12*TIME_ADD_MINUTE;
      }
      else Expired = TimeCurrent()+expiredMinutes*TIME_ADD_MINUTE;
      if(Expired>HourMin(23,54) && TimeCurrent()<HourMin(23,40)) Expired = HourMin(23,54);   // expired end of the day
   }
   
   RefreshRates();
   if((type==OP_BUYLIMIT || type==OP_SELLSTOP) && Bid>pPricePending+Market_StopLevel) proceed = true;
   else if((type==OP_SELLLIMIT || type==OP_BUYSTOP)) {
      arrow = clrRed;
      if(Ask<pPricePending-Market_StopLevel) proceed = true;
   }
   
   if(!proceed || pPricePending<=0 || !StopLevel(pPricePending)) {
      msg = _Symbol+" Pending Order: Invalid pending price placement!";
      NotifySetting(msg);
      return;
   }
   else if(lot<Market_MinLot || lot>Market_MaxLot) {
      msg = _Symbol+" Pending Order: Invalid lot!";
      NotifySetting(msg);
      return;
   }
   else if(!MarginLevelProcced(102)) {
      msg = StringConcatenate(_Symbol+" Pending Order: Not enough funds to open order with  ",lot," lot!");
      NotifySetting(msg);
      Sleep(2000);
      return;
   }
   else if(proceed && type>=2){
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
      } // end while retry
      if(ticket == -1) OrderSendError("Pending");
   }
}

void OpenBuyLimit(int magic, double lot, double pPendingPrice, string comment, int expired = 0){
   if(CountPositionAndPending(magic)==0) OpenPendingOrder(OP_BUYLIMIT,magic,lot,pPendingPrice,comment,expired);
}

void OpenSellLimit(int magic, double lot, double pPendingPrice, string comment, int expired = 0){
   if(CountPositionAndPending(magic)==0) OpenPendingOrder(OP_SELLLIMIT,magic,lot,pPendingPrice,comment,expired);
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
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);
      if(select && OrderMagicNumber() == magic && OrderSymbol()==_Symbol && OrderType()<2 && SLPoint!=0){
         bool ChkCondition  = false;
         double bufferSL = NumToPoint(SLPoint);
         double stopLoss = 0;
         RefreshRates();
         double ClosingBuy = bid();
         double ClosingSell = ask();
         if(!SpreadFilterPair()){
            ClosingBuy = ask();
            ClosingSell = bid();
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

bool HiddenTP(int magic, int TPPoint){
   bool x = false;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);
      if(select && OrderMagicNumber() == magic && OrderSymbol()==_Symbol && OrderType()<2 && TPPoint!=0){
         bool ChkCondition  = false;
         double bufferTP = NumToPoint(TPPoint);
         double takeProfit = 0;
         RefreshRates();
         double ClosingBuy = bid();
         double ClosingSell = ask();
         if(!SpreadFilterPair()){
            ClosingBuy = ask();
            ClosingSell = bid();
         }
         if(OrderType()==OP_BUY) {
            takeProfit  = OrderOpenPrice() + bufferTP;
            if(ClosingBuy>=takeProfit) x = true;
         }
         else if(OrderType()==OP_SELL){
            takeProfit  = OrderOpenPrice() - bufferTP;
            if(ClosingSell<=takeProfit) x = true;
         }
      }
   }
   return x;
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

void BreakEven(int magic, int distance, int lock = 5){
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);
      if(select && OrderMagicNumber()==magic && OrderSymbol()==_Symbol && OrderType()<2 && distance>0 && lock>=0){         
         double TrailingLevel,LockBE;
         double buffer_distance = NumToPoint(distance);
         double buffer_lock = NumToPoint(lock);
         if(OrderType() == OP_SELL){
            TrailingLevel = OrderOpenPrice() - buffer_distance;
            LockBE = OrderOpenPrice() - buffer_lock;
            if(ask()<TrailingLevel && (OrderStopLoss()==0 || OrderStopLoss()>OrderOpenPrice())) ModifyStopLoss(magic,LockBE);
         }
         else if(OrderType() == OP_BUY){
            TrailingLevel = OrderOpenPrice() + buffer_distance;
            LockBE = OrderOpenPrice() + buffer_lock;
            if(bid()>TrailingLevel && (OrderStopLoss()==0 || OrderStopLoss()<OrderOpenPrice())) ModifyStopLoss(magic,LockBE);
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
            if(ask()<TrailingLevel) ModifyStopLoss(magic,StepLevel);
         }
         else if(OrderType() == OP_BUY && OrderStopLoss()>=OrderOpenPrice()){
            TrailingLevel = OrderStopLoss() + buffer_distance;
            StepLevel     = OrderStopLoss() + buffer_step;
            if(bid()>TrailingLevel) ModifyStopLoss(magic,StepLevel);
         }
      } 
   } 
}

void SystemTrailing(int magic, int distance, int step = 10){
   if(CountPosition(magic)>0){
      BreakEven(magic,distance,step);
      TrailingStop(magic,distance,step);
   }
}

bool BetweenPriceRange(double above, double below) {
   bool x = false;
   RefreshRates();
   if(Bid<=above && Bid>=below) x = true;   
   return x;
}

void ModifyPendingOrder(int magic, double pPending) { 
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS); 
      if(select && OrderSymbol()==_Symbol && OrderMagicNumber()==magic && pPending>0){
         double NormPending = NormPrice(pPending);
         if(AcceptableDifference(OrderOpenPrice(),NormPending) && StopLevel(NormPending)){
            datetime bufferExpired = TimeCurrent()+12*TIME_ADD_MINUTE;
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

bool NewBar(int timeframe){
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

bool VerifyHistory(string symbol) {
   bool x = true;
   datetime times[];
   ResetLastError();
   ArrayCopySeries(times,MODE_TIME,symbol,PERIOD_M1);
   if(_LastError==ERR_HISTORY_WILL_UPDATED || _LastError==ERR_NO_HISTORY_DATA) x = false; // Error ERR_HISTORY_WILL_UPDATED
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

double OrderProperty_OrderOpenPrice(int magic){
   double ChkLevel = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);   
      if(select && OrderMagicNumber()==magic && OrderSymbol()==_Symbol) ChkLevel = OrderOpenPrice();  
   }
   return ChkLevel;
}

double OrderProperty_OrderLot(int magic){
   double lot = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);   
      if(select && OrderMagicNumber()==magic && OrderSymbol()==_Symbol) lot = OrderLots();  
   }
   return lot;
}

datetime OrderProperty_OrderOpenTime(int magic){
   datetime time = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);   
      if(select && OrderMagicNumber()==magic && OrderSymbol()==_Symbol) time = OrderOpenTime();  
   }
   return time;
}

int OrderProperty_OrderType(int Magic){   
   int type = 100;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);
      if(select && OrderMagicNumber() == Magic && OrderSymbol()==_Symbol) type = OrderType();
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

double OrderProperty_OrderPL(int magic){
   double ProfitLoss = 0, Commission = 0, Swap = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);   
      if(select && OrderMagicNumber()==magic && OrderSymbol()==_Symbol && OrderType()<2) {
         ProfitLoss +=OrderProfit();
         Commission +=OrderCommission();
         Swap +=OrderSwap();
      }
   }
   return NormDollar(ProfitLoss+Commission+Swap);
}

double OrderProperty_OrderPL(){
   double ProfitLoss = 0, Commission = 0, Swap = 0;
   for(int order = 0; order < OrdersTotal(); order++){
      bool select = OrderSelect(order,SELECT_BY_POS);   
      if(select && OrderSymbol()==_Symbol && OrderType()<2) {
         ProfitLoss +=OrderProfit();
         Commission +=OrderCommission();
         Swap +=OrderSwap();
      }
   }
   return NormDollar(ProfitLoss+Commission+Swap);
}

bool OrderProperty_JustClose(int magic, int minutesago = 1){
   bool x = false;
   datetime HistoryRange = TimeCurrent()-(minutesago*TIME_ADD_MINUTE);
   for(int order = OrdersHistoryTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS,MODE_HISTORY);
      if(select && OrderCloseTime()>HistoryRange && OrderType()<2 && OrderSymbol()==_Symbol && OrderMagicNumber()==magic) {
         x = true;
         break;
      }
   }
   return x;
}

int OrderCommissionChk() {
   int x = 4;
   for(int order = OrdersHistoryTotal() -1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS,MODE_HISTORY);
      if(select && OrderType()<2 && OrderCommission()==0) {
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

void MagicNum(int identifier, int& Mag1, int& Mag2, int& Mag3, int& Mag4, int& Mag5, int& Mag6, int& Mag7, int& Mag8,
int& Mag9, int& Mag10, int& Mag11, int& Mag12, int& Mag13, int& Mag14, int& Mag15, int& Mag16){
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
      ChartSetInteger(0,CHART_COLOR_FOREGROUND,C'37,44,63');
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

// --- EA Trade Logic Start ---------------------------------------------------------------

int TradeTrend(int timeframe) {
   int x = 100;
   double ma50       = iMA(_Symbol,timeframe,50,0,MODE_EMA,PRICE_CLOSE,1);
   double ma100      = iMA(_Symbol,timeframe,100,0,MODE_EMA,PRICE_CLOSE,1);
   double ma200      = iMA(_Symbol,timeframe,200,0,MODE_EMA,PRICE_CLOSE,1);
   double ma50_Now   = iMA(_Symbol,timeframe,50,0,MODE_EMA,PRICE_CLOSE,0);
   double ma100_Now  = iMA(_Symbol,timeframe,100,0,MODE_EMA,PRICE_CLOSE,0);
   double ma200_Now  = iMA(_Symbol,timeframe,200,0,MODE_EMA,PRICE_CLOSE,0);
   
   if(ma50>ma100 && ma100>ma200 && ma50_Now>ma100_Now && ma100_Now>ma200_Now) x = OP_BUY;
   else if(ma50<ma100 && ma100<ma200 && ma50_Now<ma100_Now && ma100_Now<ma200_Now) x = OP_SELL;
   return x;
}

int TrendClose() {
   int x = 100;
   double ma50    = iMA(_Symbol,PERIOD_M15,50,0,MODE_EMA,PRICE_CLOSE,1);
   double ma100   = iMA(_Symbol,PERIOD_M15,100,0,MODE_EMA,PRICE_CLOSE,1);
   double ma200   = iMA(_Symbol,PERIOD_M15,200,0,MODE_EMA,PRICE_CLOSE,1);

   if(ma50>ma100 && ma50>ma200) x = OP_BUY;
   else if(ma50<ma100 && ma50<ma200) x = OP_SELL;
   return x;
}

int EMA_Condition(int timeframe, int period) {
   int x = 100;
   double ma_now   = iMA(_Symbol,timeframe,period,0,MODE_EMA,PRICE_CLOSE,1);
   double ma_prev  = iMA(_Symbol,timeframe,period,0,MODE_EMA,PRICE_CLOSE,2);
   
   if(ma_now>ma_prev) x = OP_BUY;
   else if(ma_now<ma_prev) x = OP_SELL;

   return x;
}

bool TrendFilter(int type) {
   bool x = false;
   double ma = iMA(_Symbol,PERIOD_M15,50,0,MODE_EMA,PRICE_CLOSE,0);
   
   RefreshRates();
   if(type==OP_BUY && Ask<=ma) x = true;
   else if(type==OP_SELL && Bid>=ma) x = true;

   return x;
}

double PendingPrice() {
   return NormPrice(iMA(_Symbol,PERIOD_M15,50,0,MODE_EMA,PRICE_CLOSE,1));
}

void ManagePendingOrder() {
   if(CountPending(MagicEntry)>0) {
      int dir = OrderProperty_OrderType(MagicEntry);
      double compare = PendingPrice();
      double op = OrderProperty_OrderOpenPrice(MagicEntry);
      if((dir==OP_SELLLIMIT && Ask<compare-Market_StopLevel) || (dir==OP_BUYLIMIT && Bid>compare+Market_StopLevel)) {
         if(AcceptableDifference(op,compare) && StopLevel(compare)) ModifyPendingOrder(MagicEntry,compare);
      }
   }
}

int Trend_Condition(int timeframe) {
   int x = 100;
   if(EMA_Condition(timeframe,50)==OP_BUY && EMA_Condition(timeframe,100)==OP_BUY && EMA_Condition(timeframe,200)==OP_BUY) x = OP_BUY;
   else if(EMA_Condition(timeframe,50)==OP_SELL && EMA_Condition(timeframe,100)==OP_SELL && EMA_Condition(timeframe,200)==OP_SELL) x = OP_SELL;
   return x;
}

int MACD(int timeframe) {
   int x = 100;
   double macd       = iMACD(_Symbol,timeframe,12,26,1,PRICE_CLOSE,MODE_MAIN,1);
   double macd_Now   = iMACD(_Symbol,timeframe,12,26,1,PRICE_CLOSE,MODE_MAIN,0);
   
   if(macd>0 && macd_Now>0) x = OP_BUY;
   else if(macd<0 && macd_Now<0) x = OP_SELL;
   return x;
}

int Stoch(int timeframe, int shift, int Above, int Below, double& stoch_value) {
   int x = 100;
   stoch_value = iStochastic(_Symbol,timeframe,3,1,3,MODE_EMA,1,MODE_MAIN,shift);
   
   if(stoch_value<=Below) x = OP_BUY;
   else if(stoch_value>=Above) x = OP_SELL;
   return x;
}

int TradeEntry() {
   int x = 100;
   int trend = 100;
   int Trend_M15 = TradeTrend(PERIOD_M15);
   int Trend_M5 = TradeTrend(PERIOD_M5);
   int Macd = MACD(PERIOD_M15);
   double StochM30,StochM30Now,StochM1,StochM15,StochM15_Prev,StochM5,StochM5_Prev;
   int Stoch_M1 = Stoch(PERIOD_M1,1,99,1,StochM1);
   int Stoch_M30 = Stoch(PERIOD_M30,1,90,10,StochM30);
   int StochNow_M30 = Stoch(PERIOD_M30,0,95,5,StochM30Now);
   int Stoch_M15 = Stoch(PERIOD_M15,1,95,5,StochM15);
   int StochPrev_M15 = Stoch(PERIOD_M15,2,95,5,StochM15_Prev);
   int Stoch_M5 = Stoch(PERIOD_M5,1,80,20,StochM5);
   int StochPrev_M5 = Stoch(PERIOD_M5,2,80,20,StochM5_Prev);
   
   int TrendM30   = Trend_Condition(PERIOD_M30);
   int TrendM15    = Trend_Condition(PERIOD_M15);
   int TrendM5    = Trend_Condition(PERIOD_M5);
   
   // Trend
   if(Trend_M15==OP_BUY && Trend_M5==OP_BUY && Macd==OP_BUY) trend = OP_BUY;
   else if(Trend_M15==OP_SELL && Trend_M5==OP_SELL && Macd==OP_SELL) trend = OP_SELL;

   if(trend==OP_BUY) {
      if(Stoch_M15==OP_BUY && (Stoch_M30==OP_BUY || StochM15_Prev<=StochM15)) x = OP_BUY;
      else if(StochPrev_M15==OP_BUY && StochM15_Prev<=StochM15 && Stoch_M30==OP_BUY) x = OP_BUY;
   }
   else if(trend==OP_SELL) {
      if(Stoch_M15==OP_SELL && (Stoch_M30==OP_SELL || StochM15_Prev>=StochM15)) x = OP_SELL;
      else if(StochPrev_M15==OP_SELL && StochM15_Prev>=StochM15 && Stoch_M30==OP_SELL) x = OP_SELL;
   }
   
   RefreshRates();
   double ma = PendingPrice();
   double buffer = Market_StopLevel+NumToPoint(2);
   if(x==OP_BUY && !TrendFilter(OP_BUY) && Bid>ma+buffer) x = OP_BUYLIMIT;
   else if(x==OP_SELL && !TrendFilter(OP_SELL) && Ask<ma-buffer) x = OP_SELLLIMIT;
   
   return x;
}

void TradeClose() {
   if(CountPosition(MagicEntry)>0) {
      bool protect = false;
      double StochM15;
      int Stoch_M15 = Stoch(PERIOD_M15,1,80,20,StochM15);
      int Trend_M15 = TradeTrend(PERIOD_M15);
      double PnL = OrderProperty_OrderPL(MagicEntry);
      int dir = OrderProperty_OrderType(MagicEntry);
      
      int Macd = MACD(PERIOD_M15);
      int tp_distance = 75;
      int tp_alternate = fmax(25,Market_Spread);
      
      HiddenSL(MagicEntry,600);
      if(MartingaleClose()) CloseOrder(MagicEntry);
      
      if(dir==OP_BUY) {
         if(Macd!=OP_BUY || Trend_M15!=OP_BUY) tp_distance = tp_alternate;
         //if((Stoch_M15==OP_SELL && PnL>0) || HiddenTP(MagicEntry,tp_distance)) protect = true;
         if(HiddenTP(MagicEntry,tp_distance)) protect = true;
         if(Stoch_M15==OP_SELL && PnL<0) {
            System_BE(110);
            OptimizeSL();
         }
      }
      else if(dir==OP_SELL) {
         if(Macd!=OP_SELL || Trend_M15!=OP_SELL) tp_distance = tp_alternate;
         //if((Stoch_M15==OP_BUY && PnL>0) || HiddenTP(MagicEntry,tp_distance)) protect = true;
         if(HiddenTP(MagicEntry,tp_distance)) protect = true;
         if(Stoch_M15==OP_BUY && PnL<0) {
            System_BE(110);
            OptimizeSL();
         }
      }
      if(protect) ProtectingTargetScalp(MagicEntry);
   }
}

void ProtectingTargetScalp(int magic, int lock = 10) {
   if(CountPosition(magic)>0) {
      int type = OrderProperty_OrderType(magic);
      double SL = OrderProperty_OrderStopLoss(magic);
      double TriggerSL;
      double dis_lock = NumToPoint(lock);

      RefreshRates();
      if(type==OP_BUY) {
         TriggerSL = Bid-(dis_lock+Market_StopLevel);
         if(SL<TriggerSL||SL==0) ModifyStopLoss(magic,TriggerSL);
      }
      else if(type==OP_SELL) {
         TriggerSL = Ask+(dis_lock+Market_StopLevel);
         if(SL>TriggerSL||SL==0) ModifyStopLoss(magic,TriggerSL);
      }
   }
}

void ClearOrder() {
   if(CountPosition(MagicEntry)==0) {
      if(CountPosition(Magic1)>0) CloseOrder(Magic1);
      if(CountPosition(Magic2)>0) CloseOrder(Magic2);
      if(CountPosition(Magic3)>0) CloseOrder(Magic3);
      if(CountPosition(Magic4)>0) CloseOrder(Magic4);
      if(CountPosition(Magic5)>0) CloseOrder(Magic5);
      if(CountPosition(Magic6)>0) CloseOrder(Magic6);
      if(CountPosition(Magic7)>0) CloseOrder(Magic7);
      if(CountPosition(Magic8)>0) CloseOrder(Magic8);
      if(CountPosition(Magic9)>0) CloseOrder(Magic9);
      if(CountPosition(Magic10)>0) CloseOrder(Magic10);
      if(CountPosition(Magic11)>0) CloseOrder(Magic11);
      if(CountPosition(Magic12)>0) CloseOrder(Magic12);
      if(CountPosition(Magic13)>0) CloseOrder(Magic13);
      if(CountPosition(Magic14)>0) CloseOrder(Magic14);
   }
}

void System_BE(int lock) {
   BreakEven(MagicEntry,lock);
   BreakEven(Magic1,lock);
   BreakEven(Magic2,lock);
   BreakEven(Magic3,lock);
   BreakEven(Magic4,lock);
   BreakEven(Magic5,lock);
   BreakEven(Magic6,lock);
   BreakEven(Magic7,lock);
   BreakEven(Magic8,lock);
   BreakEven(Magic9,lock);
   BreakEven(Magic10,lock);
   BreakEven(Magic11,lock);
   BreakEven(Magic12,lock);
   BreakEven(Magic13,lock);
   BreakEven(Magic14,lock);
}

void OptimizeSL() {
   if(CountPosition(MagicEntry)>0) {
      int dir = OrderProperty_OrderType(MagicEntry);
      int Count1 = CountPosition(Magic1);
      int Count2 = CountPosition(Magic2);
      int Count3 = CountPosition(Magic3);
      int Count4 = CountPosition(Magic4);
      int Count5 = CountPosition(Magic5);
      int Count6 = CountPosition(Magic6);
      int Count7 = CountPosition(Magic7);
      int Count8 = CountPosition(Magic8);
      int Count9 = CountPosition(Magic9);
      int Count10 = CountPosition(Magic10);
      int Count11 = CountPosition(Magic11);
      int Count12 = CountPosition(Magic12);
      int Count13 = CountPosition(Magic13);
      int Count14 = CountPosition(Magic14);
      
      double magentry_sl = OrderProperty_OrderStopLoss(MagicEntry);
      double mag1_sl = OrderProperty_OrderStopLoss(Magic1);
      double mag2_sl = OrderProperty_OrderStopLoss(Magic2);
      double mag3_sl = OrderProperty_OrderStopLoss(Magic3);
      double mag4_sl = OrderProperty_OrderStopLoss(Magic4);
      double mag5_sl = OrderProperty_OrderStopLoss(Magic5);
      double mag6_sl = OrderProperty_OrderStopLoss(Magic6);
      double mag7_sl = OrderProperty_OrderStopLoss(Magic7);
      double mag8_sl = OrderProperty_OrderStopLoss(Magic8);
      double mag9_sl = OrderProperty_OrderStopLoss(Magic9);
      double mag10_sl = OrderProperty_OrderStopLoss(Magic10);
      double mag11_sl = OrderProperty_OrderStopLoss(Magic11);
      double mag12_sl = OrderProperty_OrderStopLoss(Magic12);
      double mag13_sl = OrderProperty_OrderStopLoss(Magic13);
      double mag14_sl = OrderProperty_OrderStopLoss(Magic14);
      
      double sl_entry = 0;
      double sl_1 = 0;
      double sl_2 = 0;
      double sl_3 = 0;
      double sl_4 = 0;
      double sl_5 = 0;
      double sl_6 = 0;
      double sl_7 = 0;
      double sl_8 = 0;
      double sl_9 = 0;
      double sl_10 = 0;
      double sl_11 = 0;
      double sl_12 = 0;
      double sl_13 = 0;
      double sl_14 = 0;
      double sync_SL = 0;
      
      if(magentry_sl>0) sl_entry = magentry_sl;
      if(Count1>0 && mag1_sl>0) sl_1 = mag1_sl;
      if(Count2>0 && mag2_sl>0) sl_2 = mag2_sl;
      if(Count3>0 && mag3_sl>0) sl_3 = mag3_sl;
      if(Count4>0 && mag4_sl>0) sl_4 = mag4_sl;
      if(Count5>0 && mag5_sl>0) sl_5 = mag5_sl;
      if(Count6>0 && mag6_sl>0) sl_6 = mag6_sl;
      if(Count7>0 && mag7_sl>0) sl_7 = mag7_sl;
      if(Count8>0 && mag8_sl>0) sl_8 = mag8_sl;
      if(Count9>0 && mag9_sl>0) sl_9 = mag9_sl;
      if(Count10>0 && mag10_sl>0) sl_10 = mag10_sl;
      if(Count11>0 && mag11_sl>0) sl_11 = mag11_sl;
      if(Count12>0 && mag12_sl>0) sl_12 = mag12_sl;
      if(Count13>0 && mag13_sl>0) sl_13 = mag13_sl;
      if(Count14>0 && mag14_sl>0) sl_14 = mag14_sl;
      
      if(dir==OP_BUY) {
         sync_SL = Max(sl_entry,sl_1,sl_2,sl_3,sl_4,sl_5,sl_6,sl_7,sl_8,sl_9,sl_10,sl_11,sl_12,sl_13,sl_14);
         if(sync_SL>0) {
            if(Count1>0 && mag1_sl>0 && mag1_sl<sync_SL) ModifyStopLoss(Magic1,sync_SL);
            if(Count2>0 && mag2_sl>0 && mag2_sl<sync_SL) ModifyStopLoss(Magic2,sync_SL);
            if(Count3>0 && mag3_sl>0 && mag3_sl<sync_SL) ModifyStopLoss(Magic3,sync_SL);
            if(Count4>0 && mag4_sl>0 && mag4_sl<sync_SL) ModifyStopLoss(Magic4,sync_SL);
            if(Count5>0 && mag5_sl>0 && mag5_sl<sync_SL) ModifyStopLoss(Magic5,sync_SL);
            if(Count6>0 && mag6_sl>0 && mag6_sl<sync_SL) ModifyStopLoss(Magic6,sync_SL);
            if(Count7>0 && mag7_sl>0 && mag7_sl<sync_SL) ModifyStopLoss(Magic7,sync_SL);
            if(Count8>0 && mag8_sl>0 && mag8_sl<sync_SL) ModifyStopLoss(Magic8,sync_SL);
            if(Count9>0 && mag9_sl>0 && mag9_sl<sync_SL) ModifyStopLoss(Magic9,sync_SL);
            if(Count10>0 && mag10_sl>0 && mag10_sl<sync_SL) ModifyStopLoss(Magic10,sync_SL);
            if(Count11>0 && mag11_sl>0 && mag11_sl<sync_SL) ModifyStopLoss(Magic11,sync_SL);
            if(Count12>0 && mag12_sl>0 && mag12_sl<sync_SL) ModifyStopLoss(Magic12,sync_SL);
            if(Count13>0 && mag13_sl>0 && mag13_sl<sync_SL) ModifyStopLoss(Magic13,sync_SL);
            if(Count14>0 && mag14_sl>0 && mag14_sl<sync_SL) ModifyStopLoss(Magic14,sync_SL);
         }
      }
      else if(dir==OP_SELL) {
         sync_SL = Sell_LowestSL();
            if(sync_SL>0) {
            if(Count1>0 && mag1_sl>0 && mag1_sl>sync_SL) ModifyStopLoss(Magic1,sync_SL);
            if(Count2>0 && mag2_sl>0 && mag2_sl>sync_SL) ModifyStopLoss(Magic2,sync_SL);
            if(Count3>0 && mag3_sl>0 && mag3_sl>sync_SL) ModifyStopLoss(Magic3,sync_SL);
            if(Count4>0 && mag4_sl>0 && mag4_sl>sync_SL) ModifyStopLoss(Magic4,sync_SL);
            if(Count5>0 && mag5_sl>0 && mag5_sl>sync_SL) ModifyStopLoss(Magic5,sync_SL);
            if(Count6>0 && mag6_sl>0 && mag6_sl>sync_SL) ModifyStopLoss(Magic6,sync_SL);
            if(Count7>0 && mag7_sl>0 && mag7_sl>sync_SL) ModifyStopLoss(Magic7,sync_SL);
            if(Count8>0 && mag8_sl>0 && mag8_sl>sync_SL) ModifyStopLoss(Magic8,sync_SL);
            if(Count9>0 && mag9_sl>0 && mag9_sl>sync_SL) ModifyStopLoss(Magic9,sync_SL);
            if(Count10>0 && mag10_sl>0 && mag10_sl>sync_SL) ModifyStopLoss(Magic10,sync_SL);
            if(Count11>0 && mag11_sl>0 && mag11_sl>sync_SL) ModifyStopLoss(Magic11,sync_SL);
            if(Count12>0 && mag12_sl>0 && mag12_sl>sync_SL) ModifyStopLoss(Magic12,sync_SL);
            if(Count13>0 && mag13_sl>0 && mag13_sl>sync_SL) ModifyStopLoss(Magic13,sync_SL);
            if(Count14>0 && mag14_sl>0 && mag14_sl>sync_SL) ModifyStopLoss(Magic14,sync_SL);
         }
      }      
   }
}

double Sell_LowestSL(){
   double sl = Ask+NumToPoint(5000);
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);   
      if(select && OrderSymbol()==_Symbol && OrderType()==OP_SELL && OrderStopLoss()>0 &&
      (OrderMagicNumber()==Magic1 || OrderMagicNumber()==Magic2 || OrderMagicNumber()==Magic3 ||
      OrderMagicNumber()==Magic4 || OrderMagicNumber()==Magic5 || OrderMagicNumber()==Magic6 ||
      OrderMagicNumber()==Magic7 || OrderMagicNumber()==Magic8 || OrderMagicNumber()==Magic9 ||
      OrderMagicNumber()==Magic10 || OrderMagicNumber()==Magic11 || OrderMagicNumber()==Magic12 ||
      OrderMagicNumber()==Magic13 || OrderMagicNumber()==Magic14 || OrderMagicNumber()==Magic15)
      ) 
      {if(OrderStopLoss()<sl) sl = OrderStopLoss();}
   }
   return sl;
}

double Max(double val1=0, double val2=0, double val3=0, double val4=0, double val5=0, double val6=0, double val7=0, double val8=0, double val9=0, double val10=0, double val11=0, double val12=0, double val13=0, double val14=0, double val15=0) {
   double compare_2 = fmax(val1,val2);
   double compare_3 = fmax(compare_2,val3);
   double compare_4 = fmax(compare_3,val4);
   double compare_5 = fmax(compare_4,val5);
   double compare_6 = fmax(compare_5,val6);
   double compare_7 = fmax(compare_6,val7);
   double compare_8 = fmax(compare_7,val8);
   double compare_9 = fmax(compare_8,val9);
   double compare_10 = fmax(compare_9,val10);
   double compare_11 = fmax(compare_10,val11);
   double compare_12 = fmax(compare_11,val12);
   double compare_13 = fmax(compare_12,val13);
   double compare_14 = fmax(compare_13,val14);
   double compare_15 = fmax(compare_14,val15);
   
   return compare_15;
}

double Min(double val1=0, double val2=0, double val3=0, double val4=0, double val5=0, double val6=0, double val7=0, double val8=0, double val9=0, double val10=0, double val11=0, double val12=0, double val13=0, double val14=0, double val15=0) {
   double compare_2 = fmin(val1,val2);
   double compare_3 = fmin(compare_2,val3);
   double compare_4 = fmin(compare_3,val4);
   double compare_5 = fmin(compare_4,val5);
   double compare_6 = fmin(compare_5,val6);
   double compare_7 = fmin(compare_6,val7);
   double compare_8 = fmin(compare_7,val8);
   double compare_9 = fmin(compare_8,val9);
   double compare_10 = fmin(compare_9,val10);
   double compare_11 = fmin(compare_10,val11);
   double compare_12 = fmin(compare_11,val12);
   double compare_13 = fmin(compare_12,val13);
   double compare_14 = fmin(compare_13,val14);
   double compare_15 = fmin(compare_14,val15);
   
   return compare_15;
}

void SecuringAllOrder() {
   if(CountPosition(MagicEntry)>0) {
      int dir = OrderProperty_OrderType(MagicEntry);
      double SL = OrderProperty_OrderStopLoss(MagicEntry);
      
      if(SL>0) {
         int Count1 = CountPosition(Magic1);
         int Count2 = CountPosition(Magic2);
         int Count3 = CountPosition(Magic3);
         int Count4 = CountPosition(Magic4);
         int Count5 = CountPosition(Magic5);
         int Count6 = CountPosition(Magic6);
         int Count7 = CountPosition(Magic7);
         int Count8 = CountPosition(Magic8);
         int Count9 = CountPosition(Magic9);
         int Count10 = CountPosition(Magic10);
         int Count11 = CountPosition(Magic11);
         int Count12 = CountPosition(Magic12);
         int Count13 = CountPosition(Magic13);
         int Count14 = CountPosition(Magic14);
      
         double mag1_sl = OrderProperty_OrderStopLoss(Magic1);
         double mag2_sl = OrderProperty_OrderStopLoss(Magic2);
         double mag3_sl = OrderProperty_OrderStopLoss(Magic3);
         double mag4_sl = OrderProperty_OrderStopLoss(Magic4);
         double mag5_sl = OrderProperty_OrderStopLoss(Magic5);
         double mag6_sl = OrderProperty_OrderStopLoss(Magic6);
         double mag7_sl = OrderProperty_OrderStopLoss(Magic7);
         double mag8_sl = OrderProperty_OrderStopLoss(Magic8);
         double mag9_sl = OrderProperty_OrderStopLoss(Magic9);
         double mag10_sl = OrderProperty_OrderStopLoss(Magic10);
         double mag11_sl = OrderProperty_OrderStopLoss(Magic11);
         double mag12_sl = OrderProperty_OrderStopLoss(Magic12);
         double mag13_sl = OrderProperty_OrderStopLoss(Magic13);
         double mag14_sl = OrderProperty_OrderStopLoss(Magic14);
         
         if(dir==OP_BUY) {
            if(Count1>0 && (mag1_sl==0 || mag1_sl<SL)) ModifyStopLoss(Magic1,SL);
            if(Count2>0 && (mag2_sl==0 || mag2_sl<SL)) ModifyStopLoss(Magic2,SL);
            if(Count3>0 && (mag3_sl==0 || mag3_sl<SL)) ModifyStopLoss(Magic3,SL);
            if(Count4>0 && (mag4_sl==0 || mag4_sl<SL)) ModifyStopLoss(Magic4,SL);
            if(Count5>0 && (mag5_sl==0 || mag5_sl<SL)) ModifyStopLoss(Magic5,SL);
            if(Count6>0 && (mag6_sl==0 || mag6_sl<SL)) ModifyStopLoss(Magic6,SL);
            if(Count7>0 && (mag7_sl==0 || mag7_sl<SL)) ModifyStopLoss(Magic7,SL);
            if(Count8>0 && (mag8_sl==0 || mag8_sl<SL)) ModifyStopLoss(Magic8,SL);
            if(Count9>0 && (mag9_sl==0 || mag9_sl<SL)) ModifyStopLoss(Magic9,SL);
            if(Count10>0 && (mag10_sl==0 || mag10_sl<SL)) ModifyStopLoss(Magic10,SL);
            if(Count11>0 && (mag11_sl==0 || mag11_sl<SL)) ModifyStopLoss(Magic11,SL);
            if(Count12>0 && (mag12_sl==0 || mag12_sl<SL)) ModifyStopLoss(Magic12,SL);
            if(Count13>0 && (mag13_sl==0 || mag13_sl<SL)) ModifyStopLoss(Magic13,SL);
            if(Count14>0 && (mag14_sl==0 || mag14_sl<SL)) ModifyStopLoss(Magic14,SL);
         }
         else if(dir==OP_SELL) {
            if(Count1>0 && (mag1_sl==0 || mag1_sl>SL)) ModifyStopLoss(Magic1,SL);
            if(Count2>0 && (mag2_sl==0 || mag2_sl>SL)) ModifyStopLoss(Magic2,SL);
            if(Count3>0 && (mag3_sl==0 || mag3_sl>SL)) ModifyStopLoss(Magic3,SL);
            if(Count4>0 && (mag4_sl==0 || mag4_sl>SL)) ModifyStopLoss(Magic4,SL);
            if(Count5>0 && (mag5_sl==0 || mag5_sl>SL)) ModifyStopLoss(Magic5,SL);
            if(Count6>0 && (mag6_sl==0 || mag6_sl>SL)) ModifyStopLoss(Magic6,SL);
            if(Count7>0 && (mag7_sl==0 || mag7_sl>SL)) ModifyStopLoss(Magic7,SL);
            if(Count8>0 && (mag8_sl==0 || mag8_sl>SL)) ModifyStopLoss(Magic8,SL);
            if(Count9>0 && (mag9_sl==0 || mag9_sl>SL)) ModifyStopLoss(Magic9,SL);
            if(Count10>0 && (mag10_sl==0 || mag10_sl>SL)) ModifyStopLoss(Magic10,SL);
            if(Count11>0 && (mag11_sl==0 || mag11_sl>SL)) ModifyStopLoss(Magic11,SL);
            if(Count12>0 && (mag12_sl==0 || mag12_sl>SL)) ModifyStopLoss(Magic12,SL);
            if(Count13>0 && (mag13_sl==0 || mag13_sl>SL)) ModifyStopLoss(Magic13,SL);
            if(Count14>0 && (mag14_sl==0 || mag14_sl>SL)) ModifyStopLoss(Magic14,SL);
         }      
      }
   }
}

double MartingaleLot(double multiplier){
   double step = Market_LotStep;
   double startlot = Market_MinLot;
   if(CountPosition(MagicEntry)>0) startlot = OrderProperty_OrderLot(MagicEntry);
   double rawlot = startlot*pow(multiplier,TotalPosition);
   return round(rawlot/step)*step;
}

bool PrevOrderChk_Dist(int magic, int distance){
   bool     OpenNewOrder   = false;
   double   ChkLevel       = 0;

   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);  
      if(select && OrderMagicNumber()==magic && OrderSymbol()==_Symbol && OrderType()<2){
         double step = NumToPoint(distance);
         RefreshRates();
         if(OrderType() == OP_SELL){
            ChkLevel = OrderOpenPrice() + step;        
            if(Bid>ChkLevel) OpenNewOrder = true;
         }
         else if(OrderType() == OP_BUY){
            ChkLevel = OrderOpenPrice() - step; 
            if(Ask<ChkLevel) OpenNewOrder = true;
         }
      }
   }
   return OpenNewOrder;
}

void SequenceOrder(int type, int OrderMagic, int PrevMagic, int FutMagic, int distance){
   if(CountPosition(OrderMagic)==0 && CountPosition(FutMagic)==0 && CountPosition(PrevMagic)>0 && PrevOrderChk_Dist(PrevMagic,distance)) {
     string SequenceComment = Market_Symbol+" - "+string(int(TotalPosition+1))+" "; 
     OpenOrder(type,OrderMagic,NextLot(),SequenceComment);
   }
}

void System_SequenceOrder(int type){
   SequenceOrder(type,Magic14,Magic13,Magic15,20);
   SequenceOrder(type,Magic13,Magic12,Magic14,GridDistance);
   SequenceOrder(type,Magic12,Magic11,Magic13,GridDistance);
   SequenceOrder(type,Magic11,Magic10,Magic12,10);
   SequenceOrder(type,Magic10,Magic9,Magic11,10);
   SequenceOrder(type,Magic9,Magic8,Magic10,GridDistance);
   SequenceOrder(type,Magic8,Magic7,Magic9,GridDistance);
   SequenceOrder(type,Magic7,Magic6,Magic8,10);
   SequenceOrder(type,Magic6,Magic5,Magic7,10);
   SequenceOrder(type,Magic5,Magic4,Magic6,GridDistance);
   SequenceOrder(type,Magic4,Magic3,Magic5,GridDistance);
   SequenceOrder(type,Magic3,Magic2,Magic4,10);
   SequenceOrder(type,Magic2,Magic1,Magic3,10);
   SequenceOrder(type,Magic1,MagicEntry,Magic2,10);
}

double NextLot(){
   double UseLot = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);
      if(select && OrderSymbol()==_Symbol && TotalPosition>0) UseLot = MartingaleLot(Multiplier);
   }
   return UseLot;
}

void AllOrderProperty(double& sumlot, int& pos)
{
   int count = 0;
   double lot = 0;
   
   if(CountPosition(MagicEntry)>0){
      lot+=CountLot(MagicEntry);
      count++;
   }
   if(CountPosition(Magic1)>0){
      lot+=CountLot(Magic1);
      count++;
   }
   if(CountPosition(Magic2)>0){
      lot+=CountLot(Magic2);
      count++;
   }
   if(CountPosition(Magic3)>0){
      lot+=CountLot(Magic3);
      count++;
   }
   if(CountPosition(Magic4)>0){
      lot+=CountLot(Magic4);
      count++;
   }
   if(CountPosition(Magic5)>0){
      lot+=CountLot(Magic5);
      count++;
   }
   if(CountPosition(Magic6)>0){
      lot+=CountLot(Magic6);
      count++;
   }
   if(CountPosition(Magic7)>0){
      lot+=CountLot(Magic7);
      count++;
   }
   if(CountPosition(Magic8)>0){
      lot+=CountLot(Magic8);
      count++;
   }
   if(CountPosition(Magic9)>0){
      lot+=CountLot(Magic9);
      count++;
   }
   if(CountPosition(Magic10)>0){
      lot+=CountLot(Magic10);
      count++;
   }
   if(CountPosition(Magic11)>0){
      lot+=CountLot(Magic11);
      count++;
   }
   if(CountPosition(Magic12)>0){
      lot+=CountLot(Magic12);
      count++;
   }
   if(CountPosition(Magic13)>0){
      lot+=CountLot(Magic13);
      count++;
   }
   if(CountPosition(Magic14)>0){
      lot+=CountLot(Magic14);
      count++;
   }
   pos = count;
   sumlot = lot;
}

double AveragingPrice() {
   double x = 0;
   double total = 0;
   for(int order = 0; order < OrdersTotal(); order++){
      bool select = OrderSelect(order,SELECT_BY_POS);   
      if(select && OrderSymbol()==_Symbol && OrderType()<2) {
         x += OrderOpenPrice()*OrderLots();
      }
   }
   
   double totallot = CurrentOrderLot(OP_BUY)+CurrentOrderLot(OP_SELL);
   if(totallot>0) total = x/totallot;
   return NormPrice(total);
}

double CurrentOrderLot(int direction) {
   double x = 0;
   for(int order = 0; order < OrdersTotal(); order++){
      bool select = OrderSelect(order,SELECT_BY_POS);   
      if(select && OrderSymbol()==_Symbol && OrderType()==direction) x += OrderLots();  
   }
   return x;
}

bool MartingaleClose() {
   bool x = false;
   if(CountPosition(MagicEntry)>0) {
      int dir = OrderProperty_OrderType(MagicEntry);
      int marticlose = TrendClose();
      int macdClose = MACD(PERIOD_H1);
      double avg = AveragingPrice();
      double martProfit = NumToPoint(40);
      
      if(dir==OP_BUY && Bid>(avg+martProfit) && (marticlose==OP_SELL || macdClose==OP_SELL)) x = true;
      else if(dir==OP_SELL && Ask<(avg-martProfit) && (marticlose==OP_BUY || macdClose==OP_BUY)) x = true;
   }
   return x;
}

string ProperDigit(int value) {
   string ret = IntegerToString(value);
   if(value<10) ret = StringConcatenate("0",value);
   return ret;
}

string DirectoryMonthYear(datetime time) {
   int month = TimeMonth(time);
   int year = TimeYear(time);
   
   string x = "";
   switch(month){      
      case 1: x = "JAN"; break;
      case 2: x = "FEB"; break;
      case 3: x = "MAR"; break;
      case 4: x = "APR"; break;
      case 5: x = "MAY"; break;
      case 6: x = "JUN"; break;
      case 7: x = "JUL"; break;
      case 8: x = "AUG"; break;
      case 9: x = "SEP"; break;
      case 10: x = "OCT"; break;
      case 11: x = "NOV"; break;
      default: x = "DEC";
   }
   return x+"-"+string(year);
}

void ScreenShot(string directory = "TradeScreenshot") {
   if(!IsTesting()) {
      long width = ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);   // Chart's width
      long heigh = ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);  // Chart's hight
      
      // Assign name
      string explicitdirectory = directory+"/"+DirectoryMonthYear(TimeCurrent())+"/"+Market_Symbol;
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

string TimeStamp() {
   datetime Now = iTime(_Symbol,PERIOD_M1,0);
   int year = TimeYear(Now);
   int month = TimeMonth(Now);
   int day = TimeDay(Now);
   int hour = TimeHour(Now);
   int min = TimeMinute(Now);
   return StringConcatenate(year,ProperDigit(month),ProperDigit(day),ProperDigit(hour),ProperDigit(min));
}