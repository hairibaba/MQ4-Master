
#property strict
#property indicator_chart_window

int   OT    = -1;
int   OT2   = -1;

int init() 
{
   return(0); 
}

int deinit() 
{
   int OBTotal=ObjectsTotal();
   for (int i=OBTotal; i>=0; i--) if(StringSubstr(ObjectName(i),0, 2)=="# ")ObjectDelete(ObjectName(i));
   return(0);    
}
  
int start() 
{
   int cnt, total, total2;
   total=OrdersTotal();
   total2=OrdersHistoryTotal();
   color col, ccol, linecol;
   string PL="";  
   
   if(OT==total && OT2==total2)return(0); //no change in orders to plot
     
   //Plot Orders History 
   for(cnt=0;cnt<=total2;cnt++)
   {
      bool select = OrderSelect(cnt, SELECT_BY_POS, MODE_HISTORY);
      
      if(OrderSymbol()==Symbol() && select)  // check for symbol
      {
         if(OrderType()==OP_BUY)
         { 
            col=clrBlue;
            ccol=clrBlue;
            linecol=clrBlue; 
            PL=DoubleToStr((OrderClosePrice()-OrderOpenPrice())/Point,1)+" pips";
         }

      if(OrderType()==OP_SELL)
         { 
            col=clrRed;
            ccol=clrRed;
            linecol=clrRed; 
            PL=DoubleToStr((OrderOpenPrice()-OrderClosePrice())/Point,1)+" pips";
         }
                
      if(OrderType()==OP_BUY || OrderType()==OP_SELL)
         {
            ObjectCreate("# "+IntegerToString(OrderTicket())+" : Open at "+TimeToStr(OrderOpenTime(),TIME_MINUTES),OBJ_ARROW,0,OrderOpenTime(),OrderOpenPrice());
            ObjectSet("# "+IntegerToString(OrderTicket())+" : Open at "+TimeToStr(OrderOpenTime(),TIME_MINUTES),6, col);
            ObjectSet("# "+IntegerToString(OrderTicket())+" : Open at "+TimeToStr(OrderOpenTime(),TIME_MINUTES),14,1);
                
            ObjectCreate("# "+IntegerToString(OrderTicket())+" : Close at "+TimeToStr(OrderCloseTime(),TIME_MINUTES),OBJ_ARROW,0,OrderCloseTime(),OrderClosePrice());
            ObjectSet("# "+IntegerToString(OrderTicket())+" : Close at "+TimeToStr(OrderCloseTime(),TIME_MINUTES),6, ccol);
            ObjectSet("# "+IntegerToString(OrderTicket())+" : Close at "+TimeToStr(OrderCloseTime(),TIME_MINUTES),14,3);
              
            ObjectCreate("# "+IntegerToString(OrderTicket())+" : "+PL, OBJ_TREND, 0, OrderOpenTime(),OrderOpenPrice(),OrderCloseTime(),OrderClosePrice());
            ObjectSet("# "+IntegerToString(OrderTicket())+" : "+PL,6,linecol);
            ObjectSet("# "+IntegerToString(OrderTicket())+" : "+PL,7,2);
            ObjectSet("# "+IntegerToString(OrderTicket())+" : "+PL,10,false);
            ObjectSetInteger(0,"# "+IntegerToString(OrderTicket())+" : "+PL,OBJPROP_HIDDEN,true);
         }
      }            
   }
   
   
   //Plot current orders
   for(cnt=0;cnt<=total;cnt++)
   {
      bool x = OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      
      if(OrderSymbol()==Symbol() )   // check for symbol
      {
         if(OrderType()==OP_BUY)   col=clrBlue; 
         if(OrderType()==OP_SELL)  col=clrRed; 
         
         if(OrderType()==OP_BUY ||OrderType()==OP_SELL)
         {
            ObjectCreate("# "+IntegerToString(OrderTicket())+" : Open at "+TimeToStr(OrderOpenTime(),TIME_MINUTES),OBJ_ARROW,0,OrderOpenTime(),OrderOpenPrice());
            ObjectSet("# "+IntegerToString(OrderTicket())+" : Open at "+TimeToStr(OrderOpenTime(),TIME_MINUTES),6, col);
            ObjectSet("# "+IntegerToString(OrderTicket())+" : Open at "+TimeToStr(OrderOpenTime(),TIME_MINUTES),14,1);
            ObjectSetInteger(0,"# "+IntegerToString(OrderTicket())+" : Open at "+TimeToStr(OrderOpenTime(),TIME_MINUTES),OBJPROP_HIDDEN,true);
         }
      }            
   }

    OT   = total;
    OT2  = total2;
    
   return(0);
}

