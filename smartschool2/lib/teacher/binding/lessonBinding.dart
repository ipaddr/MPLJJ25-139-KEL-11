import 'package:get/get.dart';
import 'package:smartschool2/student/controllers/lessonsController.dart';

class TlessonBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => lessonsController());
  }
}
