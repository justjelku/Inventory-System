import 'dart:io';
import 'package:firebase_login_auth/model/constant.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRCodeScanner extends StatefulWidget {
  QRCodeScanner({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _QRCodeScannerState createState() => _QRCodeScannerState();
}

class _QRCodeScannerState extends State<QRCodeScanner> {
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String qrText = '';

  String? barcodeData;
  GlobalKey globalKey = GlobalKey();
  Barcode? barcode;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: <Widget> [
          buildQrView(context),
          Positioned(
            bottom: 10,
            child: buildResult(),
          ),
          Positioned(
            top: 10,
            child: buildControlButtons(),
          )
        ],
      ),
    );
  }

  Widget buildControlButtons() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      // color: mainTextColor,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
            onPressed: () async {
              await controller?.toggleFlash();
              setState(() {});
            },
            icon: FutureBuilder<bool?>(
              future: controller?.getFlashStatus(),
              builder: (context, snapshot){
                if(snapshot.data != null){
                  return Icon(
                      snapshot.data! ? Icons.flash_on : Icons.flash_off);
                }else{
                  return Container();
                }
              },
            ),
        ),
        IconButton(
            onPressed: () async {
              await controller?.flipCamera();
              setState(() {});
            },
            icon: FutureBuilder(
                future: controller?.getCameraInfo(),
                builder: (context, snapshot){
                  if(snapshot.data != null){
                    return const Icon(Icons.switch_camera);
                  }else{
                    return Container();
                  }
                },
            ),
        )
      ],
    ),
  );

  Widget buildResult() => Column(
    children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: mainTextColor,
        ),
        child: Text(
          barcode != null ? 'Result : ${barcode!.code}' : 'Scan a code!',
          maxLines: 3,
        ),
      ),
      TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text('Go back'),
      ),
    ],
  );

  Widget buildQrView(BuildContext context) => QRView(
    key: qrKey,
    onQRViewCreated: _onQRViewCreated,
    cameraFacing: CameraFacing.back,
    overlay: QrScannerOverlayShape(
      borderColor: Colors.red,
      borderRadius: 10,
      borderLength: 30,
      borderWidth: 10,
      cutOutSize: MediaQuery.of(context).size.width * 0.8,
    ),
  );

  void _onQRViewCreated(QRViewController controller) {
    setState(() => this.controller = controller);

    controller.scannedDataStream.listen((barcode) => setState(() => this.barcode = barcode));
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void reassemble() async {
    super.reassemble();

    if(Platform.isAndroid){
      await controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

}
