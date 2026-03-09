import 'package:flutter/material.dart';

class SchoolBookingScreen extends StatefulWidget {
  const SchoolBookingScreen({super.key});

  @override
  State<SchoolBookingScreen> createState() => _SchoolBookingScreenState();
}

class _SchoolBookingScreenState extends State<SchoolBookingScreen> {

  String? mode;
  String? selectedDay;
  String? selectedSlot;
  String? selectedCourse;
  bool confirmed = false;

  final List<String> days = ["Mon","Tue","Wed","Thu","Fri","Sat"];

  final List<Map<String,dynamic>> timeSlots = [

    {
      "id":"morning1",
      "label":"🌅 Morning",
      "time":"9:00 AM – 10:30 AM",
      "available":true
    },

    {
      "id":"morning2",
      "label":"☀️ Late Morning",
      "time":"10:45 AM – 12:15 PM",
      "available":true
    },

    {
      "id":"afternoon1",
      "label":"🌤️ Afternoon",
      "time":"2:00 PM – 3:30 PM",
      "available":false
    },

    {
      "id":"afternoon2",
      "label":"🌇 Evening",
      "time":"3:45 PM – 5:15 PM",
      "available":true
    },

  ];

  final List<String> courses = [

    "Python for Kids",
    "Intro to AI",
    "Scratch Programming",
    "App Dev Basics",
    "Robotics",
    "Web Design"

  ];

  bool get canBook =>
      mode != null &&
          selectedDay != null &&
          selectedSlot != null &&
          selectedCourse != null;

  @override
  Widget build(BuildContext context) {

    if(confirmed){
      return _buildSuccess();
    }

    return Scaffold(

      backgroundColor: const Color(0xfff5f7ff),

      body: SafeArea(

        child: SingleChildScrollView(

          padding: const EdgeInsets.all(16),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              const Text(
                "📅 Book Your Class",
                style: TextStyle(
                    fontSize:24,
                    fontWeight: FontWeight.bold
                ),
              ),

              const SizedBox(height:4),

              const Text(
                "Choose your preferred time and mode",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height:20),

              /// STEP 1 COURSE
              _card(
                title: "1  Choose Course",
                child: Wrap(
                  spacing:8,
                  runSpacing:8,
                  children: courses.map((c){

                    final selected = selectedCourse==c;

                    return GestureDetector(
                      onTap:(){
                        setState(() {
                          selectedCourse=c;
                        });
                      },

                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal:12,vertical:10
                        ),

                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: selected
                                    ? Colors.purple
                                    : Colors.grey.shade300
                            ),
                            color: selected
                                ? Colors.purple.shade50
                                : Colors.grey.shade100
                        ),

                        child: Text(
                          c,
                          style: TextStyle(
                              color: selected
                                  ? Colors.purple
                                  : Colors.black87,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    );

                  }).toList(),
                ),
              ),

              const SizedBox(height:14),

              /// STEP 2 MODE
              _card(
                title: "2  Choose Mode",
                child: Row(
                  children: [

                    Expanded(
                      child: _modeButton(
                          "online",
                          "🌐 Online",
                          "Learn from home"
                      ),
                    ),

                    const SizedBox(width:10),

                    Expanded(
                      child: _modeButton(
                          "offline",
                          "🏫 Offline",
                          "Attend in person"
                      ),
                    ),

                  ],
                ),
              ),

              const SizedBox(height:14),

              /// STEP 3 DAY
              _card(
                title: "3  Choose Day",
                child: Wrap(
                  spacing:8,
                  children: days.map((d){

                    final selected = selectedDay==d;

                    return GestureDetector(

                      onTap:(){
                        setState(() {
                          selectedDay=d;
                        });
                      },

                      child: Container(

                        padding: const EdgeInsets.symmetric(
                            horizontal:16,
                            vertical:10
                        ),

                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: selected
                                    ? Colors.purple
                                    : Colors.grey.shade300
                            ),
                            color: selected
                                ? Colors.purple.shade100
                                : Colors.grey.shade100
                        ),

                        child: Text(
                          d,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    );

                  }).toList(),
                ),
              ),

              const SizedBox(height:14),

              /// STEP 4 TIME
              _card(
                title: "4  Choose Time Slot",
                child: Column(

                  children: timeSlots.map((slot){

                    final selected = selectedSlot==slot["id"];
                    final available = slot["available"];

                    return GestureDetector(

                      onTap: available
                          ? (){
                        setState(() {
                          selectedSlot=slot["id"];
                        });
                      }
                          : null,

                      child: Container(

                        margin: const EdgeInsets.only(bottom:10),
                        padding: const EdgeInsets.all(14),

                        decoration: BoxDecoration(

                            borderRadius: BorderRadius.circular(16),

                            border: Border.all(
                                color: selected
                                    ? Colors.purple
                                    : Colors.grey.shade300
                            ),

                            color: !available
                                ? Colors.grey.shade100
                                : selected
                                ? Colors.purple.shade50
                                : Colors.white
                        ),

                        child: Row(

                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,

                          children: [

                            Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [

                                Text(
                                  slot["label"],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold
                                  ),
                                ),

                                Text(
                                  slot["time"],
                                  style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize:12
                                  ),
                                ),

                              ],
                            ),

                            Text(
                              available
                                  ? "Available ✓"
                                  : "Full 🚫",
                              style: TextStyle(
                                  color: available
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize:12
                              ),
                            )

                          ],
                        ),
                      ),
                    );

                  }).toList(),
                ),
              ),

