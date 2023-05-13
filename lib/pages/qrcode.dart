import 'package:shoes_inventory_ms/model/productprovider.dart';
import 'package:shoes_inventory_ms/pages/scannerpage.dart';
import 'package:flutter/material.dart';
import 'package:shoes_inventory_ms/model/productmodel.dart';
import 'package:shoes_inventory_ms/model/constant.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:gallery_saver/gallery_saver.dart';


class QrcodePage extends StatefulWidget {
  final Product todo;

  const QrcodePage({Key? key, required this.todo}) : super(key: key);

  @override
  State<QrcodePage> createState() => _QrcodePageState();
}

class _QrcodePageState extends State<QrcodePage> {

  Future<void> startBarcodeScanStream() async {
    FlutterBarcodeScanner.getBarcodeStreamReceiver(
        '#ff6666', 'Cancel', true, ScanMode.BARCODE)!
        .listen((barcode) => print(barcode));
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

  Future<void> renderImage(String productId, ProductProvider productProvider, Product todo) async {
    final RenderRepaintBoundary boundary = globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    dynamic bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    bytes = bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);

    final Directory documentDirectory = await getApplicationDocumentsDirectory();
    final String path = documentDirectory.path;
    String imageName = '$_title$_barcodeId.png';
    imageCache.clear();
    File file = File('$path/$imageName');
    file.writeAsBytesSync(bytes);

    // Save the image to the gallery
    await GallerySaver.saveImage(file.path);

    // ignore: use_build_context_synchronously
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Download Qrcode'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Container(
                      color: Colors.white,
                      child: Image.file(file),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      // ignore: unnecessary_null_comparison
                      if (file != null) {
                        await productProvider.uploadQrcodes(productId, file, todo);
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Successfully Saved!')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to save QR code to gallery')),
                        );
                      }
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    },
                    child: const Text('Save to database'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  late String _title;
  late String _barcodeId;
  String _scanBarcode = 'Unknown';

  String? barcodeData;
  GlobalKey globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _title = widget.todo.productTitle;
    // _scanBarcode = widget.todo.barcodeId;
    _barcodeId = widget.todo.barcodeId;
  }


  Future<void> scanQR() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
      _barcodeId = barcodeScanRes;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Scanned QR code successfully! $_barcodeId")),
    );
    // ignore: use_build_context_synchronously
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Download Qrcode'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Scanned Barcode:',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    _scanBarcode,
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                scanQR();
              },
              tooltip: 'Scan QR Code',
              child: const Icon(Icons.camera_alt),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      appBar: AppBar(
        title: const Text('Qrcode Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: mainTextColor,
                border: Border.all(color: Colors.white),
              ),
              padding: const EdgeInsets.all(16),
              child: Container(
                color: mainTextColor,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _title,
                      style: TextStyle(color: secondaryTextColor),
                    ),
                    const SizedBox(height: 8),
                    RepaintBoundary(
                      key: globalKey,
                      child: PrettyQr(
                        image: const AssetImage('assets/logo.png'),
                        size: 300,
                        data: _barcodeId,
                        errorCorrectLevel: QrErrorCorrectLevel.M,
                        typeNumber: null,
                        roundEdges: true,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: const Text('CHANGE TO BARCODE', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),),
                    )
                  ],
                ),
              ),
            ),
            ElevatedButton(
                onPressed: (){
                  final ProductProvider productProvider = Provider.of<ProductProvider>(context, listen: false);
                  renderImage(widget.todo.productId, productProvider, widget.todo);
                },
                child: Text('Download Qrcode', style: TextStyle(color: mainTextColor),)
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ScannerPage(),
            ),
          );
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

