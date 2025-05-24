# Razorpay SDK ProGuard Rules
-keep class com.razorpay.** { *; }
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-dontwarn com.razorpay.**
