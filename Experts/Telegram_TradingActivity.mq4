//+------------------------------------------------------------------------------------+
//|   Coder             : hairibaba                                                    |
//|   Coder's contact   : +60123337356 (Whatsapp)                                      |
//|   Coder's email     : zulhairibaba@gmail.com                                       |
//|   Coder's skype     : hairibaba@outlook.com                                        |
//|   Coder's mql site  : https://www.mql5.com/en/users/hairi                          |
//|   Coder's location  : Kuala Lumpur, Malaysia (GMT+8)                               |
//|   Code release date : xx-xxx-xxxx                                                  |
//|                                                                                    |
//|   Development copyright © 2015-2018 of hairibaba.                                  |
//+------------------------------------------------------------------------------------+

#property copyright     "Coded by hairibaba © 2018"
#property link          "https://www.mql5.com/en/users/hairi"
#property version       "1.0"
#property description   "Trading Activity"
#property strict

#include <Telegram.mqh>
        
// --- System Global Variable -----------------------------------------------------------  
string InpChannelName   = "xtvttrade";                                   // Channel Name
string InpToken         = "642613283:AAE6xHirZLBUAt-Nlg2IWVQHTaD17wUJeUY"; // Token
string ObjIdentifier    = "EXX_"; 
CCustomBot bot;


// --- EA Operation Start ---------------------------------------------------------------
int OnInit(){
    if(StringLen(InpChannelName)==0){
      Alert("Error: Channel name is empty");
      return INIT_FAILED;
   }
   
   int retry = 0;
   while(retry<3) {
      bot.Token(InpToken);
      int result = bot.GetMe();
      if(result!=0 && retry<3) {
         retry++;
         Sleep(5000);
      }
      else if(result==0) {
         Print("Bot name: ",bot.Name());
         break;
      }
      else {
         Alert("Error: ",GetErrorDescription(result));
         return INIT_FAILED;
      }
   }
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){
   ObjectDeleteAll(ObjIdentifier); //--- Delete All Drawings
   Print(__FILE__," uninit reason : ",getUninitReasonText(reason));
}

void OnTick(){
   int type;
   string symbol;
   double op,lot;
   
   bool NewOrder = OrderProperty(type,symbol,op,lot);
   if(NewOrder) EntrySignal(type,symbol,op,lot);
}

// --- Utilities Code -------------------------------------------------------------------
void ObjectDeleteAll(string objIdentifier) {
   Comment("");
   ObjectsDeleteAll(0,objIdentifier);
}

double bid(string pSymbol=NULL){
   if(pSymbol==NULL) pSymbol=_Symbol;
   return(SymbolInfoDouble(pSymbol,SYMBOL_BID));
}

double ask(string pSymbol=NULL){
   if(pSymbol==NULL) pSymbol=_Symbol;
   return(SymbolInfoDouble(pSymbol,SYMBOL_ASK));
}

string getUninitReasonText(int reasonCode){
   string text = "";
   switch(reasonCode){      
      case REASON_PROGRAM:       text = "Expert Advisor terminated by ExpertRemove()"; break;
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

bool OrderProperty(int& type, string& symbol, double& price, double& lot, int secAgo = 10){
   bool x = false;
   datetime rangechk = TimeCurrent()-secAgo;
   for(int order = OrdersTotal()-1; order >= 0; order--){
      bool select = OrderSelect(order,SELECT_BY_POS);   
      if(select && OrderType()<2 && OrderOpenTime()>=rangechk) {
         price = OrderOpenPrice();
         lot = OrderLots();
         symbol = OrderSymbol();
         type = OrderType();
         x = true;
         break;
      }
   }
   return x;
}

void EntrySignal(int type, string symbol, double price, double lot) {
   string signal = "SELL";
   if(type==OP_BUY) signal = "BUY";
   int rounding = _Digits;
   
   string u = StringSubstr(symbol,3,3);
   if(u=="JPY") rounding = 3;
   
   string entryprice = DoubleToString(price,rounding);
   string entrylot = DoubleToString(lot,2);
   string constructor = StringConcatenate("<strong>",signal," </strong>",entrylot," ",symbol," at ",entryprice);
   BotMsg(constructor);
}

void BotMsg(string constructor) {
   int res=bot.SendMessage(InpChannelName,constructor);
   if(res!=0) Print("Error: ",GetErrorDescription(res));
   else {
      Print("Signal Telegram sent!");
      Sleep(10000);
   }
}