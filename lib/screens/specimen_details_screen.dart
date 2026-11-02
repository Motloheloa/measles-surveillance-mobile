import 'package:flutter/material.dart';

import '../database/app_database.dart';
import '../models/patient.dart';
import '../models/specimen.dart';
import 'patient_details_screen.dart';
import 'laboratory_stage_form_screen.dart';

class SpecimenDetailsScreen extends StatefulWidget {
  final Specimen specimen;

  const SpecimenDetailsScreen({
    super.key,
    required this.specimen,
  });

  @override
  State<SpecimenDetailsScreen> createState() =>
      _SpecimenDetailsScreenState();
}

class _SpecimenDetailsScreenState
    extends State<SpecimenDetailsScreen> {
  static const teal = Color(0xFF0F766E);

  Patient? patient;
  bool loading = true;

  static const stages = [
    ('Specimen Dispatch', Icons.local_shipping_outlined),
    ('Lab Reception', Icons.inventory_2_outlined),
    ('Testing', Icons.biotech_outlined),
    ('Results', Icons.assignment_outlined),
    ('Results Release', Icons.verified_outlined),
    ('Results View', Icons.task_alt_outlined),
  ];

  @override
  void initState() {
    super.initState();
    loadPatient();
  }

  Future<void> loadPatient() async {
    final patients = await AppDatabase.instance.getPatients();

    Patient? associated;

    for (final record in patients) {
      if (record.id == widget.specimen.patientLocalId) {
        associated = record;
        break;
      }
    }

    if (!mounted) return;

    setState(() {
      patient = associated;
      loading = false;
    });
  }

  // =====================================================
  // OPEN LABORATORY FORM
  // =====================================================

  Future<void> openLaboratoryForm(int stageIndex) async {
    final specimenLocalId = widget.specimen.id;

    final catalog = LaboratoryStageCatalog.stages;

    final canOpen = LaboratoryFormDrafts.canOpen(
      specimenLocalId,
      stageIndex,
    );

    if (!canOpen) {
      final firstIncomplete = catalog.indexWhere(
            (stage) => !LaboratoryFormDrafts.isComplete(
          specimenLocalId,
          stage,
        ),
      );

      if (firstIncomplete != -1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Complete ${catalog[firstIncomplete].name} '
                  'before proceeding.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }

      return;
    }

    final stage = catalog[stageIndex];

    await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => LaboratoryStageFormScreen(
          specimenLocalId: specimenLocalId,
          specimenId: widget.specimen.specimenId,
          stage: stage,
        ),
      ),
    );

    if (!mounted) return;

    setState(() {});
  }

  Widget detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final specimen = widget.specimen;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Specimen details'),
        backgroundColor: Colors.white,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // =====================================
          // SPECIMEN HEADER
          // =====================================

          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: teal,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.science_outlined,
                  color: Colors.white,
                  size: 44,
                ),

                const SizedBox(height: 12),

                Text(
                  specimen.specimenId,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  specimen.sampleType,
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 12),

                Chip(
                  label: Text(
                    specimen.syncStatus == 'pending'
                        ? 'Saved offline · Pending sync'
                        : specimen.syncStatus,
                  ),
                  backgroundColor: Colors.white,
                  side: BorderSide.none,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // =====================================
          // SPECIMEN INFORMATION
          // =====================================

          const Text(
            'Specimen information',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Card(
            color: Colors.white,
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              child: Column(
                children: [
                  detailRow(
                    'Specimen ID',
                    specimen.specimenId,
                  ),

                  const Divider(height: 1),

                  detailRow(
                    'Sample type',
                    specimen.sampleType,
                  ),

                  const Divider(height: 1),

                  detailRow(
                    'Collection date',
                    specimen.collectedAt.split('T').first,
                  ),

                  const Divider(height: 1),

                  detailRow(
                    'Sync status',
                    specimen.syncStatus,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // =====================================
          // ASSOCIATED PATIENT
          // =====================================

          const Text(
            'Associated patient',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Card(
            color: Colors.white,
            elevation: 0,
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE0F2F1),
                child: Icon(
                  Icons.person_outline,
                  color: teal,
                ),
              ),
              title: Text(
                patient?.fullName ??
                    'Patient unavailable',
              ),
              subtitle: Text(
                patient == null
                    ? 'Associated patient not found'
                    : 'Patient ID: ${patient!.patientId}',
              ),
              trailing: patient == null
                  ? null
                  : const Icon(Icons.chevron_right),
              onTap: patient == null
                  ? null
                  : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PatientDetailsScreen(
                          patient: patient!,
                        ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // =====================================
          // LABORATORY JOURNEY
          // =====================================

          const Text(
            'Laboratory journey',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Complete each laboratory stage '
                'to unlock the next stage.',
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 14),

          Card(
            color: Colors.white,
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  for (var i = 0; i < stages.length; i++)
                    Builder(
                      builder: (context) {
                        final stage =
                        LaboratoryStageCatalog.stages[i];

                        final completed =
                        LaboratoryFormDrafts.isComplete(
                          specimen.id,
                          stage,
                        );

                        final unlocked =
                        LaboratoryFormDrafts.canOpen(
                          specimen.id,
                          i,
                        );

                        return InkWell(
                          onTap: () => openLaboratoryForm(i),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                            ),
                            child: Row(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: completed
                                          ? const Color(0xFFD1FAE5)
                                          : const Color(0xFFF1F5F9),
                                      child: Icon(
                                        completed
                                            ? Icons.check_circle
                                            : unlocked
                                            ? stages[i].$2
                                            : Icons.lock_outline,
                                        color: completed
                                            ? const Color(0xFF059669)
                                            : unlocked
                                            ? teal
                                            : Colors.grey,
                                        size: 22,
                                      ),
                                    ),

                                    if (i < stages.length - 1)
                                      Container(
                                        width: 2,
                                        height: 35,
                                        color: completed
                                            ? const Color(0xFF059669)
                                            : const Color(0xFFE2E8F0),
                                      ),
                                  ],
                                ),

                                const SizedBox(width: 14),

                                Expanded(
                                  child: Padding(
                                    padding:
                                    const EdgeInsets.only(top: 2),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Stage ${i + 1}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),

                                        const SizedBox(height: 4),

                                        Text(
                                          stages[i].$1,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                            color: unlocked
                                                ? const Color(0xFF123047)
                                                : Colors.grey,
                                          ),
                                        ),

                                        const SizedBox(height: 5),

                                        Text(
                                          completed
                                              ? 'Completed'
                                              : unlocked
                                              ? 'Pending - Tap to complete'
                                              : 'Locked - Complete previous stage',
                                          style: TextStyle(
                                            color: completed
                                                ? const Color(0xFF059669)
                                                : Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                Padding(
                                  padding:
                                  const EdgeInsets.only(top: 12),
                                  child: Icon(
                                    completed
                                        ? Icons.check_circle
                                        : unlocked
                                        ? Icons.chevron_right
                                        : Icons.lock_outline,
                                    color: completed
                                        ? const Color(0xFF059669)
                                        : Colors.grey,
                                    size: 22,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}