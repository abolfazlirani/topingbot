import 'dart:convert';
import 'dart:io';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:televerse/televerse.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:jose/jose.dart';

void main() {
  final bot = Bot('7830294069:AAHWZLtw7-xfewH0JJ_l8W-oWUa0Gg6BKEM');

  bot.command('start', (ctx) {
    ctx.reply('سلام 👋! ایمیلت رو وارد کن تا دعوت‌نامه تست‌فلایت برات بفرستیم 📩');
  });

  bot.onMessage((ctx) async {
    String? email = ctx.message?.text;
    if (email != null && email.contains('@')) {
      if (await isEmailNew(email)) {
        ctx.reply('ایمیلت ثبت شد ✅، ارسال دعوت‌نامه در حال انجامه... 📤');
        bool success = await sendInvitationToTestFlight(email, ctx);
        if (success) {
          ctx.reply(
              'دعوت‌نامه به ایمیل $email ارسال شد 🎉!\n'
                  '💌 آموزش: \n'
                  '۱. ایمیلت رو چک کن و لینک دعوت‌نامه رو باز کن.\n'
                  '۲. اگه تست‌فلایت رو نصب نداری، نصبش کن 📲.\n'
                  '۳. بعد از نصب، اپلیکیشن رو دانلود و نصب کن.\n'
                  '۴. هر آپدیت جدید رو هم از طریق تست‌فلایت دریافت می‌کنی.\n'
                  'پیشاپیش از تست اپ ما ممنونیم 💙!'
          );
          await saveEmail(email);
        } else {
          ctx.reply('😕 متأسفانه در ارسال دعوت‌نامه مشکلی پیش اومد، دوباره امتحان کن.');
        }
      } else {
        ctx.reply('این ایمیل قبلاً ثبت شده 📬! لطفاً یه ایمیل جدید امتحان کن.');
      }
    } else {
      ctx.reply('لطفاً یه ایمیل معتبر وارد کن 📨');
    }
  });

  bot.start();
}

Future<bool> sendInvitationToTestFlight(String email, Context ctx) async {
  final url = 'https://api.appstoreconnect.apple.com/v1/betaTesters';
  String token = generateJwtToken(ctx);

  var headers = {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  final response = await http.post(
    Uri.parse(url),
    headers: headers,
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
              {"type": "betaGroups", "id": "573c6f18-eaf0-40a9-9b92-87f8645bf244"}
            ]
          }
        }
      }
    }),
  );

  return response.statusCode == 201;
}

String generateJwtToken(ctx) {
  final keyId = '5HKD45XYDJ';
  final issuerId = '78e54f4b-f19f-4873-bab5-fb16e545e2aa';
  final privateKey = """
-----BEGIN PRIVATE KEY-----
MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgawHis1W4+tKTS5f9
Rl246oRJ61OgFZ3OP75uNzImm/2gCgYIKoZIzj0DAQehRANCAASK14sSV17h4XRF
3qKj3B7dCbZUY4hCKfAohKttTQR6etuyhWAAuIK6wCdph+hHqiyeKnqd/kYIjEAa
z3u5SNF6
-----END PRIVATE KEY-----""";

  final claims = {
    'iss': issuerId,
    'exp': (DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000) + 1200,
    'aud': 'appstoreconnect-v1'
  };

  final jws = JsonWebSignatureBuilder()
    ..jsonContent = claims
    ..setProtectedHeader('alg', 'ES256')
    ..addRecipient(JsonWebKey.fromPem(privateKey, keyId: keyId));

  final jwt = jws.build().toCompactSerialization();
  return jwt;
}

Future<bool> isEmailNew(String email) async {
  final file = File('emails.txt');
  if (!await file.exists()) {
    await file.create();
  }
  final emails = await file.readAsLines();
  return !emails.contains(email);
}

Future<void> saveEmail(String email) async {
  final file = File('emails.txt');
  await file.writeAsString('$email\n', mode: FileMode.append);
}
