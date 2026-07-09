import 'package:meow_meow_store/core/constants/app_constants.dart';

abstract final class PriceUtils {
  static double suggestedSellingPrice(
    double buyingPrice, {
    double? markupPercent,
  }) {
    final percent = markupPercent ?? AppConstants.defaultMarkupPercent;
    return buyingPrice * (1 + percent);
  }

  static double roundToNearest(double value, {int? nearest}) {
    final n = nearest ?? AppConstants.defaultPriceRoundingNearest;
    return (value / n).ceil() * n.toDouble();
  }

  static double calculateSellingPrice(
    double buyingPrice, {
    double? markupPercent,
    int? nearest,
  }) {
    final price = suggestedSellingPrice(
      buyingPrice,
      markupPercent: markupPercent,
    );
    return roundToNearest(price, nearest: nearest);
  }
}
