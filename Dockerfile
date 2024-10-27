# استفاده از تصویر پایه Debian
FROM debian:latest

# نصب وابستگی‌ها و ابزارهای پایه
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl wget gnupg ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# افزودن مخزن رسمی Dart
RUN wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /usr/share/keyrings/dart.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/dart.gpg] https://storage.googleapis.com/download.dartlang.org/linux/debian stable main" > /etc/apt/sources.list.d/dart_stable.list

# نصب Dart SDK
RUN apt-get update && \
    apt-get install -y dart

# تنظیم دایرکتوری کاری
WORKDIR /app

# کپی کردن فایل‌های پروژه به داخل کانتینر
COPY . .

# نصب وابستگی‌های Dart
RUN dart pub get

# باز کردن پورت (در صورت نیاز)
EXPOSE 443

# دستور اجرا برای شروع برنامه
CMD ["dart", "run", "bin/topingbot.dart"]
