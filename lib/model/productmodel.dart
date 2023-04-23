class Product {
  final String productId;
  final String productTitle;
  final String productPrice;
  late String barcodeId;
  late bool completed;
  final String userId;

  Product({
    required this.productId,
    required this.productTitle,
    required this.productPrice,
    required this.barcodeId,
    required this.completed,
    required this.userId,
  });

  Product copyWith({
    String? productId,
    String? productTitle,
    String? productPrice,
    String? barcodeId,
    bool? completed,
    String? userId,
  }) {
    return Product(
      productId: productId ?? this.productId,
      productTitle: productTitle ?? this.productTitle,
      productPrice: productPrice ?? this.productPrice,
      completed: completed ?? this.completed,
      userId: userId ?? this.userId,
      barcodeId: barcodeId ?? this.barcodeId,
    );
  }
}
