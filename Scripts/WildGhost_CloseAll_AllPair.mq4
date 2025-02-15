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
#property description   "WildGhost Close All Script"
#property strict

#import "stdlib.ex4"
string ErrorDescription(int error_code);
#import

#define SLIPPAGE     15
#define RETRY_DELAY  2000
#define MAX_RETRIES  3

int OnInit(){
   if(!InitFailed()) return INIT_FAILED;
   return(INIT_SUCCEEDED);
}

void OnStart(){
   int proceed = MessageBox("Close All Order (This Pair)?","Confirmation",MB_YESNO|MB_ICONQUESTION);
   if(proceed==IDYES) ClosingAllOrder();

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

void ClosingAllOrder(){
   for(int order = 0; order <= OrdersTotal()-1; order++){
      bool select = OrderSelect(order,SELECT_BY_POS);
      if(select && (OrderType()==OP_BUY || OrderType()==OP_SELL)){
         bool proceed = true;
         if(OrderTakeProfit()>0 && !StopLevel(OrderTakeProfit())) proceed = false;
         else if(OrderStopLoss()>0 && !StopLevel(OrderStopLoss())) proceed = false;
         // Start closing all order
         if(proceed) {
            ulong  ul=0, ul_res=0;
            ul = GetMicrosecondCount();
            int retry = 0;
            bool closeorder = false;
            while(retry <= MAX_RETRIES) {
               TickData(); // Updating Latest Tick Data
               double ClosePrice = Bid;
               if(OrderType()==OP_SELL) ClosePrice = Ask;
               closeorder = OrderClose(OrderTicket(),OrderLots(),ClosePrice,SLIPPAGE,clrRed);
               if(closeorder) {
                  ul_res = GetMicrosecondCount()-ul;
                  string ms = DoubleToString((ul_res/1000.0),2);
                  if(IsTesting()) Print("Order #",OrderTicket()," closed.");
                  else PrintFormat("Order ticket %d closed in %s ms.",OrderTicket(),ms);
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

void OrderCloseError(int ticket, string action){
   string NewLine = "\n", sInput  = "%s";
   string output_string = StringConcatenate("Acc #",sInput," - Symbol : ",sInput,
                                             NewLine,"Order ticket #",sInput," failed to ",sInput,
                                             NewLine,"Reason : ",sInput
                                           );
   int Acc_Login = int(AccountInfoInteger(ACCOUNT_LOGIN));
   string msg = StringFormat(output_string,IntegerToString(Acc_Login),_Symbol,IntegerToString(ticket),action,ErrorDescription(GetLastError()));
   NotifySetting(msg);
}

bool StopLevel(double pPrice) {
   bool x = true;
   double Market_StopLevel     = NumToPoint(MarketInfo(_Symbol,MODE_STOPLEVEL));
   double Market_FreezeLevel   = NumToPoint(MarketInfo(_Symbol,MODE_FREEZELEVEL));
   double res = fmax(Market_StopLevel,Market_FreezeLevel);
   RefreshRates();
   double uppermargin = Ask + res;
   double lowermargin = Bid - res;
   if(pPrice<=uppermargin && pPrice>=lowermargin) x = false;
   return x;
}

void NotifySetting(string msg) {
   string NewLine = "\n", sInput  = "%s";
   string output_string = StringConcatenate("[",__FILE__,"] ",NewLine,sInput);
   string acc = StringFormat(output_string,msg);
   Alert(acc);
   Print(msg);
   ResetLastError();
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

double NumToPoint(int integer) {
   return integer*_Point;
}

double NumToPoint(double dbl) {
   double x = dbl*_Point;
   string y = DoubleToString(round(x/_Point)*_Point,_Digits);
   return StringToDouble(y);
}