import 'package:quete_app/Module/Quetes.dart';

import '../Services/Network.dart';

class QueteImage {
  Map<String, dynamic> dataImage = {};
  String queteTitle = "";

  Future<void> getDataImage() async {
    await Quete().getDataQute();
    queteTitle = Quete().queteTitle;
    NetworkHandle api = NetworkHandle(
        url:
            "https://random.imagecdn.app/v1/image?&category=$queteTitle&format=json");
    await api.apiFetchImage();
    dataImage = api.dataImage;
  }
}
