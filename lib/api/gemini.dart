
import 'package:flutter_gemini/flutter_gemini.dart';

void testGemini() {
  final gemini = Gemini.instance;
  gemini
      .streamGenerateContent('Utilizing Google Ads in Flutter')
      .listen((value) {
    print(value.output);
  }).onError((e) {
    print(e.toString());
  });

}
