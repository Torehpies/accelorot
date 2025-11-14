// lib/services/firestore/firestore_fetch.dart
import 'package:flutter_application_1/frontend/operator/activity_logs/models/activity_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_collections.dart';
import 'package:flutter/material.dart';
//ignore: unused_import
import 'firestore_helpers.dart';

class FirestoreFetch {
  /// Validate that userId is provided (should never be null from service layer)
  // ignore: unused_element
  static String _validateUserId(String? userId) {
    if (userId == null || userId.isEmpty) {
      throw Exception(
        'User ID must be provided. This is a programming error - FirestoreActivityService should always resolve the user ID before calling fetch methods.',
      );
    }
    return userId;
  }

  static String _resolveUserId(String? userId) {
    if (userId == null || userId.isEmpty) {
      throw Exception('User ID must be provided');
    }
    return userId;
  }

  // Fetch Substrates - filtered by userId or teamId (using machine->team relationship)
  static Future<List<ActivityItem>> getSubstrates([
    String? targetUserId,
  ]) async {
    try {
      final userId = _resolveUserId(targetUserId);

      // ⭐ Get user's teamId to fetch team-wide activities
      String? teamId;
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          teamId = userDoc.data()?['teamId'] as String?;
        }
      } catch (e) {
        debugPrint('Error fetching user teamId: $e');
      }

      List<ActivityItem> allSubstrates = [];

