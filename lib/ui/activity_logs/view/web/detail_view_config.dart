// lib/ui/activity_logs/view/detail_view_config.dart

import 'package:intl/intl.dart';
import '../../../../data/models/activity_log_item.dart';

/// Configuration for detail views based on activity type
class DetailViewConfig {
  static ViewConfig getConfig(ActivityLogItem item) {
    switch (item.type) {
      case ActivityType.report:
        return ViewConfig(
          title: 'View Report',
          subtitle: 'View in-depth information about this report.',
          heightRatio: 0.7,
          fields: [
            RowFields(
              field1: SingleField('Title', (i) => i.title),
              field2: SingleField('Priority Level', (i) => i.priority ?? 'N/A'),
            ),
            RowFields(
              field1: SingleField('Category', (i) => i.category),
              field2: SingleField('Submitted By', (i) => i.operatorName ?? 'Unknown'),
            ),
            RowFields(
              field1: SingleField('Machine Name', (i) => i.machineName ?? 'N/A'),
              field2: SingleField('Remarks', (i) => i.status ?? 'N/A'),
            ),
            SingleField('Description', (i) => i.description, isMultiline: true),
            SingleField(
              'Date Added',
              (i) => DateFormat('MM/dd/yyyy, hh:mm a').format(i.timestamp),
            ),
          ],
        );

      case ActivityType.alert:
        return ViewConfig(
          title: 'View Alert',
          subtitle: 'View in-depth information about this alert.',
          heightRatio: 0.6,
          fields: [
            SingleField('Category', (i) => i.category),
            SingleField('Machine Name', (i) => i.machineName ?? 'N/A'),
            SingleField('Measurement Value', (i) => i.value),
            SingleField('Description', (i) => i.description, isMultiline: true),
            SingleField(
              'Date Added',
              (i) => DateFormat('MM/dd/yyyy, hh:mm a').format(i.timestamp),
            ),
          ],
        );

      case ActivityType.substrate:
        return ViewConfig(
          title: 'View Substrate',
          subtitle: 'View in-depth information about this substrate.',
          heightRatio: 0.7,
          fields: [
            SingleField('Title', (i) => i.title),
            RowFields(
              field1: SingleField('Category', (i) => i.category),
              field2: SingleField('Quantity (kg)', (i) => i.value),
            ),
            SingleField('Machine Name', (i) => i.machineName ?? 'N/A'),
            SingleField('Description', (i) => i.description, isMultiline: true),
            SingleField('Submitted By', (i) => i.operatorName ?? 'Unknown'),
            SingleField(
              'Date Added',
              (i) => DateFormat('MM/dd/yyyy, hh:mm a').format(i.timestamp),
            ),
          ],
        );

      case ActivityType.cycle:
        final isRecommendation = item.category.toLowerCase() == 'recoms';
        return ViewConfig(
          title: isRecommendation ? 'View Recommendation' : 'View Cycle',
          subtitle: isRecommendation
              ? 'View in-depth information about this AI recommendation.'
              : 'View in-depth information about this composting cycle.',
          heightRatio: 0.6,
          fields: [
            SingleField('Title', (i) => i.title),
            SingleField('Category', (i) => i.category),
            SingleField('Machine Name', (i) => i.machineName ?? 'N/A'),
            SingleField('Description', (i) => i.description, isMultiline: true),
            SingleField(
              'Date Added',
              (i) => DateFormat('MM/dd/yyyy, hh:mm a').format(i.timestamp),
            ),
          ],
        );
    }
  }
}

/// View configuration container
class ViewConfig {
  final String title;
  final String subtitle;
  final double heightRatio;
  final List<dynamic> fields; // Can be SingleField or RowFields

  ViewConfig({
    required this.title,
    required this.subtitle,
    required this.heightRatio,
    required this.fields,
  });
}

/// Single field configuration
class SingleField {
  final String label;
  final String Function(ActivityLogItem) getValue;
  final bool isMultiline;

  SingleField(this.label, this.getValue, {this.isMultiline = false});
}

/// Two fields in a row configuration
class RowFields {
  final SingleField field1;
  final SingleField field2;

  RowFields({required this.field1, required this.field2});
}