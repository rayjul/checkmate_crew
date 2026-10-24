import 'dart:io';

import 'package:image/image.dart' as img;

// Android 12 masks the splash into a circle. Export with safe transparent padding.
void main() {
  final source = img.decodePng(
    File('assets/branding/splash_logo.png').readAsBytesSync(),
  )!;
  final padded = img.Image(width: 1152, height: 1152, numChannels: 4);
  final logo = img.copyResize(source, width: 640, height: 640);
  img.compositeImage(padded, logo, dstX: 256, dstY: 256);
  File('assets/branding/splash_android12.png')
      .writeAsBytesSync(img.encodePng(padded));
}