      if (teamId != null && teamId.isNotEmpty) {
        // ⭐ Fetch team machines first, then get batches for those machines
        debugPrint('🔍 Fetching team-wide substrates for teamId: $teamId');

        // Get all machines belonging to this team
        final machinesSnapshot = await FirebaseFirestore.instance
            .collection('machines')
            .where('teamId', isEqualTo: teamId)
            .get();

        final teamMachineIds = machinesSnapshot.docs
            .map((doc) => doc.id)
            .toList();

        if (teamMachineIds.isNotEmpty) {
          // Get all batches for these machines
          final batchesSnapshot =
              await FirestoreCollections.getBatchesCollection()
                  .where('machineId', whereIn: teamMachineIds)
                  .get();

          // Fetch substrates from each batch
          for (var batchDoc in batchesSnapshot.docs) {
            final batchData = batchDoc.data() as Map<String, dynamic>?;
            final batchUserId = batchData?['userId'] as String?;

            if (batchUserId != null) {
              try {
                final substratesSnapshot =
                    await FirestoreCollections.getSubstratesCollection(
                      batchDoc.id,
                      batchUserId,
                    ).get();

                final substrates = substratesSnapshot.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return ActivityItem.fromMap(data);
                }).toList();

                allSubstrates.addAll(substrates);
              } catch (e) {
                debugPrint(
                  'Error fetching substrates from batch ${batchDoc.id}: $e',
                );
              }
            }
          }
        }
      } else {
        // Fallback: Get only current user's batches
        final batchesSnapshot =
            await FirestoreCollections.getBatchesCollection()
                .where('userId', isEqualTo: userId)
                .get();

        for (var batchDoc in batchesSnapshot.docs) {
          final substratesSnapshot =
              await FirestoreCollections.getSubstratesCollection(
                batchDoc.id,
                userId,
              ).get();

          final substrates = substratesSnapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return ActivityItem.fromMap(data);
          }).toList();

          allSubstrates.addAll(substrates);
        }
      }

      // Sort all substrates by timestamp
      allSubstrates.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      debugPrint(
        '✅ Fetched ${allSubstrates.length} substrates for ${teamId != null ? "team: $teamId" : "user: $userId"}',
      );

      return allSubstrates;
    } catch (e) {
      debugPrint('Error fetching substrates: $e');
      rethrow;
    }
  }

  // Fetch Alerts - filtered by userId or teamId (from batch subcollection)
  static Future<List<ActivityItem>> getAlerts([String? targetUserId]) async {
    try {
      final userId = _resolveUserId(targetUserId);

      // ⭐ Get user's teamId to fetch team-wide activities
      String? teamId;
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          teamId = userDoc.data()?['teamId'] as String?;
        }
      } catch (e) {
        debugPrint('Error fetching user teamId: $e');
      }

      List<ActivityItem> allAlerts = [];

      if (teamId != null && teamId.isNotEmpty) {
        // ⭐ Fetch team machines first, then get batches for those machines
        debugPrint('🔍 Fetching team-wide alerts for teamId: $teamId');

        // Get all machines belonging to this team
        final machinesSnapshot = await FirebaseFirestore.instance
            .collection('machines')
            .where('teamId', isEqualTo: teamId)
            .get();

        final teamMachineIds = machinesSnapshot.docs
            .map((doc) => doc.id)
            .toList();

        if (teamMachineIds.isNotEmpty) {
          // Get all batches for these machines
          final batchesSnapshot =
              await FirestoreCollections.getBatchesCollection()
                  .where('machineId', whereIn: teamMachineIds)
                  .get();

          // ⭐ Fetch alerts from each batch's alerts subcollection
          for (var batchDoc in batchesSnapshot.docs) {
            try {
              final alertsSnapshot = await FirebaseFirestore.instance
                  .collection('batches')
                  .doc(batchDoc.id)
                  .collection('alerts')
                  .get();

              final alerts = alertsSnapshot.docs.map((doc) {
                final data = doc.data();
                return ActivityItem.fromMap(data);
              }).toList();

              allAlerts.addAll(alerts);
            } catch (e) {
              debugPrint('Error fetching alerts from batch ${batchDoc.id}: $e');
            }
          }
        }
      } else {
        // Fallback: Get only current user's batches
        final batchesSnapshot =
            await FirestoreCollections.getBatchesCollection()
                .where('userId', isEqualTo: userId)
                .get();

        for (var batchDoc in batchesSnapshot.docs) {
          try {
            final alertsSnapshot = await FirebaseFirestore.instance
                .collection('batches')
                .doc(batchDoc.id)
                .collection('alerts')
                .get();

            final alerts = alertsSnapshot.docs.map((doc) {
              final data = doc.data();
              return ActivityItem.fromMap(data);
            }).toList();

            allAlerts.addAll(alerts);
          } catch (e) {
            debugPrint('Error fetching alerts from batch ${batchDoc.id}: $e');
          }
        }
      }

      // Sort all alerts by timestamp
      allAlerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      debugPrint(
        '✅ Fetched ${allAlerts.length} alerts for ${teamId != null ? "team: $teamId" : "user: $userId"}',
      );

      return allAlerts;
    } catch (e) {
      debugPrint('Error fetching alerts: $e');
      rethrow;
    }
  }

  // Fetch Cycles and Recommendations - filtered by userId or teamId (from batch subcollection)
  static Future<List<ActivityItem>> getCyclesRecom([
    String? targetUserId,
  ]) async {
    try {
      final userId = _resolveUserId(targetUserId);

      // ⭐ Get user's teamId to fetch team-wide activities
      String? teamId;
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          teamId = userDoc.data()?['teamId'] as String?;
        }
      } catch (e) {
        debugPrint('Error fetching user teamId: $e');
      }

      List<ActivityItem> allCycles = [];

      if (teamId != null && teamId.isNotEmpty) {
        // ⭐ Fetch team machines first, then get batches for those machines
        debugPrint('🔍 Fetching team-wide cycles for teamId: $teamId');

        // Get all machines belonging to this team
        final machinesSnapshot = await FirebaseFirestore.instance
            .collection('machines')
            .where('teamId', isEqualTo: teamId)
            .get();

        final teamMachineIds = machinesSnapshot.docs
            .map((doc) => doc.id)
            .toList();

        if (teamMachineIds.isNotEmpty) {
          // Get all batches for these machines
          final batchesSnapshot =
              await FirestoreCollections.getBatchesCollection()
                  .where('machineId', whereIn: teamMachineIds)
                  .get();

          // ⭐ Fetch cycles from each batch's cyclesRecom subcollection
          for (var batchDoc in batchesSnapshot.docs) {
            try {
              final cyclesSnapshot = await FirebaseFirestore.instance
                  .collection('batches')
                  .doc(batchDoc.id)
                  .collection('cyclesRecom')
                  .get();

              final cycles = cyclesSnapshot.docs.map((doc) {
                final data = doc.data();
                return ActivityItem.fromMap(data);
              }).toList();

              allCycles.addAll(cycles);
            } catch (e) {
              debugPrint('Error fetching cycles from batch ${batchDoc.id}: $e');
            }
          }
        }
      } else {
        // Fallback: Get only current user's batches
        final batchesSnapshot =
            await FirestoreCollections.getBatchesCollection()
                .where('userId', isEqualTo: userId)
                .get();

        for (var batchDoc in batchesSnapshot.docs) {
          try {
            final cyclesSnapshot = await FirebaseFirestore.instance
                .collection('batches')
                .doc(batchDoc.id)
                .collection('cyclesRecom')
                .get();

            final cycles = cyclesSnapshot.docs.map((doc) {
              final data = doc.data();
              return ActivityItem.fromMap(data);
            }).toList();

            allCycles.addAll(cycles);
          } catch (e) {
            debugPrint('Error fetching cycles from batch ${batchDoc.id}: $e');
          }
        }
      }

      // Sort all cycles by timestamp
      allCycles.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      debugPrint(
        '✅ Fetched ${allCycles.length} cycles for ${teamId != null ? "team: $teamId" : "user: $userId"}',
      );

      return allCycles;
    } catch (e) {
      debugPrint('Error fetching cycles: $e');
      rethrow;
    }
  }

  /// Fetch all reports from all machines the user can access
  static Future<List<ActivityItem>> getReports([String? targetUserId]) async {
    try {
      // Fetch all machines (reports are stored per machine)
      final machinesSnapshot = await FirebaseFirestore.instance
          .collection('machines')
          .get();

      List<ActivityItem> allReports = [];

      // Fetch reports from each machine
      for (var machineDoc in machinesSnapshot.docs) {
        try {
          final reportsSnapshot = await FirebaseFirestore.instance
              .collection('machines')
              .doc(machineDoc.id)
              .collection('reports')
              .orderBy('createdAt', descending: true)
              .get();

          final reports = reportsSnapshot.docs.map((doc) {
            final data = doc.data();

            // Map report fields to ActivityItem
            return ActivityItem(
              title: FirestoreHelpers.getReportTypeLabel(
                data['reportType'],
              ), // "Maintenance Issue", "Safety Concern"
              value: _capitalizeFirst(
                data['status'] ?? 'unknown',
              ), // "Open" or "Resolved"
              statusColor: FirestoreHelpers.colorIntToString(
                data['statusColor'] ?? 0xFF9E9E9E,
              ),
              icon: FirestoreHelpers.getIconFromCodePoint(data['icon'] ?? 0),
              category: FirestoreHelpers.getReportTypeLabel(data['reportType']),
              timestamp: (data['createdAt'] as Timestamp).toDate(),
              machineId: data['machineId'],
              description: _buildReportDescription(data),
            );
          }).toList();

          allReports.addAll(reports);
        } catch (e) {
          debugPrint('Error fetching reports for machine ${machineDoc.id}: $e');
          // Continue to next machine even if one fails
        }
      }

      // Sort all reports by timestamp
      allReports.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      debugPrint('✅ Fetched ${allReports.length} reports across all machines');

      return allReports;
    } catch (e) {
      debugPrint('❌ Error fetching reports: $e');
      rethrow;
    }
  }

  /// Helper: Capitalize first letter
  static String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Helper: Build report description - cleaner format matching substrate style
  static String _buildReportDescription(Map<String, dynamic> data) {
    final parts = <String>[];

    // Add description text if exists
    if (data['description'] != null &&
        data['description'].toString().isNotEmpty) {
      parts.add(data['description']);
    }

    // Add machine and reporter info at bottom
    if (data['machineName'] != null) {
      parts.add('Machine: ${data['machineName']}');
    }

    if (data['userName'] != null) {
      parts.add('By: ${data['userName']}');
    }

    return parts.join('\n');
  }

  // Fetch All Activities Combined (substrates + alerts + cycles only, excluding reports)
  static Future<List<ActivityItem>> getAllActivities([
    String? targetUserId,
  ]) async {
    try {
      final userId = _resolveUserId(targetUserId);

      // Fetch all collections in parallel (excluding reports)
      final results = await Future.wait([
        getSubstrates(userId),
        getAlerts(userId),
        getCyclesRecom(userId),
      ]);

      // Combine all lists
      final allActivities = <ActivityItem>[
        ...results[0], // substrates
        ...results[1], // alerts
        ...results[2], // cycles
      ];

      // Sort by timestamp descending
      allActivities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      debugPrint(
        '✅ Fetched ${allActivities.length} total activities for user: $userId',
      );
      debugPrint('   - ${results[0].length} substrates');
      debugPrint('   - ${results[1].length} alerts');
      debugPrint('   - ${results[2].length} cycles');

      if (allActivities.isNotEmpty) {
        final first = allActivities.first;
        debugPrint(
          '   First activity: ${first.isReport ? "REPORT" : "WASTE"} - ${first.title}',
        );
      }

      return allActivities;
    } catch (e) {
      debugPrint('❌ Error fetching all activities: $e');
      rethrow;
    }
  }
}
