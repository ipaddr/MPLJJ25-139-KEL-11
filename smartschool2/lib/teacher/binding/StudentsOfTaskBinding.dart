import 'package:get/get.dart';
import 'package:smartschool2/teacher/controllers/TasksControllers/CheckedStudentTaskInfoController.dart';

import '../controllers/TasksControllers/studentTaskInfo.dart';

class StudentsOfTaskBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<StudentTaskInfoController>(StudentTaskInfoController());
    Get.put<CheckedStudentTaskInfoController>(
      CheckedStudentTaskInfoController(),
    );
  }
}
