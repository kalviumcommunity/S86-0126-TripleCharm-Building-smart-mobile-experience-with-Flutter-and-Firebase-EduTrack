import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/theme.dart';
import '../../providers/class_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/marks_provider.dart';
import '../../services/database_service.dart';

class ReportsScreen extends StatefulWidget {
  final String classId;
  final String className;

  const ReportsScreen({required this.classId, required this.className, super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<_ResolvedTopStudent> _resolvedTop = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<AttendanceProvider>().getClassAttendanceSummary(widget.classId);
      if (!mounted) return;
      context.read<MarksProvider>().loadClassMarks(widget.classId);
      
      final marksProvider = context.read<MarksProvider>();
      final tops = marksProvider.topStudents;
      final List<_ResolvedTopStudent> resolved = [];
      for (var t in tops) {
        try {
          final name = await DatabaseService.getStudentName(t.name);
          if (!mounted) return;
          resolved.add(_ResolvedTopStudent(name: name ?? t.name, percentage: t.percentage));
        } catch (_) {
          resolved.add(_ResolvedTopStudent(name: t.name, percentage: t.percentage));
        }
      }
      if (!mounted) return;
      setState(() {
        _resolvedTop = resolved;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = context.watch<AttendanceProvider>();
    final marksProvider = context.watch<MarksProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Reports - ${widget.className}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exporting report as PDF...')),
              );
            },
            tooltip: 'Export PDF',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Preparing report share...')),
              );
            },
            tooltip: 'Share',
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Overview', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildStatsGrid(context, attendanceProvider, marksProvider),
            const SizedBox(height: 24),
            
            Text('Attendance Analytics', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildAttendanceChart(attendanceProvider),
            const SizedBox(height: 24),

            Text('Performance Analytics', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildPerformanceChart(marksProvider),
            const SizedBox(height: 24),

            Text('Top Performers', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildTopPerformersCard(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, AttendanceProvider attendance, MarksProvider marks) {
    return GridView.count(
      crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _ReportCard(
          title: 'Avg. Attendance',
          value: '${(attendance.classAveragePercent ?? 0.0).toStringAsFixed(1)}%',
          color: AppTheme.successColor,
          icon: Icons.check_circle_outline,
        ),
        _ReportCard(
          title: 'Avg. Marks %',
          value: '${marks.classAveragePercent.toStringAsFixed(1)}%',
          color: AppTheme.accentColor,
          icon: Icons.grade_outlined,
        ),
        _ReportCard(
          title: 'Total Students',
          value: context.watch<ClassProvider>().selectedClass?.studentCount?.toString() ?? '0',
          color: AppTheme.primaryColor,
          icon: Icons.people_outline,
        ),
      ],
    );
  }

  Widget _buildAttendanceChart(AttendanceProvider provider) {
    final total = provider.totalPresent + provider.totalAbsent;
    if (total == 0) {
      return const Card(child: Padding(padding: EdgeInsets.all(32), child: Center(child: Text('No attendance data available'))));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 200,
          child: Row(
            children: [
              Expanded(
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: [
                      PieChartSectionData(
                        color: AppTheme.successColor,
                        value: provider.totalPresent.toDouble(),
                        title: '${((provider.totalPresent / total) * 100).toStringAsFixed(0)}%',
                        radius: 50,
                        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      PieChartSectionData(
                        color: AppTheme.errorColor,
                        value: provider.totalAbsent.toDouble(),
                        title: '${((provider.totalAbsent / total) * 100).toStringAsFixed(0)}%',
                        radius: 50,
                        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegend(AppTheme.successColor, 'Present (${provider.totalPresent})'),
                  const SizedBox(height: 8),
                  _buildLegend(AppTheme.errorColor, 'Absent (${provider.totalAbsent})'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceChart(MarksProvider provider) {
    final distribution = provider.gradeDistribution;
    final maxVal = distribution.values.isEmpty ? 0 : distribution.values.reduce((a, b) => a > b ? a : b);
    
    if (maxVal == 0) {
      return const Card(child: Padding(padding: EdgeInsets.all(32), child: Center(child: Text('No marks data available'))));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 250,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: (maxVal + 1).toDouble(),
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const titles = ['A', 'B', 'C', 'D', 'F'];
                      return Text(titles[value.toInt()]);
                    },
                  ),
                ),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: [
                _buildBarGroup(0, distribution['A']!.toDouble(), AppTheme.successColor),
                _buildBarGroup(1, distribution['B']!.toDouble(), Colors.lightGreen),
                _buildBarGroup(2, distribution['C']!.toDouble(), AppTheme.warningColor),
                _buildBarGroup(3, distribution['D']!.toDouble(), Colors.orange),
                _buildBarGroup(4, distribution['F']!.toDouble(), AppTheme.errorColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 25,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildTopPerformersCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            if (_resolvedTop.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No performance data yet'),
              )
            else
              ..._resolvedTop.map((s) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryLight,
                      child: Text(s.name.isNotEmpty ? s.name[0].toUpperCase() : '?', style: TextStyle(color: AppTheme.primaryColor)),
                    ),
                    title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: s.percentage >= 70 ? AppTheme.successColor.withValues(alpha: 0.1) : AppTheme.warningColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${s.percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: s.percentage >= 70 ? AppTheme.successColor : AppTheme.warningColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _ReportCard({required this.title, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ResolvedTopStudent {
  final String name;
  final double percentage;
  _ResolvedTopStudent({required this.name, required this.percentage});
}
