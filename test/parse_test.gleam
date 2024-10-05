import bigdecimal
import bigi.{type BigInt}
import gleam/list
import gleeunit/should

pub fn basic_parse__test() {
  use #(input, expected_unscaled_value, expected_scale) <- list.each([
    // basic
    #("123.45", bigi.from_int(12_345), 2),
    #("0.123", bigi.from_int(123), 3),
    #("123.0", bigi.from_int(1230), 1),
    // leading zeros
    #("000123.45", bigi.from_int(12_345), 2),
    #("0000.12", bigi.from_int(12), 2),
    #("000.000", bigi.from_int(0), 3),
    // negative numbers
    #("-123.45", bigi.from_int(-12_345), 2),
    #("-0.123", bigi.from_int(-123), 3),
    // whitespace
    #(" 123.45 ", bigi.from_int(12_345), 2),
    #("\t 123.45 \r\n", bigi.from_int(12_345), 2),
    // zeros
    #("0", bigi.from_int(0), 0),
    #("0.0", bigi.from_int(0), 1),
    #("-0.0", bigi.from_int(0), 1),
    // trailing/leading decimal point
    #("123.", bigi.from_int(123), 0),
    #("-456.", bigi.from_int(-456), 0),
    #(".789", bigi.from_int(789), 3),
    #("-.123", bigi.from_int(-123), 3),
    // explicit plus sign
    #("+123", bigi.from_int(123), 0),
    #("+123.4", bigi.from_int(1234), 1),
  ])

  common_parse_assertions(input, expected_unscaled_value, expected_scale)
}

pub fn extreme_parse__test() {
  use #(input, expected_unscaled_value, expected_scale) <- list.each([
    #(
      "123456789123456789123456789.123456789",
      bigi.from_string("123456789123456789123456789123456789"),
      9,
    ),
    #(
      "-123456789123456789123456789.123456789",
      bigi.from_string("-123456789123456789123456789123456789"),
      9,
    ),
    #(
      "0.00000000123456789123456789123456789123456789",
      bigi.from_string("123456789123456789123456789123456789"),
      44,
    ),
    #(
      "-0.00000000123456789123456789123456789123456789",
      bigi.from_string("-123456789123456789123456789123456789"),
      44,
    ),
  ])

  let assert Ok(expected_unscaled_value) = expected_unscaled_value
  common_parse_assertions(input, expected_unscaled_value, expected_scale)
}

pub fn scientific_notation_parse__test() {
  use #(input, expected_unscaled_value, expected_scale) <- list.each([
    #("1.23E3", bigi.from_string("123"), -1),
    #("4.56E-7", bigi.from_string("456"), 9),
    #("-7.89E9", bigi.from_string("-789"), -7),
    #("1E-32", bigi.from_string("1"), 32),
    #("+1.23e3", bigi.from_string("123"), -1),
    #("4.56e-7", bigi.from_string("456"), 9),
    #("-7.89e9", bigi.from_string("-789"), -7),
    #("-1e32", bigi.from_string("-1"), -32),
  ])

  let assert Ok(expected_unscaled_value) = expected_unscaled_value
  common_parse_assertions(input, expected_unscaled_value, expected_scale)
}

pub fn parse_fail__test() {
  use input <- list.each([
    "123 .45", "123. 45", "123x", "NaN", "Infinity", "1,234.5", "12.34.56",
    "12e3e4",
  ])

  bigdecimal.from_string(input)
  |> should.be_error
}

fn common_parse_assertions(
  input: String,
  expected_unscaled_value: BigInt,
  expected_scale: Int,
) {
  let bigd =
    bigdecimal.from_string(input)
    |> should.be_ok

  bigd
  |> bigdecimal.unscaled_value
  |> should.equal(expected_unscaled_value)

  bigd
  |> bigdecimal.scale
  |> should.equal(expected_scale)
}
