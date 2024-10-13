pub type RoundingMode {
  /// Round towards positive infinity
  Ceiling

  /// Round towards negative infinity
  Floor

  /// Round towards zero
  Down

  /// Round away from zero
  Up

  /// Round towards nearest neighbour. Round down if both neighbours are equidistant.
  HalfDown

  /// Round towards nearest neighbour. Round up if both neighbours are equidistant.
  HalfUp

  /// Round towards nearest neighbour. Round to the even one if both neighbours are equidistant.
  HalfEven
}
