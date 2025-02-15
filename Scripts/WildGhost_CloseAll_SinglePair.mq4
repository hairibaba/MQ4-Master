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
#property script_show_inputs
#property strict

#import "stdlib.ex4"
string ErrorDescription(int error_code);
#import

#define SLIPPAGE        15
#define RETRY_DELAY     2000
#define MAX_RETRIES     3
#define RETRY_SECONDS   2

int OnInit(){
   if(!InitFailed()) return INIT_FAILED;
   return(INIT_SUCCEEDED);
}

void OnStart(){
   int proceed = MessageBox("Close All Order (This Pair)?","Confirmation",MB_YESNO|MB_ICONQUESTION);
   if(proceed==IDYES) {
      ServerCheck();
      CloseAllOrder_Symbol_NonFIFO();
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

bool LiveOperation() {
   return !(MQLInfoInteger(MQL_TESTER) || MQLInfoInteger(MQL_VISUAL_MODE));
}

void ServerCheck(){
   if(LiveOperation()) {
      while(!TerminalInfoInteger(TERMINAL_CONNECTED) || IsTradeContextBusy() || !RefreshRates()) Sleep(1);
   }
   else RefreshRates();
}

bool CloseAll_Symbol_NonFIFO() {
   int ticket = -1;
   int magic = -1;
   datetime open_time = -1;
   bool haveSLTP = false;
   
   for(int order = OrdersTotal()-1; order >= 0; order--) {
      if(SymbolTrade(order) && OrderOpenTime()>open_time) ticket = OrderTicket();
   }
   
   if(ticket!=-1) {
      DeleteSLTPTrade();
      if(OrderSelect(ticket, SELECT_BY_TICKET)) {
         int retry = 0;
         bool closeorder = false;
         while(retry <= MAX_RETRIES) {
            ServerCheck();
            closeorder = OrderClose(ticket,OrderLots(),OrderClosePrice(),SLIPPAGE,clrRed);
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

void CloseAllOrder_Symbol_NonFIFO() {
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

void DeleteSLTPTrade() { 
   for(int order = OrdersTotal()-1; order >= 0; order--){ 
      if(SymbolTrade(order) && (OrderTakeProfit()>0 || OrderStopLoss()>0)){
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

bool SymbolTrade(int i, int mode = MODE_TRADES){
   return (OrderSelect(i,SELECT_BY_POS, mode) && OrderSymbol() == _Symbol && (OrderType()==OP_BUY || OrderType()==OP_SELL));
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

void SleepSeconds(int seconds) {
   Sleep(seconds*1000);
   RefreshRates();
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