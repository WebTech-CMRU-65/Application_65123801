import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class HabitTrackerPage extends StatefulWidget {
  const HabitTrackerPage({super.key});

  @override
  State<HabitTrackerPage> createState() => _HabitTrackerPageState();
}

class _HabitTrackerPageState extends State<HabitTrackerPage> {
  final user = FirebaseAuth.instance.currentUser!;

  // Firestore reference
  CollectionReference get habitRef => FirebaseFirestore.instance
      .collection("users")
      .doc(user.uid)
      .collection("habits");

  // Predefined habits
  final List<Map<String, dynamic>> predefinedHabits = [
    {
      'name': 'ดื่มน้ำ',
      'icon': Icons.water_drop,
      'color': Colors.blue,
      'target': 8, // 8 glasses per day
    },
    {
      'name': 'ออกกำลังกาย',
      'icon': Icons.fitness_center,
      'color': Colors.green,
      'target': 1, // 1 session per day
    },
    {
      'name': 'อ่านหนังสือ',
      'icon': Icons.menu_book,
      'color': Colors.orange,
      'target': 1, // 1 session per day
    },
  ];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayFormatted = DateFormat('yyyy-MM-dd').format(today);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tracker'),
        backgroundColor: const Color(0xFF0FB5AE),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0FB5AE), Color(0xFF60D6CB), Color(0xFFB3F0EA)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Today's habits section
              Expanded(
                flex: 2,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'กิจวัตรวันนี้ ($todayFormatted)',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(child: _buildTodayHabitsList()),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Statistics section
              Expanded(
                flex: 3,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'สถิติ 7 วันล่าสุด',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(child: _buildIndividualCharts()),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayHabitsList() {
    return ListView.builder(
      itemCount: predefinedHabits.length,
      itemBuilder: (context, index) {
        final habit = predefinedHabits[index];
        return _buildTodayHabitCard(habit);
      },
    );
  }

  Widget _buildTodayHabitCard(Map<String, dynamic> habit) {
    final today = DateTime.now();
    final todayKey = _getDateKey(today);

    return StreamBuilder<DocumentSnapshot>(
      stream: habitRef.doc('${habit['name']}_$todayKey').snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final currentCount = data?['count'] ?? 0;
        final target = habit['target'] as int;
        final progress = currentCount / target;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: habit['color'].withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(habit['icon'], color: habit['color'], size: 20),
              ),
              const SizedBox(width: 12),

              // Habit info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$currentCount/$target',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress >= 1.0 ? Colors.green : habit['color'],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Controls
              Row(
                children: [
                  GestureDetector(
                    onTap: currentCount > 0
                        ? () =>
                              _updateHabitCount(habit['name'], currentCount - 1)
                        : null,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: currentCount > 0
                            ? Colors.red[100]
                            : Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.remove,
                        size: 16,
                        color: currentCount > 0
                            ? Colors.red[700]
                            : Colors.grey[400],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$currentCount',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () =>
                        _updateHabitCount(habit['name'], currentCount + 1),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: habit['color'].withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.add, size: 16, color: habit['color']),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIndividualCharts() {
    return ListView.builder(
      itemCount: predefinedHabits.length,
      itemBuilder: (context, index) {
        final habit = predefinedHabits[index];
        return _buildHabitChart(habit);
      },
    );
  }

  Widget _buildHabitChart(Map<String, dynamic> habit) {
    return StreamBuilder<QuerySnapshot>(
      stream: habitRef.where('habitName', isEqualTo: habit['name']).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return SizedBox(
            height: 120,
            child: Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}')),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        final chartData = _prepareHabitChartData(docs, habit);

        return Container(
          height: 120,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              // Icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: habit['color'].withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(habit['icon'], color: habit['color'], size: 16),
              ),
              const SizedBox(width: 12),

              // Chart
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            if (value == 0) {
                              return const Text(
                                '0%',
                                style: TextStyle(fontSize: 10),
                              );
                            }
                            if (value == 1) {
                              return const Text(
                                '100%',
                                style: TextStyle(fontSize: 10),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 20,
                          getTitlesWidget: (value, meta) {
                            final dayIndex = value.toInt();
                            if (dayIndex >= 0 && dayIndex < 7) {
                              final date = DateTime.now().subtract(
                                Duration(days: 6 - dayIndex),
                              );
                              return Text(
                                DateFormat('E', 'th').format(date),
                                style: const TextStyle(fontSize: 10),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: chartData,
                        isCurved: true,
                        color: habit['color'],
                        barWidth: 2,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 3,
                              color: habit['color'],
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                    minY: 0,
                    maxY: 1,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateHabitCount(String habitName, int newCount) async {
    final today = DateTime.now();
    final todayKey = _getDateKey(today);
    final docId = '${habitName}_$todayKey';

    await habitRef.doc(docId).set({
      'habitName': habitName,
      'count': newCount,
      'date': Timestamp.fromDate(today),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  List<FlSpot> _prepareHabitChartData(
    List<QueryDocumentSnapshot> docs,
    Map<String, dynamic> habit,
  ) {
    final spots = <FlSpot>[];
    final today = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dateKey = _getDateKey(date);
      final docId = '${habit['name']}_$dateKey';

      // Find the document for this habit and date
      final matchingDocs = docs.where((d) => d.id == docId).toList();

      double progress = 0.0;
      if (matchingDocs.isNotEmpty) {
        final doc = matchingDocs.first;
        final data = doc.data() as Map<String, dynamic>;
        final count = data['count'] ?? 0;
        final target = habit['target'] as int;
        progress = (count / target).clamp(0.0, 1.0);
      }

      spots.add(FlSpot((6 - i).toDouble(), progress));
    }

    return spots;
  }

  String _getDateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Timestamp _getStartOfWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return Timestamp.fromDate(
      DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
    );
  }

  Timestamp _getEndOfWeek() {
    final now = DateTime.now();
    final endOfWeek = now.add(Duration(days: 7 - now.weekday));
    return Timestamp.fromDate(
      DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59),
    );
  }
}
