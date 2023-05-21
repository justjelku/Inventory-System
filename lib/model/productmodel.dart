import 'dart:io';

class Product {
  final String productId;
  final String category;
  final int productSize;
  final String sizeSystem;
  final String color;
  final String productTitle;
  final String productBrand;
  final int productPrice;
  final String productDetails;
  final int productQuantity;
  late String barcodeId;
  final String userId;
  final String barcodeUrl;
  final String qrcodeUrl;
  final String productImage;
  final String branch;

  Product({
    required this.productId,
    required this.category,
    required this.productSize,
    required this.sizeSystem,
    required this.color,
    required this.productTitle,
    required this.productBrand,
    required this.productPrice,
    required this.productDetails,
    required this.productQuantity,
    required this.barcodeId,
    required this.userId,
    required this.barcodeUrl,
    required this.qrcodeUrl,
    required this.productImage,
    required this.branch,
  });

  Product copyWith({
    String? productId,
    int? productSize,
    String? sizeSystem,
    String? color,
    String? category,
    String? productTitle,
    String? productBrand,
    int? productPrice,
    String? productDetails,
    int? productQuantity,
    String? barcodeId,
    String? userId,
    String? barcodeUrl,
    String? qrcodeUrl,
    String? productImage,
    String? branch,
  }) {
    return Product(
      productId: productId ?? this.productId,
      category: category ?? this.category,
      productSize: productSize ?? this.productSize,
      sizeSystem: sizeSystem ?? this.sizeSystem,
      color: color ?? this.color,
      productTitle: productTitle ?? this.productTitle,
      productBrand: productBrand ?? this.productBrand,
      productPrice: productPrice ?? this.productPrice,
      productDetails: productDetails ?? this.productDetails,
      productQuantity: productQuantity ?? this.productQuantity,
      userId: userId ?? this.userId,
      barcodeId: barcodeId ?? this.barcodeId,
      barcodeUrl: barcodeUrl ?? this.barcodeUrl,
      qrcodeUrl: qrcodeUrl ?? this.qrcodeUrl,
      productImage: productImage ?? this.productImage,
      branch: branch ?? this.branch,
    );
  }
    Map<String, dynamic> toMap() {
      return {
        'productId': productId,
        'category' : category,
        'productSize': productSize,
        'sizeSystem' : sizeSystem,
        'color': color,
        'productTitle': productTitle,
        'productBrand': productBrand,
        'productPrice': productPrice,
        'productDetails': productDetails,
        'userId': userId,
        'barcodeId': barcodeId,
        'barcodeUrl': barcodeUrl,
        'qrcodeUrl': qrcodeUrl,
        'productImage': productImage,
        'branch': branch,
      };
    }
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      productId: map['productId'],
      category: map['category'],
      productSize: map['productSize'],
      sizeSystem: map['sizeSystem'],
      color: map['color'],
      productTitle: map['productTitle'],
      productBrand: map['productBrand'],
      productPrice: map['productPrice'],
      productDetails: map['productDetails'],
      productQuantity: map['productQuantity'],
      userId: map['userId'],
      barcodeId: map['barcodeId'],
      barcodeUrl: map['barcodeUrl'],
      qrcodeUrl: map['qrcodeUrl'],
      branch: map['branch'],
      productImage: map['productImage'],
    );
  }
}
