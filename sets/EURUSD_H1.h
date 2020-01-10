//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_Gator_EURUSD_H1_Params : Stg_Gator_Params {
  Stg_Gator_EURUSD_H1_Params() {
    symbol = "EURUSD";
    tf = PERIOD_H1;
    Gator_Period = 2;
    Gator_Applied_Price = 3;
    Gator_Shift = 0;
    Gator_TrailingStopMethod = 6;
    Gator_TrailingProfitMethod = 11;
    Gator_SignalOpenLevel = 36;
    Gator_SignalBaseMethod = 0;
    Gator_SignalOpenMethod1 = 195;
    Gator_SignalOpenMethod2 = 0;
    Gator_SignalCloseLevel = 36;
    Gator_SignalCloseMethod1 = 1;
    Gator_SignalCloseMethod2 = 0;
    Gator_MaxSpread = 6;
  }
};
