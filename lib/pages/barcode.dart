import 'package:firebase_login_auth/model/productprovider.dart';
import 'package:firebase_login_auth/pages/barcodescan.dart';
import 'package:firebase_login_auth/pages/qrcode.dart';
import 'package:firebase_login_auth/pages/qrscan.dart';
import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:firebase_login_auth/model/productmodel.dart';
import 'package:firebase_login_auth/model/constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';


class BarcodePage extends StatefulWidget {
  final Product todo;

  const BarcodePage({Key? key, required this.todo}) : super(key: key);

  @override
  State<BarcodePage> createState() => _BarcodePageState();
}

class _BarcodePageState extends State<BarcodePage> {

  late String _title;
  late String _barcodeId;

  String? barcodeData;
  GlobalKey globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _title = widget.todo.productTitle;
    _barcodeId = widget.todo.barcodeId;
  }

  Future<void> renderImage(String userId, ProductProvider productProvider, Product todo) async {
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

    // ignore: use_build_context_synchronously
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Download Barcode'),
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
                      // await productProvider.uploadBarcodes(userId, file);
                      if (file != null) {
                        await productProvider.uploadBarcodes(userId, file, todo);
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
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Barcode Page'),
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
                      child: BarcodeWidget(
                        color: secondaryTextColor,
                        barcode: Barcode.code128(),
                        data: _barcodeId,
                        width: 350,
                        height: 200,
                        drawText: true,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QrcodePage(
                              todo: widget.todo,
                            ),
                          ),
                        );
                      },
                      child: const Text('CHANGE TO QRCODE', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),),
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
                child: Text('Download Barcode', style: TextStyle(color: mainTextColor),)
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to barcode scanner page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BarcodeScanner(),
            ),
          );
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

