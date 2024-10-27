import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:televerse/televerse.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:jose/jose.dart';

void main() {
  final bot = Bot('7830294069:AAHWZLtw7-xfewH0JJ_l8W-oWUa0Gg6BKEM');

  bot.command('start', (ctx) {
    ctx.reply('سلام! ایمیل خود را وارد کنید تا دعوت‌نامه تست‌فلایت دریافت کنید.');
  });

  bot.onMessage((ctx) async {
    String? email = ctx.message?.text;
    if (email != null && email.contains('@')) {
      ctx.reply('ایمیل شما ثبت شد. ارسال دعوت‌نامه...');

      bool success = await sendInvitationToTestFlight(email,ctx);
      if (success) {
        ctx.reply('دعوت‌نامه به ایمیل $email ارسال شد!');
      } else {
        ctx.reply('مشکلی در ارسال دعوت‌نامه پیش آمد. لطفاً دوباره تلاش کنید.');
      }
    } else {
      ctx.reply('لطفاً یک ایمیل معتبر وارد کنید.');
    }
  });

  bot.start();
}

Future<bool> sendInvitationToTestFlight(String email, Context ctx) async {
  final url = 'https://api.appstoreconnect.apple.com/v1/betaTesters';
  String token = generateJwtToken();

  var  headerss= {
  'Authorization': 'Bearer $token',
  'Content-Type': 'application/json',
  };
  final response = await http.post(
    Uri.parse(url),
    headers: headerss,
    body: jsonEncode({
      "data": {
        "type": "betaTesters",
        "attributes": {
          "email": email,
          "firstName": "Test",
          "lastName": "User"
        },
        "relationships": {
          "betaGroups": {
            "data": [
              {"type": "betaGroups", "id": "BETA_GROUP_ID"}
            ]
          }
        }
      }
    }),
  );

  ctx.reply(' headerss : ${headerss} \n ${response.body}');
  return response.statusCode == 201;
}

String generateJwtToken() {
  final keyId = '5HKD45XYDJ';
  final issuerId = '78e54f4b-f19f-4873-bab5-fb16e545e2aa';
  final privateKey = """
-----BEGIN PRIVATE KEY-----
MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgawHis1W4+tKTS5f9
Rl246oRJ61OgFZ3OP75uNzImm/2gCgYIKoZIzj0DAQehRANCAASK14sSV17h4XRF
3qKj3B7dCbZUY4hCKfAohKttTQR6etuyhWAAuIK6wCdph+hHqiyeKnqd/kYIjEAa
z3u5SNF6
-----END PRIVATE KEY-----""";

  // ساخت توکن با payload مورد نظر
  final jwt = JWT(
    {
      'iss': issuerId,
      'exp': (DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000) + 1200,
      'aud': 'appstoreconnect-v1'
    },
  );

  // امضای توکن با کلید خصوصی و الگوریتم ES256
  final token = jwt.sign(
    ECPrivateKey(privateKey),
    algorithm: JWTAlgorithm.ES256,
  );

  // اضافه کردن kid به هدر به عنوان بخشی از رشته نهایی
  final header = '{"alg":"ES256","kid":"$keyId","typ":"JWT"}';
  final headerBase64 = base64Url.encode(utf8.encode(header));
  final payloadBase64 = base64Url.encode(utf8.encode(jwt.payload.toString()));

  return '$headerBase64.$payloadBase64.$token';
}