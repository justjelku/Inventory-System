class Product {
  final String productId;
  final String productTitle;
  final String productPrice;
  late String barcodeId;
  late bool completed;
  final String userId;
  final String barcodeUrl;
  final String qrcodeUrl;

  Product({
    required this.productId,
    required this.productTitle,
    required this.productPrice,
    required this.barcodeId,
    required this.completed,
    required this.userId,
    required this.barcodeUrl,
    required this.qrcodeUrl,
  });

  Product copyWith({
    String? productId,
    String? productTitle,
    String? productPrice,
    String? barcodeId,
    bool? completed,
    String? userId,
    String? barcodeUrl,
    String? qrcodeUrl,
  }) {
    return Product(
      productId: productId ?? this.productId,
      productTitle: productTitle ?? this.productTitle,
      productPrice: productPrice ?? this.productPrice,
      completed: completed ?? this.completed,
      userId: userId ?? this.userId,
      barcodeId: barcodeId ?? this.barcodeId,
      barcodeUrl: barcodeUrl ?? this.barcodeUrl,
      qrcodeUrl: qrcodeUrl ?? this.qrcodeUrl,
    );
  }
    Map<String, dynamic> toMap() {
      return {
        'productId': productId,
        'productTitle': productTitle,
        'productPrice': productPrice,
        'completed': completed,
        'userId': userId,
        'barcodeId': barcodeId,
        'barcodeUrl': barcodeUrl,
        'qrcodeUrl': qrcodeUrl,
      };
    }
}