              const SizedBox(height:20),

              /// CONFIRM BUTTON
              SizedBox(
                width: double.infinity,

                child: ElevatedButton(

                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical:16),
                      backgroundColor: canBook
                          ? Colors.deepPurple
                          : Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)
                      )
                  ),

                  onPressed: canBook
                      ? (){
                    setState(() {
                      confirmed=true;
                    });
                  }
                      : null,

                  child: Text(
                    canBook
                        ? "🚀 Confirm Booking!"
                        : "Fill all details above",
                    style: const TextStyle(
                        fontSize:18,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }

  Widget _modeButton(String value,String title,String subtitle){

    final selected = mode==value;

    return GestureDetector(

      onTap:(){
        setState(() {
          mode=value;
        });
      },

      child: Container(

        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: selected
                    ? Colors.blue
                    : Colors.grey.shade300
            ),
            color: selected
                ? Colors.blue.shade50
                : Colors.white
        ),

        child: Column(
          children: [

            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold
                )),

            const SizedBox(height:4),

            Text(
              subtitle,
              style: const TextStyle(
                  fontSize:12,
                  color: Colors.grey
              ),
              textAlign: TextAlign.center,
            )

          ],
        ),
      ),
    );
  }

  Widget _card({required String title, required Widget child}){

    return Container(

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200)
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            title,
            style: const TextStyle(
                fontWeight: FontWeight.bold
            ),
          ),

          const SizedBox(height:12),

          child

        ],
      ),
    );
  }

  Widget _buildSuccess(){

    return Scaffold(

      backgroundColor: const Color(0xfff5f7ff),

      body: Center(

        child: Container(

          padding: const EdgeInsets.all(24),

          margin: const EdgeInsets.all(20),

          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24)
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              const Text("🎉",style: TextStyle(fontSize:60)),

              const SizedBox(height:10),

              const Text(
                "Booking Confirmed!",
                style: TextStyle(
                    fontSize:22,
                    fontWeight: FontWeight.bold
                ),
              ),

              const SizedBox(height:10),

              Text(selectedCourse ?? ""),

              Text(selectedDay ?? ""),

              const SizedBox(height:20),

              ElevatedButton(

                onPressed: (){
                  setState(() {
                    confirmed=false;
                  });
                },

                child: const Text("Book Another Class"),
              )

            ],
          ),
        ),
      ),
    );
  }
}
