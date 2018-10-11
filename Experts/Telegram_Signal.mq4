//+------------------------------------------------------------------+
//|                                           Telegram_Signal_EA.mq5 |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#property strict

#include <Telegram.mqh>

//--- input parameters
input string InpChannelName="GBPUSDScalping";                           // Channel Name
input string InpToken="643900677:AAGYa11O9YzCah9rQwp_C-fgPeSpXra8M3c";  // Token

//--- global variables
CCustomBot bot;

int OnInit(){
   if(StringLen(InpChannelName)==0){
      Alert("Error: Channel name is empty");
      return INIT_FAILED;
   }
   
   bot.Token(InpToken);
   int result = bot.GetMe();
   
   if(result!=0) {
      Alert("Error: ",GetErrorDescription(result));
      return INIT_FAILED;
   }
   else Print("Bot name: ",bot.Name());
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){
   //--
}
void OnTick(){
   //EntrySignal("SELL");
   //ExitSignal("BUY");
}

bool BetweenTimeRange(datetime timeStart, datetime timeEnd) {
   datetime compare = TimeCurrent();
   return compare>=timeStart && compare<=timeEnd;
}

datetime HourMin(int pHour = 0, int pMinute = 0){
   MqlDateTime timeStruct;
   TimeToStruct(TimeCurrent(),timeStruct);
   timeStruct.hour   = pHour;
   timeStruct.min    = pMinute;
   return StructToTime(timeStruct);
}

int TickCount() {
   static int TickCount = 0;
   static datetime BarTime = 0; 
   
   if(Time[0]!=BarTime) { 
      TickCount = 0; 
      BarTime= Time[0];
   } else TickCount++;
   return TickCount;
}

bool TestSignal() {
   bool x = false;
   if(TickCount()==1 && BetweenTimeRange(HourMin(0,1),HourMin(2,55))) x = true;
   return x;
}

void EntrySignal(string signal, string symbol = NULL) {
   if(TestSignal()) {
      if(symbol==NULL) symbol=_Symbol;
      string emoji = "\x203C";
      StringToUpper(signal);
      string constructor = StringConcatenate(emoji," <strong>",signal," ",symbol," NOW </strong>",emoji,"\nServer Time: %s\nEntry Price (+-) : %s");
      
      datetime msiatime = TimeCurrent()-(19*3600);
      string time =  TimeToString(TimeCurrent())+" (Malaysia Time: "+TimeToString(msiatime,TIME_MINUTES)+")";
      
      string price = DoubleToString(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
      if(signal=="BUY") price = DoubleToString(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
      
      BotMsg(constructor,time,price);
   }
}

void ExitSignal(string signal, string symbol = NULL) {
   if(TestSignal()) {
      if(symbol==NULL) symbol=_Symbol;
      string emoji = "\xF4B0";
      StringToUpper(signal);
      string constructor = StringConcatenate(emoji,emoji," <strong>",symbol," ","CLOSE ",signal," </strong>",emoji,emoji,"\nServer Time: %s\nExit Price (+-) : %s");
      
      datetime msiatime = TimeCurrent()-(19*3600);
      string time =  TimeToString(TimeCurrent())+" (Malaysia Time: "+TimeToString(msiatime,TIME_MINUTES)+")";
      
      string price = DoubleToString(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
      if(signal=="BUY") price = DoubleToString(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
      
      BotMsg(constructor,time,price);
   }
}

void BotMsg(string constructor, string time, string price) {
   string msg=StringFormat(constructor,time,price);
   int res=bot.SendMessage(InpChannelName,msg);
   if(res!=0) Print("Error: ",GetErrorDescription(res));
   else Print("Signal Telegram sent!");
}