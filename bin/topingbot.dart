import 'package:televerse/televerse.dart';

void main() {
  // توکن ربات تلگرام خود را وارد کنید
  final bot = Bot('7830294069:AAHWZLtw7-xfewH0JJ_l8W-oWUa0Gg6BKEM');

  // تعریف دستور /start
  bot.command('start', (ctx) {
    ctx.reply('سلام! به ربات تلگرام خوش آمدید.');
  });

  // تعریف دستور /echo
  bot.command('echo', (ctx) {
    if (ctx.message!.text != null) {
      String userMessage = ctx.message!.text!.replaceFirst('/echo', '').trim();
      ctx.reply(userMessage.isNotEmpty ? userMessage : 'متنی وارد نشده است!');
    }
  });

  // راه‌اندازی ربات
  bot.start();
}
