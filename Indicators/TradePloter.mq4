//+------------------------------------------------------------------------------------+
//|   Coder             : hairibaba                                                    |
//|   Coder's Telegram  : @hairibaba (Telegram ID)                                     |
//|   Coder's email     : zulhairibaba@gmail.com                                       |
//|   Coder's mql site  : https://www.mql5.com/en/users/hairi                          |
//|   Coder's location  : Kuala Lumpur, Malaysia (GMT+8)                               |
//|------------------------------------------------------------------------------------|
//|   Development copyright © 2012-2018 of hairibaba.                                  |
//|------------------------------------------------------------------------------------|
//|   ChangeLog:                                                                       |
//|   Release date : xx-xxx-xxxx                                                       |
//|                                                                                    |
//+------------------------------------------------------------------------------------+

#property copyright     "Coded by hairibaba © 2018"
#property link          "https://www.mql5.com/en/users/hairi"
#property description   "Trade Ploter"
#property version       "1.00"
#property strict
#property indicator_chart_window

// --- Input Variable ------------------------------------------------------------------
input color Color_Long  = clrAqua,
            Color_Shot  = clrTomato;

// --- Global Variable ------------------------------------------------------------------
string   ObjIdentifier     = "PLT_",
         profitloss        = "";
int      ObjTotal_Current,ObjTotal_History;

int OnInit(){
   return(INIT_SUCCEEDED);
}
  
void OnDeinit(const int reason){
   ObjectDeleteAll(); //--- Delete All Drawings
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]){
//---
   if(Bars(_Symbol,_Period)<rates_total) return(0);
   
   ObjTotal_Current = OrdersTotal();
   ObjTotal_History = OrdersHistoryTotal();
   
   // Plot History Trade
   for(int i=ObjTotal_History; i>0; i--){
      bool select = OrderSelect(i, SELECT_BY_POS, MODE_HISTORY);
      if(select && OrderSymbol()==_Symbol){
         if(OrderType()==OP_BUY) {
            profitloss = IntegerToString(PointToInt(OrderClosePrice()-OrderOpenPrice()))+" point.";
            PlotTradeHistory(OrderTicket(),OrderType(),profitloss,OrderOpenTime(),OrderCloseTime(),OrderOpenPrice(),OrderClosePrice(),Color_Long,1);
         }
         if(OrderType()==OP_SELL) {
            profitloss = IntegerToString(PointToInt(OrderOpenPrice()-OrderClosePrice()))+" point.";
            PlotTradeHistory(OrderTicket(),OrderType(),profitloss,OrderOpenTime(),OrderCloseTime(),OrderOpenPrice(),OrderClosePrice(),Color_Shot,1);
         }
      }
   }
   for(int i=ObjTotal_Current; i>0; i--){
      bool select = OrderSelect(i, SELECT_BY_POS);
      if(select && OrderSymbol()==_Symbol){
         if(OrderType()==OP_BUY) {
            profitloss = "";
            PlotTradeHistory(OrderTicket(),OrderType(),profitloss,OrderOpenTime(),OrderCloseTime(),OrderOpenPrice(),OrderClosePrice(),Color_Long);
         }
         if(OrderType()==OP_SELL) {
            profitloss = "";
            PlotTradeHistory(OrderTicket(),OrderType(),profitloss,OrderOpenTime(),OrderCloseTime(),OrderOpenPrice(),OrderClosePrice(),Color_Shot);
         }
      }
   }   
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

int PointToInt (double point){
   return int(point/_Point);
}

void ObjectDeleteAll(){
   Comment("");
   ObjectsDeleteAll(0,ObjIdentifier);
}

void ObjectDrawDelete(string name){
   ObjectDelete(0,ObjIdentifier+name);
}

void PlotTradeHistory(long ticket, int type, string pProfitloss, datetime open, datetime close, double priceopen, double priceclose, color linecolor, int plot = 0){

   string ord = "";
   if(type==OP_BUY) ord = "Buy";
   else if(type==OP_SELL) ord = "Sell";
   else if(type==OP_BUYLIMIT) ord = "Buy Limit";
   else if(type==OP_BUYSTOP) ord = "Buy Stop";
   else if(type==OP_SELLLIMIT) ord = "Sell Limit";
   else if(type==OP_SELLSTOP) ord = "Sell Stop";
   
   string thistix = IntegerToString(ticket);
   string string1 = ObjIdentifier+"# "+thistix+" : Open at "+TimeToStr(open,TIME_MINUTES);
   if (ObjectFind(0,string1) == 0) {
      ObjectCreate(0,string1,OBJ_ARROW,0,open,priceopen);
      ObjectSetInteger(0,string1,6, linecolor);
      ObjectSetInteger(0,string1,14,1);
      ObjectSetInteger(0,string1,OBJPROP_HIDDEN,true);
      SetIndexLabel(0,NULL);
   }
   
   if(plot==1) {
      string string2 = ObjIdentifier+"# "+thistix+" : Close at "+TimeToStr(close,TIME_MINUTES);
      ObjectCreate(0,string2,OBJ_ARROW,0,close,priceclose);
      ObjectSetInteger(0,string2,6, linecolor);
      ObjectSetInteger(0,string2,14,3);
      ObjectSetInteger(0,string2,OBJPROP_HIDDEN,true);
      SetIndexLabel(0,NULL);
      
      string string3 = ObjIdentifier+"# "+thistix+" : "+profitloss;
      ObjectCreate(0,string3, OBJ_TREND, 0, open,priceopen,close,priceclose);
      ObjectSetInteger(0,string3,6,linecolor);
      ObjectSetInteger(0,string3,7,2);
      ObjectSetInteger(0,string3,10,false);
      ObjectSetInteger(0,string3,OBJPROP_HIDDEN,true);
      SetIndexLabel(0,NULL);
   }
}