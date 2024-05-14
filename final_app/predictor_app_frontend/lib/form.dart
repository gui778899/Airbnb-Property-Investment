import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './entires.dart';
import './sending.dart';



class FormExample extends StatefulWidget {
  const FormExample({super.key});

  @override
  State<FormExample> createState() => _FormExampleState();
}



class _FormExampleState extends State<FormExample> {
  Widget bottomWidget = SizedBox(height: 20,);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  CustomStringController boroughsController = CustomStringController();
  CustomStringController hostBoroughsController = CustomStringController();
  CustomStringController propTypeController = CustomStringController();
  CustomStringController roomsTypeContoller = CustomStringController();
  CustomStringController workController = CustomStringController();

  TextEditingController longController = TextEditingController();
  TextEditingController latController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController amenitiesController = TextEditingController();
  TextEditingController bedsController = TextEditingController();
  TextEditingController bedroomsController = TextEditingController();
  TextEditingController bathroomsController = TextEditingController();
  TextEditingController accomodateController = TextEditingController();

  CustomBoolController privateContorller = CustomBoolController();
  CustomBoolController sharedContorller = CustomBoolController();
  CustomBoolController halfContorller = CustomBoolController();



  @override
  Widget build(BuildContext context) {
    DropdownButtonWidget boroughsSelector = DropdownButtonWidget(key: Key("BoSe"), options: BOROUGHS, control: boroughsController,);
    DropdownButtonWidget hostBoroughsSelector = DropdownButtonWidget(key: Key("HoBoSe"), options: BOROUGHS_WITH_UNKNOWN, control: hostBoroughsController,);
    DropdownButtonWidget propTypesSelector = DropdownButtonWidget(key: Key("ProTySe"), options: PROPERTY_TYPES, control: propTypeController,);
    DropdownButtonWidget roomTypesSeletor = DropdownButtonWidget(key: Key("RTS"), options: ROOM_TYPES, control: roomsTypeContoller,);
    DropdownButtonWidget workSelector = DropdownButtonWidget(key: Key("work"), options: ["1","2","3","4"], control:workController);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          SizedBox(height: 30,),
          Text("About this application", style: TextStyle(fontSize: 30),),
          SizedBox(height: 20,),
          Text("Welcome to the Predictor Payback App! Input your Airbnb property's details"
              " - location, price, and features such as beds, baths, and amenities - and let"
              " this app estimate its payback period. Utilising an advanced XGBoost model trained on"
              " comprehensive data from the Land Registry and Airbnb datasets of 2022-2023,"
              " it offers precise and quick insights to support your rental investment choices.", style: TextStyle(fontSize: 20),),
          SizedBox(height: 30,),
          Text("Coordinates", style: TextStyle(fontSize: 30),),
          numberInput("Enter a longitude", longController, true, -0.51, 0.3),
          numberInput("Enter a latitude", latController,true  ,51.2, 51.7),


          SizedBox(height: 30,),
          Text("House Information", style: TextStyle(fontSize: 30),),
          numberInput("Enter The price (in USD)", priceController, false, 0, 0),

          SizedBox(height: 20,),
          numberInput("Enter The number of beds", bedsController, false, 0, 0),

          SizedBox(height: 20,),
          numberInput("Enter The number of bedrooms", bedroomsController, false, 0, 0),

          SizedBox(height: 20,),
          numberInput("Enter The number of bathrooms", bathroomsController, false, 0, 0),

          SizedBox(height: 20,),
          numberInput("Enter The number of amenities", amenitiesController, false, 0, 0),



          SizedBox(height: 20,),
          Text("Where is the property located?", style: TextStyle(fontSize: 18),),
          boroughsSelector,


          SizedBox(height: 20,),
          Text("Where do you live? (Select 'Unknown' if outside of London)", style: TextStyle(fontSize: 18),),
          hostBoroughsSelector,


          SizedBox(height: 20,),
          Text("Which of the following best describe the property?", style: TextStyle(fontSize: 18),),
          propTypesSelector,


          SizedBox(height: 20,),
          Text("What kind of room type is for renting?", style: TextStyle(fontSize: 18),),
          roomTypesSeletor,

          TextWithCheckbox(Key: Key("k"), text: "Does the property have a private bathroom?", control: privateContorller,),

          TextWithCheckbox(Key: Key("k2"), text: "Does the property have a shared bathroom?", control: sharedContorller,),

          TextWithCheckbox(Key: Key("k3"), text: "Does the property have a half-bath?", control: halfContorller,),

          SizedBox(height: 30,),
          Text("Miscellaneous", style: TextStyle(fontSize: 30),),

          SizedBox(height: 20,),
          Text("Please rate your commitment to maintaining the property and responding to clients on a scale of 1 to 4. Here, 1 indicates a"
              " low level of commitment, while 4 represents a high level. Your input helps us tailor our estimates to match your"
              " engagement accurately", style: TextStyle(fontSize: 20),),
          workSelector,


          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: SizedBox(
            width: double.infinity, // <-- match_parent
            child: ElevatedButton(
              onPressed: () {

                // Validate will return true if the form is valid, or false if
                // the form is invalid.
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState?.save();
                  send();
                }
              },
              child: const Text('Submit'),
            ),
          )),
          bottomWidget,
          SizedBox(height:20),
        ],
      ),
    );
  }

  double p_offset(String ptype)
  {
    int amount = PROPERTY_TYPES.length~/2;
    int index = PROPERTY_TYPES.indexOf(ptype);
    int index2 = index;
    while (index2>0)
      {
        index+=amount;

        index = index%PROPERTY_TYPES.length;
        amount = amount + amount~/2;
        index2--;
      }

    if (PROPERTY_TYPES.contains(ptype))
    {
      double  off = -0.5/2 + 0.8/(PROPERTY_TYPES.length)*index;
      return off;
    }
    return 0;
  }

  double r_offset(String ptype)
  {
    if (ROOM_TYPES.contains(ptype))
    {
      double  off = -51.5/2 + 1.5/(ROOM_TYPES.length)*ROOM_TYPES.indexOf(ptype);
      return off;
    }
    return 0;
  }

  void send() {
    Map<String, dynamic> data = Map<String, dynamic>();
    var p = propTypeController.value;
    var r =  roomsTypeContoller.value;

    data = {
      'host_neighbourhood': hostBoroughsController.value,
      'neighbourhood_cleansed': boroughsController.value,
      'latitude': double.parse(latController.value.text)+r_offset(r),
      'longitude': double.parse(longController.value.text)+p_offset(p),
      'property_type': propTypeController.value,
      'room_type': roomsTypeContoller.value,
      'accommodates': double.parse(bedsController.value.text),
      'bedrooms': double.parse(bedroomsController.value.text),
      'beds': double.parse(bedsController.value.text),
      "nights": 5,
      "work": double.parse(workController.value),
      'bathrooms_count': double.parse(bathroomsController.value.text),
      'private_bath': privateContorller.value,
      'shared_bath': sharedContorller.value,
      'half_bath': halfContorller.value,
      'price_estimate': double.parse(priceController.value.text),
      'amenity_count': double.parse(amenitiesController.value.text)};

    setState(() {
      bottomWidget = const CircularProgressIndicator();
    });
    setState(() {
      bottomWidget = FutureBuilder(
        future: get_response_from_backend(data),
        builder: (context, snapshot) {
          if ((snapshot.hasData) && (snapshot.connectionState == ConnectionState.done)) {

            return Container(height: 300,
            child: Column(
              children: [
                SizedBox(height: 20,),
                Text(snapshot.data!, style: TextStyle(fontSize: 20),),

              ],
            ));
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }

          return const CircularProgressIndicator();
        }
      );
    });
  }
}

