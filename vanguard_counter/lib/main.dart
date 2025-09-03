import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vanguard Power Counter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
      ),
      home: const VanguardCounter(),
    );
  }
}

class VanguardCounter extends StatefulWidget {
  const VanguardCounter({super.key});

  @override
  _VanguardCounterState createState() => _VanguardCounterState();
}

class _VanguardCounterState extends State<VanguardCounter> {
  List<int> powers = List.generate(6, (index) => 0);
  List<int> basePowers = List.generate(6, (index) => 0);
  int gZoneCount = 0;
  bool showLabels = false;

  void _updatePower(int index, int value) {
    setState(() => powers[index] += value);
  }

  void _setBasePower(int index, int basePower) {
    setState(() {
      basePowers[index] = basePower;
      powers[index] = basePower;

      // If this is Vanguard or front row, apply G-Zone bonus if it exists
      if (index == 0 || index == 1 || index == 3) {
        powers[index] += gZoneCount * 5000;
      }
    });
  }

  void _updateFrontRow(int value) {
    setState(() {
      // Update Rearguard1 (index 1), Vanguard (index 0), and Rearguard2 (index 3)
      powers[1] += value;
      powers[0] += value;
      powers[3] += value;
    });
  }

  void _updateBackRow(int value) {
    setState(() {
      // Update Rearguard3 (index 4), Rearguard4 (index 2), and Rearguard5 (index 5)
      powers[4] += value;
      powers[2] += value;
      powers[5] += value;
    });
  }

  void _resetPowers() {
    setState(() {
      powers = List.generate(6, (index) => 0);
      basePowers = List.generate(6, (index) => 0);
      gZoneCount = 0;
    });
  }

  void _toggleLabels() {
    setState(() {
      showLabels = !showLabels;
    });
  }

  void _showBasePowerModal(int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[900],
          child: Column(
            children: [
              const Text(
                'Select Base Power',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), // Disable GridView scrolling
                crossAxisCount: 3, // 3 columns
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: [
                  for (int power in [3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000, 11000, 12000, 13000])
                    ElevatedButton(
                      onPressed: () {
                        _setBasePower(index, power);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // Rectangular buttons
                        ),
                      ),
                      child: Text(
                        '$power',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCustomPowerModal(int index, bool isBasePower) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isBasePower ? 'Set Base Power' : 'Enter Power Change'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              final value = int.tryParse(controller.text) ?? 0;
              if (isBasePower) {
                _setBasePower(index, value);
              } else {
                _updatePower(index, value);
              }
              Navigator.pop(context);
            },
            child: const Text('Confirm'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _attackMode(int column) {
    int totalPower = 0;
    if (column == 1) {
      totalPower = powers[4] + powers[1];
    } else if (column == 2) {
      totalPower = powers[0] + powers[2];
    } else if (column == 3) {
      totalPower = powers[5] + powers[3];
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Attack Power'),
        content: Text('Total Power: $totalPower'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _gZoneModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[900],
          child: Column(
            children: [
              Text(
                'G-Zone: $gZoneCount (Power +${gZoneCount * 5000})',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), // Disable GridView scrolling
                crossAxisCount: 4, // 4 columns
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: [
                  for (int i = 0; i <= 16; i++)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          gZoneCount = i;
                          // Update front row powers (Vanguard and front rearguards)
                          powers[0] = basePowers[0] + (gZoneCount * 5000);
                          powers[1] = basePowers[1] + (gZoneCount * 5000);
                          powers[3] = basePowers[3] + (gZoneCount * 5000);
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gZoneCount == i ? Colors.blue : Colors.grey[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // Rectangular buttons
                        ),
                      ),
                      child: Text(
                        '$i',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageSize = MediaQuery.of(context).size.width / 5;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 10,
            left: 10,
            child: Row(
              children: [
                IconButton(
                  onPressed: _gZoneModal,
                  icon: const Icon(Icons.star, color: Colors.white),
                ),
                Text(
                  'G-Zone: $gZoneCount',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              onPressed: _toggleLabels,
              icon: Icon(
                showLabels ? Icons.visibility : Icons.visibility_off,
                color: Colors.white,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildRearguard(1, imageSize, 'Rearguard1'),
                      _buildVanguard(imageSize),
                      _buildRearguard(3, imageSize, 'Rearguard2'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildRearguard(4, imageSize, 'Rearguard3'),
                      _buildRearguard(2, imageSize, 'Rearguard4'),
                      _buildRearguard(5, imageSize, 'Rearguard5'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 4,
                        child: _buildColumnButtons(1),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 4,
                        child: _buildColumnButtons(2),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 4,
                        child: _buildColumnButtons(3),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildRowButtons(true),
                      _buildRowButtons(false),
                    ],
                  ),
                  const SizedBox(height: 2),
                  ElevatedButton(onPressed: _resetPowers, child: const Text('Reset')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVanguard(double size) {
    return GestureDetector(
      onTap: () => _showBasePowerModal(0),
      onLongPress: () => _showCustomPowerModal(0, true),
      child: Column(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage('assets/vanguard.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Text(
            '${powers[0]}',
            style: const TextStyle(color: Colors.white),
          ),
          if (showLabels)
            const Text('Vanguard', style: TextStyle(color: Colors.white)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove, color: Colors.white),
                onPressed: () => _updatePower(0, -1000),
                onLongPress: () => _showCustomPowerModal(0, false),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () => _updatePower(0, 1000),
                onLongPress: () => _showCustomPowerModal(0, false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRearguard(int index, double size, String label) {
    return GestureDetector(
      onTap: () => _showBasePowerModal(index),
      onLongPress: () => _showCustomPowerModal(index, true),
      child: Column(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage('assets/rearguard.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Text(
            '${powers[index]}',
            style: const TextStyle(color: Colors.white),
          ),
          if (showLabels)
            Text(label, style: const TextStyle(color: Colors.white)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove, color: Colors.white),
                onPressed: () => _updatePower(index, -1000),
                onLongPress: () => _showCustomPowerModal(index, false),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () => _updatePower(index, 1000),
                onLongPress: () => _showCustomPowerModal(index, false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColumnButtons(int column) {
    return ElevatedButton(
      onPressed: () => _attackMode(column),
      child: Text('Attack $column'),
    );
  }

  Widget _buildRowButtons(bool isFrontRow) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove, color: Colors.white),
          onPressed: () => isFrontRow ? _updateFrontRow(-1000) : _updateBackRow(-1000),
          onLongPress: () {
            final controller = TextEditingController();
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Enter Power Change'),
                content: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      final value = int.tryParse(controller.text) ?? 0;
                      if (isFrontRow) {
                        _updateFrontRow(-value);
                      } else {
                        _updateBackRow(-value);
                      }
                      Navigator.pop(context);
                    },
                    child: const Text('Confirm'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            );
          },
        ),
        Text(isFrontRow ? 'Front Row' : 'Back Row', style: const TextStyle(color: Colors.white)),
        IconButton(
          icon: const Icon(Icons.add, color: Colors.white),
          onPressed: () => isFrontRow ? _updateFrontRow(1000) : _updateBackRow(1000),
          onLongPress: () {
            final controller = TextEditingController();
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Enter Power Change'),
                content: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      final value = int.tryParse(controller.text) ?? 0;
                      if (isFrontRow) {
                        _updateFrontRow(value);
                      } else {
                        _updateBackRow(value);
                      }
                      Navigator.pop(context);
                    },
                    child: const Text('Confirm'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}