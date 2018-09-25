//+------------------------------------------------------------------+
//| Magnified Market Price.mq4        ver1.4             by Habeeb   |
//+------------------------------------------------------------------+

#property indicator_chart_window

  extern string note1 = "Change font colors automatically? True = Yes";
  extern bool   Bid_Ask_Colors = True;
  extern string note2 = "Default Font Color";
  extern color  FontColor = Black;
  extern string note3 = "Font Size";
  extern int    FontSize=24;
  extern string note4 = "Font Type";
  extern string FontType="Comic Sans MS";
  extern string note5 = "Display the price in what corner?";
  extern string note6 = "Upper left=0; Upper right=1";
  extern string note7 = "Lower left=2; Lower right=3";
  extern int    WhatCorner=2;

  double    Old_Price;
  string    ObjIdentifier  = "PDX_";

int init(){
   return(0);
}

int deinit(){
   ObjectDelete("Market_Price_Label"); 
   ObjectDelete("PnL"); 
   ObjectDelete("LotDisplay");
   ObjectDelete("AvgPrice");
   ObjectDeleteAll();
   return(0);
}

int start(){
   if (Bid_Ask_Colors == True){
      if (Bid > Old_Price) FontColor = LawnGreen;
      if (Bid < Old_Price) FontColor = Red;
      Old_Price = Bid;
   }
   
   string spread = IntegerToString(int(MarketInfo(_Symbol,MODE_SPREAD)));
   string Market_Price = DoubleToStr(Bid, Digits);
   string display = StringConcatenate(Market_Price," (",spread,")");
   int rou = 2;
   color pnq = clrWheat;
   color base = clrWheat;
   double pnl_data = OrderProperty_OrderPL();
   if(pnl_data==0) rou = 0;
   else if(pnl_data>0) pnq = C'102,184,149';
   else if(pnl_data<0) pnq = C'214,87,95';
   string pnl = StringConcatenate("$",DoubleToString(OrderProperty_OrderPL(),rou));
   string lotdis = StringConcatenate("Buy Lot: ",CurrentOrderLot(OP_BUY),"  ||  Sell Lot: ",CurrentOrderLot(OP_SELL));
   string avgp = StringConcatenate("Avg Entry: ",DoubleToString(AveragingPrice(),_Digits));
   
   displayinfo("Market_Price_Label",display,20,5,FontSize,base);
   if(pnl_data!=0) {
      displayinfo("PnL",pnl,20,180,26,pnq);
      displayinfo("LotDisplay",lotdis,20,155,10,pnq);
      displayinfo("AvgPrice",avgp,20,100,15,pnq);
   }
   else {
      ObjectDelete("PnL"); 
      ObjectDelete("LotDisplay");
      ObjectDelete("AvgPrice");
   }
  
   return (0);
}

void ObjectDeleteAll()
{
   Comment("");
   ObjectsDeleteAll(0,ObjIdentifier);
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

double NormDollar(double Dollar) {
   return round(Dollar/0.01)*0.01;
}

double NormPrice(double price) {
   double ticksize = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   return round(price/ticksize)*ticksize;
}

double CurrentOrderLot(int direction) {
   double x = 0;
   for(int order = 0; order < OrdersTotal(); order++){
      bool select = OrderSelect(order,SELECT_BY_POS);   
      if(select && OrderSymbol()==_Symbol && OrderType()==direction) x += OrderLots();  
   }
   return x;
}

void displayinfo(string label,string displayitem, int x, int y, int size, color col) {
   ObjectCreate(label, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(label, displayitem, size, FontType, col);
   ObjectSet(label, OBJPROP_CORNER, 2);
   ObjectSet(label, OBJPROP_XDISTANCE, x);
   ObjectSet(label, OBJPROP_YDISTANCE, y);
}