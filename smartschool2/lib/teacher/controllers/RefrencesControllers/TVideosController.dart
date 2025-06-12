import 'package:get/get.dart';
import 'package:smartschool2/student/models/Adjuncts/refrencesVideos.dart';
import 'package:smartschool2/teacher/resources/TAdjunctsServices/TAdjunctsServices.dart';

class TVideosController extends GetxController {
  var refServices = TAdjunctsServices();
  var VideosList =
      [
        /*RefrencesVideos(
      url: '',
      subject: 'Math',
      videoName: 'any',
    ),
    RefrencesVideos(
      url: '',
      subject: 'Math',
      videoName: 'any',
    ),
    RefrencesVideos(
      url: '',
      subject: 'Math',
      videoName: 'any',
    ),*/
      ].obs;

  getVideos() async {
    VideosList.value = await refServices.getVideos();
  }
}
