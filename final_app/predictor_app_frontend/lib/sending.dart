import 'dart:convert';
import 'package:http/http.dart' as http;
import "dart:io";

Future<String> get_response_from_backend(Map<String, dynamic> data)  async {
  print(json.encode(data));
  final response = await http.post(

    Uri.parse('http://localhost:8080'),
    headers:{
     "Access-Control-Allow-Origin":"*",
     "Access-Control-Allow-Methods":"GET,PUT,PATCH,POST,DELETE",
    "Access-Control-Allow-Headers": "Origin, X-Requested-With, Content-Type, Accept"
    },

    body: jsonEncode(data),
  );

  if (response.statusCode == 200) {
     Map<String, dynamic> responseData = json.decode(response.body);
     if (responseData.containsKey("ONPY"))
       {
         return "According to our analysis, your house should best be rented at a price of ${responseData["Price"]} a night, with "
  "minimum nights of ${responseData["MinNights"]} and maximum nights of ${responseData["MaxNights"]}. This way you will "
  "recoup your original investment in ${responseData["Delay"]} years. The average numbers of nights rented per year is estimated "
  "to be ${responseData["NPY"]}.\nProvided more effort is put into the property, the delay will be estimated to be ${responseData["OptiDelay"]}. "
             "Please run the prediction with 4 as the work value for more details";
       }
    return "According to our analysis, your house should best be rented at a price of ${responseData["Price"]} a night, with "
        "minimum nights of ${responseData["MinNights"]} and maximum nights of ${responseData["MaxNights"]}. This way you will "
        "recoup your original investment in ${responseData["Delay"]} years. The average numbers of nights rented per year is estimated "
        "to be ${responseData["NPY"]}";
  } else {

    throw Exception('Failed to reach backend');
  }
}

bool isNumeric(String str) {
  try{
    var value = double.parse(str);
  } on FormatException {
    return false;
  }

    return true;
}