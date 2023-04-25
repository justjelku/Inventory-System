import 'package:firebase_login_auth/model/userprovider.dart';
import 'package:firebase_login_auth/pages/barcode.dart';
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
import 'package:pretty_qr_code/pretty_qr_code.dart';


class QrcodePage extends StatefulWidget {
  final Product todo;

  const QrcodePage({Key? key, required this.todo}) : super(key: key);

  @override
  State<QrcodePage> createState() => _QrcodePageState();
}

class _QrcodePageState extends State<QrcodePage> {

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

  Future<void> renderImage(String userId, UserProvider userProvider) async {
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
                      await userProvider.uploadBarcodes(userId, file);
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    },
                    child: const Text('Upload'),
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
                  final UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
                  renderImage(FirebaseAuth.instance.currentUser!.uid, userProvider);
                },
                child: Text('Download Qrcode', style: TextStyle(color: mainTextColor),)
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to barcode scanner page
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

