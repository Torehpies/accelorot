// lib/ui/landing_page/models/step_model.dart

class StepModel {
  final int number;
  final String title;
  final String description;

  StepModel({
    required this.number,
    required this.title,
    required this.description,
  });

  // Updated sample data based on the image content
  static List<StepModel> getSampleSteps() {
    return [
      StepModel(
        number: 1,
        title: 'Add Organic Waste',
        description: 'Simply add your greens (nitrogen-rich), browns (carbon-rich), and starter compost into the rotary drum.',
      ),
      StepModel(
        number: 2,
        title: 'Smart Monitoring',
        description: 'IoT sensors continuously track temperature, moisture, and air quality—adjusting conditions automatically.',
      ),
      StepModel(
        number: 3,
        title: 'AI Recommendations',
        description: 'Receive intelligent suggestions on moisture levels, aeration frequency, and optimal harvest timing.',
      ),
      StepModel(
        number: 4,
        title: 'Harvest Quality Compost',
        description: 'In just 14 days, collect mature, nutrient-rich compost safe for gardens and agriculture.',
      ),
    ];
  }
}