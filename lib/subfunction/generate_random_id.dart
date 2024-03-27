import 'dart:math';

String generateRandomID() {
  DateTime nowTime = DateTime.now();
  String randomString = nowTime.toString();
  randomString = randomString.replaceAll(" ", "");
  randomString = randomString.replaceAll("-", "");
  randomString = randomString.replaceAll(".", "");
  randomString = randomString.replaceAll(":", "");
  int randomInt = Random.secure().nextInt(1 << 32);
  randomString = randomString + randomInt.toString();
  // print("Random ID generated: " + randomString);
  return randomString;
}
