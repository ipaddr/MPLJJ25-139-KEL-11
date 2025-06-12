import 'package:get/get.dart';
import 'package:smartschool2/public/config/user_information.dart';
import 'package:smartschool2/student/resources/subject/subject_api.dart';

class SubjectController extends GetxController {
  var subjectServices = SubjectServices();
  var subjectList = [].obs;
  getSujects() async {
    subjectList.value = await subjectServices.getUserSubjects();
    UserInformation.Subjects = subjectList.value;
  }
}
