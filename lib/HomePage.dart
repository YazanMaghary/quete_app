import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:quete_app/Module/QueteImage.dart';
import 'package:quete_app/Module/Quetes.dart';
import 'dart:ui' as ui;

import 'package:share_plus/share_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Quete quete = Quete();
  QueteImage queteImage = QueteImage();
  List<dynamic> dataQute = [];
  Map<String, dynamic> dataImage = {};
  String queteTitle = "";
  bool isLoadingQuete = true;
  bool isLoadingImage = true;
  GlobalKey globalKey = GlobalKey();
  Uint8List? pngBytes;
  Future<void> _capturePng() async {
    RenderRepaintBoundary boundary =
        globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    if (kDebugMode) {
      print("Waiting for boundary to be painted.");
    }
    await Future.delayed(const Duration(milliseconds: 20));
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    pngBytes = byteData!.buffer.asUint8List();
    if (kDebugMode) {
      print(pngBytes);
    }
    if (mounted) {
      _onShareXFileFromAssets(context, byteData);
    }
  }

  void _onShareXFileFromAssets(BuildContext context, ByteData? data) async {
    final box = context.findRenderObject() as RenderBox?;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    // final data = await rootBundle.load('assets/flutter_logo.png');
    final buffer = data!.buffer;
    final shareResult = await Share.shareXFiles(
      [
        XFile.fromData(
          buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
          name: 'screen_shot.png',
          mimeType: 'image/png',
        ),
      ],
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );

    scaffoldMessenger.showSnackBar(getResultSnackBar(shareResult));
  }

  SnackBar getResultSnackBar(ShareResult result) {
    return SnackBar(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Share result: ${result.status}"),
          if (result.status == ShareResultStatus.success)
            Text("Shared to: ${result.raw}")
        ],
      ),
    );
  }

  Future<void> getDataQute() async {
    // NetworkHandle api =
    //     NetworkHandle(url: "https://api.quotable.io/quotes/random");
    // await api.apiFetchQuete();
    // dataQute = api.dataQute;
    // queteTitle = dataQute[0]["tags"][0];
    await quete.getDataQute();
    isLoadingQuete = false;
    setState(() {});
    print(queteTitle);
  }

  Future<void> getDataImage() async {
    // NetworkHandle api = NetworkHandle(
    //     url:
    //         "https://random.imagecdn.app/v1/image?&category=$queteTitle&format=json");
    // await api.apiFetchImage();
    // dataImage = api.dataImage;
    await queteImage.getDataImage();
    isLoadingImage = false;
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    getDataImage();
    getDataQute();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RepaintBoundary(
        key: globalKey,
        child: SafeArea(
            child: Stack(children: [
          isLoadingQuete == true || isLoadingImage == true
              ? const Center(child: CircularProgressIndicator())
              : Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(queteImage.dataImage["url"]),
                          fit: BoxFit.fill)),
                ),
          isLoadingQuete == true || isLoadingImage == true
              ? const Center(child: CircularProgressIndicator())
              : Container(
                  color: Colors.white.withOpacity(0.4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.4)),
                            child: Text(
                              "${quete.dataQuete[0]["content"]}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            decoration: BoxDecoration(
                                color: Colors.lightGreen,
                                borderRadius: BorderRadius.circular(15)),
                            child: Text(
                              "${quete.dataQuete[0]["tags"][0]}",
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          Positioned(
              top: 20,
              right: 10,
              child: IconButton(
                onPressed: () async {
                  isLoadingQuete = true;
                  isLoadingImage = true;
                  await getDataQute();
                  await getDataImage();
                  setState(() {});
                },
                icon: const Icon(
                  Icons.refresh,
                  size: 40,
                ),
                color: Colors.lightGreen,
              )),
          Positioned(
            bottom: 20,
            right: 10,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.lightGreen,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15))),
                onPressed: _capturePng,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.share,
                      size: 32,
                    ),
                    Text(
                      "Take ScreenShot",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    )
                  ],
                )),
          ),
        ])),
      ),
    );
  }
}
