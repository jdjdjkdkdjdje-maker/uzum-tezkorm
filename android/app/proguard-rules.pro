# Flutter o'zi ko'p narsani himoya qiladi, lekin quyidagilar ba'zi
# pluginlar (Firebase, Google Sign-In, Socket.IO) uchun xavfsizlik uchun kerak.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**

-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**

-keepattributes Signature
-keepattributes *Annotation*
