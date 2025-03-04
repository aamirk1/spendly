import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:spendly/controllers/expenseController.dart';
import 'dart:math';

class MyChart extends StatefulWidget {
  const MyChart({super.key});

  @override
  _MyChartState createState() => _MyChartState();
}

class _MyChartState extends State<MyChart> {
  final ExpenseController controller = Get.find<ExpenseController>();
  var selectedFilter = 'Monthly'.obs;

  @override
  @override
void initState() {
  super.initState();

  // Ensure fetchChartExpenseTotals runs after the first frame is built
  WidgetsBinding.instance.addPostFrameCallback((_) {
    controller.fetchChartExpenseTotals(selectedFilter.value);
  });
}


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            filterButton('Weekly'),
            filterButton('Monthly'),
            filterButton('Yearly'),
          ],
        ),
        const SizedBox(height: 5),

        // 🔹 Legend at the Top Right
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Wrap(
              spacing: 12,
              children: controller.expenseCategories.map((category) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(category['icon'], color: category['color'], size: 16),
                    const SizedBox(width: 4),
                    Text(category['name'],
                        style: const TextStyle(fontSize: 12)),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // 🔹 Bar Chart
        Expanded(
          child: Obx(() {
            if (controller.categoryTotals.isEmpty) {
              return const Center(child: Text("No expenses to display"));
            }
            return BarChart(mainBarData());
          }),
        ),
      ],
    );
  }

  Widget filterButton(String label) {
    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: ElevatedButton(
            onPressed: () {
              selectedFilter.value = label;
              controller.fetchChartExpenseTotals(label);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedFilter.value == label
                  ? Colors.blue.shade700 // Selected color
                  : Colors.grey.shade300, // Unselected color
              foregroundColor: selectedFilter.value == label
                  ? Colors.white
                  : Colors.black87, // Text color
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // Rounded corners
              ),
              elevation: selectedFilter.value == label ? 4 : 0, // Slight shadow
            ),
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ));
  }

  BarChartGroupData makeGroupData(int x, double y, Color color) {
    return BarChartGroupData(x: x, barRods: [
      BarChartRodData(
        toY: y,
        gradient: LinearGradient(
          colors: [color.withOpacity(0.7), color],
          transform: const GradientRotation(pi / 4),
        ),
        width: 10,
        backDrawRodData: BackgroundBarChartRodData(
          show: true,
          toY: y + 10,
          color: Colors.grey.shade300,
        ),
      )
    ]);
  }

  List<BarChartGroupData> showingGroups() {
    List<String> categories = controller.categoryTotals.keys.toList();
    List<double> values = controller.categoryTotals.values.toList();
    return List.generate(categories.length, (i) {
      Color color = _getCategoryColor(categories[i]);
      return makeGroupData(i, values[i], color);
    });
  }

  BarChartData mainBarData() {
    return BarChartData(
      titlesData: FlTitlesData(
        show: true,
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 38,
            getTitlesWidget: getCategoryTitle,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 38,
            getTitlesWidget: leftTitles,
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      gridData: const FlGridData(show: false),
      barGroups: showingGroups(),
    );
  }

  Widget getCategoryTitle(double value, TitleMeta meta) {
    List<String> categories = controller.categoryTotals.keys.toList();
    if (value.toInt() >= categories.length) return Container();

    String category = categories[value.toInt()];
    IconData icon = _getCategoryIcon(category);
    Color color = _getCategoryColor(category);

    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Icon(icon,
          color: color, size: 20), // 🔹 Icon now has a category color
    );
  }

  IconData _getCategoryIcon(String category) {
    final categoryData = controller.expenseCategories.firstWhere(
      (element) => element['name'] == category,
      orElse: () => {'icon': CupertinoIcons.question_circle_fill},
    );
    return categoryData['icon'];
  }

  Widget leftTitles(double value, TitleMeta meta) {
    return SideTitleWidget(
      space: 0,
      meta: meta,
      child: Text(
        "${value.toInt()}K",
        style: const TextStyle(
            color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    final categoryData = controller.expenseCategories.firstWhere(
      (element) => element['name'] == category,
      orElse: () => {'color': Colors.grey},
    );
    return categoryData['color'];
  }
}
