import 'package:url_launcher/url_launcher.dart';

Future<void> launchUrlWithBrowser(String url) async {
  Uri parsedUrl = Uri.parse(url);
  if (!await launchUrl(parsedUrl)) {
    throw Exception('Could not launch $url');
  }
}
