import bigi.{type BigInt}
import gleam/int
import gleam/result
import gleam/string

pub opaque type BigDecimal {
  BigDecimal(
    // unscaled value
    BigInt,
    // scale
    Int,
  )
}

pub fn unscaled_value(value: BigDecimal) {
  let BigDecimal(unscaled_value, ..) = value
  unscaled_value
}

pub fn scale(value: BigDecimal) {
  let BigDecimal(_, scale, ..) = value
  scale
}

pub fn from_string(value: String) -> Result(BigDecimal, Nil) {
  parse_exponential(value)
}

fn parse_exponential(value: String) -> Result(BigDecimal, Nil) {
  let value = value |> string.trim |> string.lowercase
  case value |> string.split_once("e") {
    Ok(#(number, exponent)) ->
      int.parse(exponent)
      |> result.map(int.negate)
      |> result.try(parse_decimal(number, _))

    Error(_) -> parse_decimal(value, 0)
  }
}

fn parse_decimal(value: String, initial_scale: Int) -> Result(BigDecimal, Nil) {
  case value |> string.split_once(".") {
    Ok(#(before, after)) ->
      parse_unscaled(before <> after, string.byte_size(after) + initial_scale)

    Error(_) -> parse_unscaled(value, initial_scale)
  }
}

fn parse_unscaled(value: String, scale: Int) -> Result(BigDecimal, Nil) {
  bigi.from_string(value)
  |> result.map(BigDecimal(_, scale))
}
