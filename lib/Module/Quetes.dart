import '../Services/Network.dart';

class Quete {
  List<dynamic> dataQuete = [];
  String queteTitle = "";
  Future<void> getDataQute() async {
    NetworkHandle api =
        NetworkHandle(url: "https://api.quotable.io/quotes/random");
    await api.apiFetchQuete();
    dataQuete = api.dataQute;
    queteTitle = dataQuete[0]["tags"][0];
    print(queteTitle);
  }
}
