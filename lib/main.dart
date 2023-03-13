import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'web.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qr Okuyucu',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'QR'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final qrKey = GlobalKey(debugLabel: 'QR');

  Barcode? barcode;                     // boş olabilecek şekilde barcode ve Qrcontroller değişkenlerimizi oluşturduk.
  QRViewController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void reassemble() async {           // Kameramızı başlatıyoruz
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        child: buildQrView(context),
                        height: MediaQuery.of(context).size.height - 100,
                      ),
                      Positioned(
                        child: buildResult(context),
                        bottom: 25,
                      )
                    ],
                  ),
                ],
              ),
            ),
          )),
    );
  }


  // qr koddan okunan veri url değil metin ise sayfanın altında gösterilecek olan alan
  Widget buildResult(BuildContext context) => Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white54),
    child: Text(
      // barcode değerimizi kontrol ediyoruz eğer dolu ise metni gösteriyoruz
      barcode != null
          ? '${barcode!.code}'
          : "Lütfen Kodu Okutun",
      maxLines: 3,
      style: TextStyle(fontSize: 16),
    ),
  );

  // qr okuyucu için kameramızı açtığımız ve okuma penceresini oluşturduğumuz alan
  Widget buildQrView(BuildContext context) => QRView(
    key: qrKey,
    onQRViewCreated: onQRViewCreated,
    overlay: QrScannerOverlayShape(
        borderColor: Theme.of(context).accentColor,
        borderRadius: 10,
        borderLength: 20,
        borderWidth: 10,
        cutOutSize: MediaQuery.of(context).size.width * 0.8),
  );

  // qr okuyucu pencere oluşturulduğunda qr okunup okunmadığını kontrol ettiğimiz alan
  void onQRViewCreated(QRViewController controller) {
    setState(() => this.controller = controller);

    controller.scannedDataStream.listen((barcode) {
      var code = barcode.code;

      // url doğru olup olmadığını kontrol ediyoruz
      bool _validURL = Uri.parse(code!).isAbsolute;

      if(_validURL){
        // url doğru ise web.dart dosyasına gönderiyoruz url'i webview olarak açıyoruz
        Navigator.push(context, MaterialPageRoute(builder: (context) => WebviewPage(barcode.code)));
      }

      // barcode değişkenimizi qr koddan gelen barcode ile güncelliyoruz
      setState(() => this.barcode = barcode);
    }
    );
  }
}
