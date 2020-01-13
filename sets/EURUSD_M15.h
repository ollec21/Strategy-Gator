//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_Gator_EURUSD_M15_Params : Stg_Gator_Params {
  Stg_Gator_EURUSD_M15_Params() {
    symbol = "EURUSD";
    tf = PERIOD_M15;
    Gator_Period = 2;
    Gator_Applied_Price = 3;
    Gator_Shift = 0;
    Gator_SignalOpenMethod = -63;
    Gator_SignalOpenLevel = 36;
    Gator_SignalCloseMethod = 1;
    Gator_SignalCloseLevel = 36;
    Gator_PriceLimitMethod = 0;
    Gator_PriceLimitLevel = 0;
    Gator_MaxSpread = 4;
  }
};
