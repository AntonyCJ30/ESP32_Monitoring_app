import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleConfig {
  static final Guid provisioningService =
      Guid("6E400001-B5A3-F393-E0A9-E50E24DCCA9E");

  static final Guid rx =
      Guid("6E400002-B5A3-F393-E0A9-E50E24DCCA9E");

  static final Guid tx =
      Guid("6E400003-B5A3-F393-E0A9-E50E24DCCA9E");
}
