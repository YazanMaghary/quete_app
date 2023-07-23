import 'dart:convert';

import 'package:http/http.dart' as http;

class NetworkHandle {
  final String url;
  late List<dynamic> dataQute = [];
  late Map<String, dynamic> dataImage = {};
  NetworkHandle({required this.url});

  Future<List<dynamic>> apiFetchQuete() async {
    http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      dataQute = jsonDecode(response.body);
      print(dataQute);
      return dataQute;
    } else {
      return Future.error("Somthing Wrong");
    }
  }

  Future<Map<String, dynamic>> apiFetchImage() async {
    http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      dataImage = jsonDecode(response.body);
      print(dataImage);
      return dataImage;
    } else {
      return Future.error("Somthing Wrong");
    }
  }
}
