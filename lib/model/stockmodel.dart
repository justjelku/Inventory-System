import 'dart:io';

class StockInModel {
  final String productId;
  final String stockinId;
  final String productImage;
  final String barcodeId;
  final String barcodeUrl;
  final String category;
  final String color;
  final String stock;
  final int productSize;
  final String qrcodeUrl;
  final String branch;
  final String productTitle;
  final String productDetails;
  final String productBrand;
  final int productPrice;
  final int productQuantity;
  final String userId;
  final DateTime updatedAt;

  StockInModel({
    required this.productId,
    required this.stockinId,
    required this.productImage,
    required this.barcodeId,
    required this.barcodeUrl,
    required this.category,
    required this.color,
    required this.stock,
    required this.productSize,
    required this.qrcodeUrl,
    required this.branch,
    required this.productTitle,
    required this.productDetails,
    required this.productBrand,
    required this.productPrice,
    required this.productQuantity,
    required this.userId,
    required this.updatedAt, required sizeSystem, required type,
  });

  factory StockInModel.fromMap(Map<String, dynamic> map) {
    return StockInModel(
      productId: map['productId'],
      stockinId: map['stockinId'],
      productImage: map['productImage'],
      barcodeId: map['barcodeId'],
      barcodeUrl: map['barcodeUrl'],
      category: map['category'],
      color: map['color'],
      stock: map['stock'],
      productSize: map['productSize'],
      qrcodeUrl: map['qrcodeUrl'],
      branch: map['branch'],
      productTitle: map['productTitle'],
      productDetails: map['productDetails'],
      productBrand: map['productBrand'],
      productPrice: map['productPrice'],
      productQuantity: map['productQuantity'],
      userId: map['userId'],
      updatedAt: map['updatedAt'].toDate(), sizeSystem: map['sizeSystem'], type: map['type'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'stockinId': stockinId,
      'productImage': productImage,
      'barcodeId': barcodeId,
      'barcodeUrl': barcodeUrl,
      'category': category,
      'color': color,
      'stock': stock,
      'productSize': productSize,
      'qrcodeUrl': qrcodeUrl,
      'branch': branch,
      'productTitle': productTitle,
      'productDetails': productDetails,
      'productBrand': productBrand,
      'productPrice': productPrice,
      'productQuantity': productQuantity,
      'userId': userId,
      'updatedAt': updatedAt,
    };
  }
}
