import 'package:get/get.dart';
import 'package:smartschool2/teacher/controllers/RefrencesControllers/TrefrenceBottomSheetController.dart';
import 'package:smartschool2/teacher/controllers/TasksControllers/bottomSheetController.dart';

import '../controllers/RefrencesControllers/TPdfRefrencesController.dart';

class TAdjunctsBinding implements Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(() => TRefrencesPdfController());
    Get.lazyPut(() => TreferenceBottomsheetController());
    Get.lazyPut(() => BottomSheetController());
  }
}
