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
#property description   "Modified All TakeProfit Script"
#property script_show_inputs
#property strict

#define MAX_RETRIES        2
#define RETRY_SECONDS      2

#import "stdlib.ex4"
string ErrorDescription(int error_code);
#import

enum orderselect {
   None,
   Buy,
   Sell
};

enum ordertype {
   Both,
   Market,
   Pending
};

// Input Variable ------------------------------------------------------------------
input double      Target      = 1.3456;
input orderselect WhichOrder  = None;
input ordertype   TradeType   = Both;

// Global Variable ------------------------------------------------------------------  
int OnInit(){
   if(!InitFailed()) return INIT_FAILED;
   return(INIT_SUCCEEDED);
}

void OnStart() {     
   int x = 100;
   
   ServerCheck();
   if(WhichOrder==Buy) {
      if(TradeType==Market) ModifyTakeProfit(OP_BUY,Target);
      else if(TradeType==Pending) {
         ModifyTakeProfit(OP_BUYLIMIT,Target);
         ModifyTakeProfit(OP_BUYSTOP,Target);
      }
      else {
         ModifyTakeProfit(OP_BUY,Target);
         ModifyTakeProfit(OP_BUYLIMIT,Target);
         ModifyTakeProfit(OP_BUYSTOP,Target);
      }
   }
   else if(WhichOrder==Sell) {
      if(TradeType==Market) ModifyTakeProfit(OP_SELL,Target);
      else if(TradeType==Pending) {
         ModifyTakeProfit(OP_SELLLIMIT,Target);
         ModifyTakeProfit(OP_SELLSTOP,Target);
      }
      else {
         ModifyTakeProfit(OP_SELL,Target);
         ModifyTakeProfit(OP_SELLLIMIT,Target);
         ModifyTakeProfit(OP_SELLSTOP,Target);
      }
   }
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

int OrderAllSymbol(){
   int count = 0;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      if(SymbolAll(order)) {
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

bool SymbolAll(int i, int mode = MODE_TRADES){
   return (OrderSelect(i,SELECT_BY_POS, mode) && OrderSymbol() == _Symbol);
}

void ModifyTakeProfit(int type, double pPriceTP) { 
   if(OrderAllSymbol()>0) {
      for(int order = OrdersTotal()-1; order >= 0; order--){
         if(SymbolAll(order) && OrderType()==type) {
            double NormTP = NormPrice(pPriceTP);
            RefreshRates();
            MqlTick tick;
            SymbolInfoTick(_Symbol,tick);
            
            bool proceed = false;
            if((type==OP_BUY || type==OP_BUYLIMIT || type==OP_BUYSTOP) && (tick.ask<NormTP || NormTP==0)) proceed = true;
            else if((type==OP_SELL || type==OP_SELLLIMIT || type==OP_SELLSTOP) && (tick.bid>NormTP || NormTP==0)) proceed = true;
            
            
            if(proceed && AcceptableDifference(OrderTakeProfit(),NormTP) && StopLevel(NormTP)){
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
               if(!modify) ModifyError(OrderTicket());
            } 
         }
      }
   }
}

void ModifyError(int ticket){
   int Acc_Login   = int(AccountInfoInteger(ACCOUNT_LOGIN));
   string NewLine = "\n", sInput  = "%s", space = " ";
   string output_string = StringConcatenate("Acc #%d - Symbol : ",sInput,space,
                                             NewLine,"Order ticket #%d modify failed!",space,
                                             NewLine,"Reason : ",sInput
                                           );
   string msg = StringFormat(output_string,Acc_Login,_Symbol,ticket,ErrorDescription(GetLastError()));
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


bool AcceptableDifference(double price, double pricecompare) {
   double buffer = NumToPoint(2);
   double range_u = pricecompare+buffer,
          range_b = pricecompare-buffer;
   if(price==pricecompare || (price<range_u && price>range_b)) return false;
   else return true;
}


bool StopLevel(double pPrice) {
   double Market_StopLevel     = NumToPoint(MarketInfo(_Symbol,MODE_STOPLEVEL));
   double Market_FreezeLevel   = NumToPoint(MarketInfo(_Symbol,MODE_FREEZELEVEL));
   double Market_StopFreeze    = fmax(Market_StopLevel,Market_FreezeLevel);
   RefreshRates();
   MqlTick tick;
   SymbolInfoTick(_Symbol,tick);
   double uppermargin = tick.ask + Market_StopFreeze;
   double lowermargin = tick.bid - Market_StopFreeze;
   if(pPrice<=uppermargin && pPrice>=lowermargin) return false;
   else return true;
}

double NormPrice(double price) {
   double ticksize = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   return Round(price,ticksize);
}

void ServerCheck(){
   if(LiveOperation()) {
      while(!TerminalInfoInteger(TERMINAL_CONNECTED) || IsTradeContextBusy() || !RefreshRates()) Sleep(1);
   }
   else RefreshRates();
}

bool LiveOperation() {
   return !(MQLInfoInteger(MQL_TESTER) || MQLInfoInteger(MQL_VISUAL_MODE));
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

double RoundUp(double value, double rounding) {
   return ceil(value/rounding)*rounding;
}

double RoundDn(double value, double rounding) {
   return floor(value/rounding)*rounding;
}

double Round(double value, double rounding) {
   return round(value/rounding)*rounding;
}