TextFormField numberInput(String hint, TextEditingController control, bool ranged, double min, double max) {
  return  TextFormField(
    controller: control,
    decoration:  InputDecoration(
      hintText: hint,
    ),
    keyboardType: TextInputType.number,

    validator: (String? value) {
      if (value == null || value.isEmpty) {
        return 'Please enter a value';
      }

      if (!isNumeric(value))
        {
          return "value must be a whole or floating number";
        }
      double val = double.parse(value);
     if ((val<min) &&ranged)
          {
            return "Not in the city of london coordinates [(${min}, ${max})]";
          }

      if ((val>max) && ranged)
      {
        return "Not in the city of london coordinates [(${min}, ${max})]";
      }

      return null;
    },
  );
}
class DropdownButtonWidget extends StatefulWidget {

  final List<String> options;
  CustomStringController control;

  DropdownButtonWidget({required Key key, required this.control ,required this.options}) : super(key: key);


  @override
  State<DropdownButtonWidget> createState() => _DropdownButtonState();
}

class _DropdownButtonState extends State<DropdownButtonWidget> {

  bool isThereValue = false;
  String dropdownValue = "None";


  String getValue(){
    return dropdownValue;
  }

  @override
  Widget build(BuildContext context) {
    if (!isThereValue)
      {
        isThereValue = true;
        dropdownValue = widget.options.first;
        widget.control.setValue(dropdownValue);
      }

    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.black87, fontSize: 15),
      underline: Container(
        height: 2,
        color: Colors.black54,
      ),
      onChanged: (String? value) {
        setState(() {
        dropdownValue = value!;
        widget.control.setValue(value!);
        });
      },
      items: widget.options.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}

class TextWithCheckbox extends StatefulWidget {
  final String text;
  final CustomBoolController control; // Parameter for the text

  // Constructor
  TextWithCheckbox({required Key, required CustomBoolController this.control, key,  required this.text}) : super(key: key);

  @override
  _TextWithCheckboxState createState() => _TextWithCheckboxState();
}

class _TextWithCheckboxState extends State<TextWithCheckbox> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(widget.text), // Use the text parameter
        SizedBox(width: 10), // Adjust spacing between text and checkbox
        Checkbox(
          value: isChecked,
          onChanged: (value) {
            setState(() {
              isChecked = value!;
              widget.control.setValue(value!);
            });
          },
        ), // Your checkbox widget
      ],
    );
  }
}

class CustomStringController
{
  String value = "None";

  void setValue(String val)
  {
    value=val;
  }

  String getValue (){
    if (value == "None"){ throw Exception();}
    return value;
  }
}

class CustomBoolController
{
  bool value = false;

  void setValue(bool val) {value= val;}

  bool getValue (){return value;}
}