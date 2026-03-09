import 'dart:math';
import 'package:flutter/material.dart';

class SchoolSignupScreen extends StatefulWidget {
  const SchoolSignupScreen({super.key});

  @override
  State<SchoolSignupScreen> createState() => _SchoolSignupScreenState();
}

class _SchoolSignupScreenState extends State<SchoolSignupScreen>
    with TickerProviderStateMixin {

  int step = 0;

  Map<String, dynamic> form = {
    "name": "",
    "age": "",
    "school": "",
    "grade": "",
    "parentName": "",
    "parentPhone": "",
    "parentEmail": "",
    "interests": <String>[]
  };

  final interests = [
    '🐍 Python',
    '🤖 AI/ML',
    '🎮 Game Dev',
    '📱 App Dev',
    '🌐 Web',
    '🔬 Robotics',
    '🎨 Design',
    '📊 Data'
  ];

  final emojis = ['🌟','🚀','🤖','💡','🎨','🔬'];
  final shapes = ['🟣','🟡','🔵','🟢','🔴','🟠'];

  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    super.initState();
  }

  void toggleInterest(String i){
    List list = form["interests"];

    if(list.contains(i)){
      list.remove(i);
    }else{
      list.add(i);
    }

    setState(() {
      form["interests"] = list;
    });
  }

  void nextStep(){
    if(step < 2){
      setState(() {
        step++;
      });
    }else{
      Navigator.pushNamed(context, "/school");
    }
  }

  void back(){
    if(step > 0){
      setState(() {
        step--;
      });
    }else{
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: [

          /// Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xfff093fb),
                  Color(0xff667eea),
                  Color(0xff4facfe)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          /// Floating Emojis
          ...List.generate(emojis.length, (i) {
            return AnimatedBuilder(
              animation: controller,
              builder: (_, child) {

                double offset = sin(controller.value * 2 * pi + i) * 15;

                return Positioned(
                  left: 30 + i * 40,
                  top: 80 + offset,
                  child: Text(
                    emojis[i],
                    style: const TextStyle(fontSize: 26),
                  ),
                );
              },
            );
          }),

          /// Floating Shapes
          ...List.generate(shapes.length, (i) {
            return AnimatedBuilder(
              animation: controller,
              builder: (_, child) {

                double rotate = controller.value * 2 * pi;

                return Positioned(
                  right: 20 + i * 30,
                  bottom: 80 + (i % 3) * 100,
                  child: Transform.rotate(
                    angle: rotate,
                    child: Opacity(
                      opacity: .4,
                      child: Text(
                        shapes[i],
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          /// Main content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: 360,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                        blurRadius: 20,
                        color: Colors.black26
                    )
                  ],
                ),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    /// Back button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: back,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text("Back"),
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// Step emoji
                    Text(
                      ['🎒','👨‍👩‍👧','🎯'][step],
                      style: const TextStyle(fontSize: 40),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      [
                        "Tell us about you!",
                        "Parent's Info",
                        "What interests you?"
                      ][step],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      "Step ${step+1} of 3",
                      style: const TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 20),

                    /// Progress bar
                    Row(
                      children: List.generate(3, (i) {
                        return Expanded(
                          child: Container(
                            height: 10,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: i <= step
                                  ? const LinearGradient(
                                  colors: [
                                    Colors.purple,
                                    Colors.blue
                                  ])
                                  : null,
                              color: i > step ? Colors.grey[200] : null,
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 20),

                    /// STEP 1
                    if(step == 0)...[

                      TextField(
                        decoration: const InputDecoration(
                            labelText: "🧒 Your Name"
                        ),
                        onChanged: (v)=>form["name"]=v,
                      ),

                      const SizedBox(height:10),

                      TextField(
                        decoration: const InputDecoration(
                            labelText: "🎂 Age"
                        ),
                        onChanged:(v)=>form["age"]=v,
                      ),

                      const SizedBox(height:10),

                      DropdownButtonFormField(
                        items: ['5','6','7','8','9','10','11','12']
                            .map((g)=>DropdownMenuItem(
                            value:g,
                            child:Text("Grade $g")
                        )).toList(),
                        onChanged:(v)=>form["grade"]=v,
                        decoration: const InputDecoration(
                            labelText: "📚 Grade"
                        ),
                      ),

                      const SizedBox(height:10),

                      TextField(
                        decoration: const InputDecoration(
                            labelText: "🏫 School Name"
                        ),
                        onChanged:(v)=>form["school"]=v,
                      ),
                    ],

                    /// STEP 2
                    if(step == 1)...[

                      TextField(
                        decoration: const InputDecoration(
                            labelText: "👤 Parent Name"
                        ),
                        onChanged:(v)=>form["parentName"]=v,
                      ),

                      const SizedBox(height:10),

                      TextField(
                        decoration: const InputDecoration(
                            labelText: "📱 Phone"
                        ),
                        onChanged:(v)=>form["parentPhone"]=v,
                      ),

                      const SizedBox(height:10),

                      TextField(
                        decoration: const InputDecoration(
                            labelText: "📧 Parent Email"
                        ),
                        onChanged:(v)=>form["parentEmail"]=v,
                      ),

                    ],

                    /// STEP 3
                    if(step == 2)...[

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "What do you want to learn? 🎯",
                          style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),

                      const SizedBox(height:10),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: interests.map((i){

                          bool selected =
                          form["interests"].contains(i);

                          return GestureDetector(
                            onTap: ()=>toggleInterest(i),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal:14,vertical:10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: selected
                                    ? Colors.purple[100]
                                    : Colors.grey[100],
                                border: Border.all(
                                    color: selected
                                        ? Colors.purple
                                        : Colors.grey.shade300
                                ),
                              ),
                              child: Text(
                                i,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: selected
                                        ? Colors.purple
                                        : Colors.black54
                                ),
                              ),
                            ),
                          );

                        }).toList(),
                      )

                    ],

                    const SizedBox(height:20),

                    /// Next Button
                    GestureDetector(
                      onTap: nextStep,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical:16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                                colors: [
                                  Color(0xff667eea),
                                  Color(0xfff093fb)
                                ]
                            )
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            if(step < 2)
                              const Text(
                                "Next Step",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize:18
                                ),
                              ),

                            if(step == 2)
                              const Text(
                                "Start Learning!",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize:18
                                ),
                              ),

                            const SizedBox(width:8),

                            Icon(
                              step < 2
                                  ? Icons.arrow_forward
                                  : Icons.check_circle,
                              color: Colors.white,
                            )
                          ],
                        ),
                      ),
                    )

                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
