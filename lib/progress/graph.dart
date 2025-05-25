import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meditation_app/api_service.dart';

// Color Constants
class AppColors {
  static const Color primary = Color(0xFF00695C); // Green accent color
  static const Color primaryLight = Color(0xFF00695C);
  static const Color primaryDark = Color(0xFF4DB6AC);
  static const Color background = Color(0xFFF0F4F8);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textLight = Color(0xFF6B7280);
}

class ProgressScreen extends StatefulWidget {
  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  DateTime? _selectedDate;
  Map<String, Map<String, dynamic>> usageData = {};
  Timer? _weeklySyncTimer;

  Map<DateTime, List<Map<String, dynamic>>> get markedDates {
    return usageData.map((key, value) {
      DateTime parsedDate = DateTime.parse(key);
      if (parsedDate.isBefore(DateTime(2025, 1, 1)) || parsedDate.isAfter(DateTime(2025, 12, 31))) {
        return MapEntry(parsedDate, []);
      }
      return MapEntry(parsedDate, [value]);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUsageData().then((_) {
      _fetchProgressFromDatabase().then((remoteData) {
        if (remoteData.isEmpty && usageData.isNotEmpty) {
          _syncProgress();
        }
      });
    });
    _scheduleWeeklySync();
  }

  @override
  void dispose() {
    _weeklySyncTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUsageData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('userId') ?? 'guest';
    final daysUsedKey = 'days_used_$uid';
    List<String> daysUsed = prefs.getStringList(daysUsedKey) ?? [];
    Map<String, Map<String, dynamic>> fetchedData = {};

    for (var day in daysUsed) {
      final dailyUsageKey = "usage_${uid}_$day";
      int seconds = prefs.getInt(dailyUsageKey) ?? 0;
      double hours = (seconds / 3600.0).toDouble();
      fetchedData[day] = {"hours": hours, "activity": "Pranayama"};
    }

    setState(() {
      usageData = fetchedData;
    });
  }

  int _calculateMaxStreak() {
    if (usageData.isEmpty) return 0;
    List<DateTime> dates = usageData.keys.map((key) => DateTime.parse(key)).toList();
    dates.sort((a, b) => a.compareTo(b));

    int maxStreak = 1;
    int currentStreak = 1;
    for (int i = 1; i < dates.length; i++) {
      if (dates[i].difference(dates[i - 1]).inDays == 1) {
        currentStreak++;
        if (currentStreak > maxStreak) maxStreak = currentStreak;
      } else {
        currentStreak = 1;
      }
    }
    return maxStreak;
  }

  void _scheduleWeeklySync() {
    _weeklySyncTimer = Timer.periodic(Duration(days: 7), (timer) {
      _syncProgress();
    });
  }

  Future<void> _syncProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('userId') ?? 'guest';
    try {
      await updateProgresses(uid, usageData);
      await _clearUsageData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Progress synced successfully")),
        );
      }
    } catch (e) {
      print("Error syncing progress: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to sync progress: $e")),
        );
      }
    }
  }

  Future<void> _clearUsageData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('userId') ?? 'guest';
    final daysUsedKey = 'days_used_$uid';
    final List<String> daysUsed = prefs.getStringList(daysUsedKey) ?? [];
    for (final day in daysUsed) {
      final dailyUsageKey = "usage_${uid}_$day";
      await prefs.remove(dailyUsageKey);
    }
    await prefs.remove(daysUsedKey);

    setState(() {
      usageData.clear();
    });
  }

  Future<Map<String, Map<String, dynamic>>> _fetchProgressFromDatabase() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('userId') ?? 'guest';
      Map<String, Map<String, dynamic>> remoteData = await fetchProgressData(uid);
      // Convert hours to double for each entry in remoteData
      remoteData = remoteData.map((key, value) => MapEntry(
          key,
          Map<String, dynamic>.from(value)
            ..update('hours', (v) => v is int ? v.toDouble() : (v as num).toDouble(), ifAbsent: () => 0.0)));
      setState(() {
        usageData = {...remoteData, ...usageData};
      });
      return remoteData;
    } catch (e) {
      print("Error fetching progress: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch progress: $e")),
        );
      }
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalHours = usageData.values.fold<double>(
      0,
          (sum, item) {
        var hours = item["hours"];
        return sum + (hours is int ? hours.toDouble() : (hours as double? ?? 0.0));
      },
    );

    final dataList = usageData.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primaryDark,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Your Progress",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Track your consistency and growth",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  _buildStatsSection(totalHours),
                  SizedBox(height: 24),
                  _buildCalendarSection(),
                  SizedBox(height: 24),
                  if (_selectedDate != null) _buildSelectedDateInfo(),
                  SizedBox(height: 24),
                  _buildGraphSection(dataList),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(double totalHours) {
    int maxStreak = _calculateMaxStreak();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.calendar_today, "${usageData.length}", "Days"),
          _buildStatItem(Icons.timeline, "$maxStreak", "Max Streak"),
          _buildStatItem(Icons.access_time, "${totalHours.toStringAsFixed(1)}", "Hours"),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primaryDark,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textLight,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                "Activity Calendar",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          TableCalendar(
            firstDay: DateTime(2025, 1, 1),
            lastDay: DateTime(2025, 12, 31),
            focusedDay: _selectedDate ?? DateTime.now(),
            selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
              });
            },
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: AppColors.primaryDark,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              defaultTextStyle: TextStyle(color: AppColors.textDark),
              weekendTextStyle: TextStyle(color: AppColors.textDark),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                color: AppColors.textDark,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.primaryDark),
              rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.primaryDark),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: AppColors.textLight),
              weekendStyle: TextStyle(color: AppColors.textLight),
            ),
            eventLoader: (date) => markedDates[date] ?? [],
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, date, focusedDay) {
                String formattedDate =
                    "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                if (usageData.containsKey(formattedDate)) {
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDateInfo() {
    final selectedDateStr = _selectedDate!.toLocal().toString().split(' ')[0];
    final data = usageData[selectedDateStr];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                "Selected Day Summary",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textLight,
                      ),
                    ),
                    Text(
                      data != null
                          ? "${(data['hours'] is int ? data['hours'].toDouble() : (data['hours'] as double? ?? 0.0)).toStringAsFixed(1)} hours of ${data['activity']}"
                          : "No activity recorded",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraphSection(List<MapEntry<String, Map<String, dynamic>>> dataList) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.show_chart, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                "Consistency Over Time",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            height: 200,
            child: dataList.isEmpty
                ? Center(child: Text("No data available", style: TextStyle(color: AppColors.textLight)))
                : LineChart(
              LineChartData(
                minX: 0,
                maxX: dataList.length - 1,
                minY: 0,
                maxY: dataList.isNotEmpty
                    ? (dataList.map((e) {
                  var hours = e.value['hours'];
                  return hours is int ? hours.toDouble() : (hours as double? ?? 0.0);
                }).reduce((a, b) => a > b ? a : b) +
                    1)
                    : 5,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 1,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[200],
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: Colors.grey[200],
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < dataList.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              dataList[index].key.split("-")[2],
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textLight,
                              ),
                            ),
                          );
                        }
                        return Container();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textLight,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      dataList.length,
                          (index) {
                        var hours = dataList[index].value['hours'];
                        return FlSpot(
                          index.toDouble(),
                          hours is int ? hours.toDouble() : (hours as double? ?? 0.0),
                        );
                      },
                    ),
                    isCurved: true,
                    color: AppColors.primaryDark,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.primary,
                          strokeColor: Colors.white,
                          strokeWidth: 2,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.3),
                          AppColors.primary.withOpacity(0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}