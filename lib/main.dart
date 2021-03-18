import 'package:flutter/material.dart';
import 'package:groovin_widgets/groovin_widgets.dart';
import 'package:ionicons/ionicons.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  List<Color> buttonColors = [
    Colors.grey,
    Colors.green
  ];
  List<Icon> icons = [
    Icon(
      Ionicons.ellipse_outline,
      color: Colors.white,
    ),
    Icon(
      Ionicons.checkmark_circle,
      color: Colors.white,
    )
  ];
  int buttonVal = 0;
  int val1 = 0;
  int val2 = 0;
  int val3 = 0;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(75),
        child: AppBar(
          backgroundColor: Colors.red,
          elevation: 12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            "Avalanche Safety App"
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Center(
                child: Container(
                  height: size.height * 0.2,
                  width: size.height * 0.2,
                  child: FittedBox(
                    child: FloatingActionButton(
                      child: Icon(
                        Ionicons.power,
                        color: buttonColors[buttonVal],
                      ),
                      onPressed: (){
                        if(buttonVal == 0){
                          setState(() {
                            buttonVal = 1;
                          });
                        }else{
                          setState(() {
                            buttonVal = 0;
                          });
                        }
                      },
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GroovinExpansionTile(
                defaultTrailingIconColor: Colors.white,
                  boxDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    color: Colors.red[900]
                  ),
                  leading: icons[val1],
                  title: Text(
                      "Motor Connected",
                    style: TextStyle(
                      color: Colors.white
                    ),
                  ),
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.red[900]!)
                    ),
                      onPressed: (){
                        if(val1 == 0){
                          setState(() {
                            val1 = 1;
                          });
                        }else{
                          setState(() {
                            val1 = 0;
                          });
                        }
                      },
                      child: Text(
                        "Connect",
                        style: TextStyle(
                          color: Colors.white
                        ),
                      )
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GroovinExpansionTile(
                defaultTrailingIconColor: Colors.white,
                boxDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    color: Colors.red[900]
                ),
                leading: icons[val2],
                title: Text(
                  "Sensors Online",
                  style: TextStyle(
                      color: Colors.white
                  ),
                ),
                children: [
                  ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.red[900]!)
                      ),
                      onPressed: (){
                        if(val2 == 0){
                          setState(() {
                            val2 = 1;
                          });
                        }else{
                          setState(() {
                            val2 = 0;
                          });
                        }
                      },
                      child: Text(
                        "Connect",
                        style: TextStyle(
                            color: Colors.white
                        ),
                      )
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GroovinExpansionTile(
                defaultTrailingIconColor: Colors.white,
                boxDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    color: Colors.red[900]
                ),
                leading: icons[val3],
                title: Text(
                  "Trigger Connected",
                  style: TextStyle(
                      color: Colors.white
                  ),
                ),
                children: [
                  ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.red[900]!)
                      ),
                      onPressed: (){
                        if(val3 == 0){
                          setState(() {
                            val3 = 1;
                          });
                        }else{
                          setState(() {
                            val3 = 0;
                          });
                        }
                      },
                      child: Text(
                        "Connect",
                        style: TextStyle(
                            color: Colors.white
                        ),
                      )
                  )
                ],
              ),
            ),
          ],
        ),

      ),
    );
  }
}
