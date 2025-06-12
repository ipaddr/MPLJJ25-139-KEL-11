import 'package:get/get.dart';
import 'package:smartschool2/student/resources/chat/chat_api.dart';

class SearchController extends GetxController {
  bool searchStatus = true;
  var searchResult = [].obs;

  loadSearchByName(String name) async {
    searchStatus = false;
    searchResult.value = await FirebaseApi.LoadNameFromApi(name);
    print(searchResult.value);

    searchStatus = true;
  }
}
