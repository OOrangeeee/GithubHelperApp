import 'package:http/http.dart' as http;

class HttpHelper {
  // 发送 GET 请求
  Future<String> httpGet(String url, Map<String, String> headers,
      [Map<String, String>? queryParams]) async {
    var uri = Uri.parse(url).replace(queryParameters: queryParams);
    var response = await http.get(uri, headers: headers);
    // 不做状态码判断，在别的地方做
    return response.body;
  }
}
