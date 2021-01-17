/**
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_Gator_Params_M5 : GatorParams {
  Indi_Gator_Params_M5() : GatorParams(indi_gator_defaults, PERIOD_M5) {
    applied_price = (ENUM_APPLIED_PRICE)0;
    ma_method = (ENUM_MA_METHOD)0;
    period_jaw = 4;
    period_lips = 4;
    period_teeth = 4;
    shift = 0;
    shift_jaw = 0;
    shift_lips = 0;
    shift_teeth = 0;
  }
} indi_gator_m5;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_Gator_Params_M5 : StgParams {
  // Struct constructor.
  Stg_Gator_Params_M5() : StgParams(stg_gator_defaults) {
    lot_size = 0;
    signal_open_method = 0;
    signal_open_filter = 1;
    signal_open_level = (float)0.0;
    signal_open_boost = 0;
    signal_close_method = 0;
    signal_close_level = (float)0;
    price_stop_method = 0;
    price_stop_level = (float)1;
    tick_filter_method = 1;
    max_spread = 0;
  }
} stg_gator_m5;
