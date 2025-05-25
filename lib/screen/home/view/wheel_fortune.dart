import 'package:project_skripsi/api/api.dart';
import 'package:project_skripsi/utils/local_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'dart:convert';

class SpiningWheel extends StatefulWidget {
  const SpiningWheel({super.key});

  @override
  State<SpiningWheel> createState() => _SpiningWheel();
}

class _SpiningWheel extends State<SpiningWheel>
    with SingleTickerProviderStateMixin {
  // Data
  List<double> sectors = [
    100,
    1750,
    2500,
    500,
    2000,
    1250,
    200,
    750,
    1500,
    1000
  ]; // sectors on the wheel
  int randomSectorIndex = -1; // any index on sectors
  List<double> sectorRadians = []; // sector degrees/radians
  double angle = 0; // angle in radians to spin
  bool isLoggedIn = false;

  // Other data
  bool spinning = false; // whether currently spinning or not
  int earnedValue = 0; // currently earned value
  double totalEarnings = 0; // all earnings in total
  int spins = 0; // number of times of spinning so far
  int chances = 0; // number of chances the user has to spin

  // Random object to help generate any random int
  math.Random random = math.Random();

  // Spin animation controller
  late AnimationController controller;
  // Animation
  late Animation<double> animation;

  // Initial setup
  @override
  void initState() {
    super.initState();

    // Fetch chance from LocalData
    _getIsLoggedIn();
    _getChance();

    // Generate sector radians / fill the list
    generateSectorRadians();

    // Animation controller
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600), // 3.6 sec
    );

    // The tween
    Tween<double> tween = Tween<double>(begin: 0, end: 1);

    // The curve behavior
    CurvedAnimation curve = CurvedAnimation(
      parent: controller,
      curve: Curves.decelerate,
    );

    // Animation tween
    animation = tween.animate(curve);

    // Rebuild the screen as animation continues
    controller.addListener(() {
      // Only when animation complete
      if (controller.isCompleted) {
        // Rebuild
        setState(() {
          // Record stats
          // Update status bool
          spinning = false;
        });
        // Show pop-up with the earned value after 4 seconds
        earnedValue =
            (sectors[sectors.length - (randomSectorIndex + 1)]).toInt();
        _showWinDialog();
      }
    });
  }

  // Dispose controller after use
  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  Future<void> _getIsLoggedIn() async {
    final data = await LocalData.getDataBool('isLoggedIn');
    setState(() {
      isLoggedIn = data;
    });
  }

  // Fetch chances from LocalData
  Future<void> _getChance() async {
    int chance = isLoggedIn ? int.parse(await LocalData.getData('chance')) : 0;
    setState(() {
      chances = chance;
    });
  }

  // Build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown,
      body: _body(),
    );
  }

  // Body
  Widget _body() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
              "https://i.pinimg.com/736x/e7/3a/b8/e73ab8cbf6752d9523558f9c2c63da78.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: _SpiningContent(), // Content
    );
  }

  Widget _SpiningContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _spiningTitle(),
          SizedBox(height: 10),
          _spiningWheel(),
          SizedBox(height: 10),
          _chanceRemaining(), // Display remaining chances
        ],
      ),
    );
  }

  Widget _spiningWheel() {
    return Center(
      child: Container(
        padding: const EdgeInsets.only(top: 20, left: 5),
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: const BoxDecoration(
            image: DecorationImage(
          fit: BoxFit.contain,
          image: AssetImage("assets/images/belt.png"),
        )),
        // Use animated builder for spinning
        child: InkWell(
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Transform.rotate(
                angle: controller.value *
                    angle, //  angle and controller value in action
                child: Container(
                  margin:
                      EdgeInsets.all(MediaQuery.of(context).size.width * 0.07),
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                    fit: BoxFit.contain,
                    image: AssetImage("assets/images/wheelrupiah.png"),
                  )),
                ),
              );
            },
          ),
          onTap: () {
            // If not spinning and there are chances left, spin
            setState(() {
              if (isLoggedIn) {
                if (!spinning && chances > 0) {
                  spin(); // A method to spin the wheel
                  spinning = true; // Now spinning status
                  chances--; // Decrease the chances
                  LocalData.saveData(
                      'chance', chances.toString()); // Save the updated chances
                } else if (chances == 0) {
                  // Show a message if no chances left
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Kesempatan Untuk Wheel of Fortune sudah habis!')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Harap Login Terlebih Dahulu')));
              }
            });
          },
        ),
      ),
    );
  }

  // Spinning title
  Widget _spiningTitle() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.only(top: 70),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: Border.all(
            color: CupertinoColors.systemYellow,
            width: 2,
          ),
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 91, 0, 107),
              Color.fromARGB(255, 235, 42, 203),
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: const Text(
          "Wheel Undian",
          style: TextStyle(
            fontSize: 40,
            color: CupertinoColors.systemYellow,
          ),
        ),
      ),
    );
  }

  Widget _chanceRemaining() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Text(
        "Remaining Chances: $chances",
        style: TextStyle(
          fontSize: 20,
          color: CupertinoColors.systemYellow,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void generateSectorRadians() {
    // Radian for 1 sector
    double sectorRadian = 2 * math.pi / sectors.length; // ie.360 degrees = 2xpi

    // Fill the radians list
    for (int i = 0; i < sectors.length; i++) {
      sectorRadians.add((i + 1) * sectorRadian);
    }
  }

  void spin() {
    // Spinning here
    randomSectorIndex =
        random.nextInt(sectors.length); // get random sector index
    double randomRadian = generateRandomRadianToSpinTo();
    controller.reset(); // reset any previous values
    angle = randomRadian;
    controller.forward(); // spin
  }

  double generateRandomRadianToSpinTo() {
    return (2 * math.pi * sectors.length) + sectorRadians[randomSectorIndex];
  }

  // Show a pop-up dialog with the winning value
  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Congratulations!"),
          content: Text("You Won: ${(earnedValue)} Point"),
          actions: [
            TextButton(
              onPressed: () async {
                if (await LocalData.containsKey('point')) {
                  final poin = await LocalData.getData('point');
                  final totalPoin = earnedValue + int.parse(poin);
                  LocalData.saveData('point', totalPoin.toString());
                  LocalData.saveData('max_point', totalPoin.toString());
                }
                Navigator.of(context).pop(); // Close the pop-up
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );

    _updatePointsInDatabase();
  }

  Future<void> _updatePointsInDatabase() async {
    try {
      final username =
          await LocalData.getData('user'); // Replace with actual user ID
      int points = earnedValue; // Calculate points to send to the server
      // Define the URL for the PHP script
      final String url = '${API.BASE_URL}'; // Replace with your actual URL

      // Send data to the server
      final response = await API.basePost(
          '/earn_point.php',
          {
            'username': username,
            'points': points,
          },
          {'Content-Type': 'application/json'},
          true,
          (result, error) {});
    } catch (e) {
      print('Error updating points: $e');
    }
  }
}
