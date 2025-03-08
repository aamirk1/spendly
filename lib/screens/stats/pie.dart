import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:spendly/controllers/expenseController.dart';

class MyPieChart extends StatefulWidget {
  const MyPieChart({super.key});

  @override
  _MyPieChartState createState() => _MyPieChartState();
}

class _MyPieChartState extends State<MyPieChart> {
  final ExpenseController controller = Get.find<ExpenseController>();
  var selectedFilter = 'Monthly'.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchChartExpenseTotals(selectedFilter.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.categoryTotals.isEmpty) {
        return const Center(child: Text("No expenses to display"));
      }
      return Column(
        mainAxisSize: MainAxisSize.min, // 🛠 Prevents unnecessary expansion
        children: [
          // 🔹 Row for Legends and Pie Chart
          Row(
            children: [
              // 🔹 Legends (Left Side)
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: controller.expenseCategories.map((category) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(category['icon'],
                                color: category['color'], size: 18),
                            const SizedBox(width: 6),
                            Text(category['name'],
                                style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // 🔹 Pie Chart (Right Side)
              Expanded(
                flex: 2,
                child: AspectRatio(
                  aspectRatio: 1, // 🛠 Ensures Pie Chart doesn't stretch
                  child: PieChart(mainPieData()),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  PieChartData mainPieData() {
    return PieChartData(
      sections: showingPieSections(),
      sectionsSpace: 2,
      centerSpaceRadius: 28, // 🔹 Creates Donut Effect
      borderData: FlBorderData(show: false),
    );
  }

  List<PieChartSectionData> showingPieSections() {
    List<String> categories = controller.categoryTotals.keys.toList();
    List<double> values = controller.categoryTotals.values.toList();
    double total = values.fold(0, (sum, value) => sum + value);

    return List.generate(categories.length, (i) {
      Color color = _getCategoryColor(categories[i]);
      return PieChartSectionData(
        color: color,
        value: values[i],
        title: "${((values[i] / total) * 100).toStringAsFixed(1)}%",
        radius: 45,
        titleStyle: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    });
  }

  Color _getCategoryColor(String category) {
    final categoryData = controller.expenseCategories.firstWhere(
      (element) => element['name'] == category,
      orElse: () => {'color': Colors.grey},
    );
    return categoryData['color'];
  }
}
