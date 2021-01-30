/*
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_Gator_Params_M30 : GatorParams {
  Indi_Gator_Params_M30() : GatorParams(indi_gator_defaults, PERIOD_M30) {
    applied_price = (ENUM_APPLIED_PRICE)3;
    jaw_period = 17;
    jaw_shift = 10;
    teeth_period = 8;
    teeth_shift = 7;
    lips_period = 7;
    lips_shift = 3;
    ma_method = (ENUM_MA_METHOD)2;
    shift = 0;
  }
} indi_gator_m30;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_Gator_Params_M30 : StgParams {
  // Struct constructor.
  Stg_Gator_Params_M30() : StgParams(stg_gator_defaults) {
    lot_size = 0;
    signal_open_method = 0;
    signal_open_filter = 1;
    signal_open_level = (float)0;
    signal_open_boost = 0;
    signal_close_method = 0;
    signal_close_level = (float)0;
    price_stop_method = 0;
    price_stop_level = (float)2;
    tick_filter_method = 1;
    max_spread = 0;
  }
} stg_gator_m30;
