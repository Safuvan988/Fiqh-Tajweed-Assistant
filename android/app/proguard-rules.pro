# Keep Flutter classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Firebase (important for your app)
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Keep Kotlin
-keep class kotlin.** { *; }