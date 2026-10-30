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

  // =====================================================
  // LABORATORY JOURNEY STAGES
  // =====================================================

  static const stages = [
    ('Specimen Dispatch', Icons.local_shipping_outlined),
    ('Lab Reception', Icons.inventory_2_outlined),
    ('Testing', Icons.biotech_outlined),
    ('Results', Icons.assignment_outlined),
    ('Results Release', Icons.verified_outlined),
    ('Results View', Icons.task_alt_outlined),
  ];

  // =====================================================
  // INITIALIZE
  // =====================================================

  @override
  void initState() {
    super.initState();
    loadPatient();
  }

  // =====================================================
  // LOAD ASSOCIATED PATIENT
  // ORIGINAL FUNCTION PRESERVED
  // =====================================================

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
  // NEW FUNCTION
  // =====================================================

  Future<void> openLaboratoryForm(int stageIndex) async {

    final stage = LaboratoryStageCatalog.stages[stageIndex];

    await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => LaboratoryStageFormScreen(
          specimenLocalId: widget.specimen.id,
          specimenId: widget.specimen.specimenId,
          stage: stage,
        ),
      ),
    );

    if (!mounted) return;

    // Refresh Laboratory Journey after returning.
    setState(() {});
  }

  // =====================================================
  // SPECIMEN DETAIL ROW
  // ORIGINAL FUNCTION PRESERVED
  // =====================================================

  Widget detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
              ),
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

  // =====================================================
  // MAIN SCREEN
  // =====================================================

  @override
  Widget build(BuildContext context) {

    final specimen = widget.specimen;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Specimen details'),
        backgroundColor: Colors.white,
      ),

      body: loading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : ListView(
        padding: const EdgeInsets.all(18),
        children: [

          // =====================================
          // SPECIMEN HEADER
          // ORIGINAL CODE
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
          // ORIGINAL CODE
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
          // ORIGINAL CODE
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
                  : const Icon(
                Icons.chevron_right,
              ),

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
          // ORIGINAL SECTION
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
            'Tap a laboratory stage to open its form.',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 14),

          // =====================================
          // LABORATORY JOURNEY CARD
          // SAME ORIGINAL STRUCTURE
          // =====================================

          Card(
            color: Colors.white,
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [

                  for (var i = 0; i < stages.length; i++)

                  // =================================
                  // NEW: CLICKABLE STAGE
                  // =================================

                    InkWell(
                      onTap: () {
                        openLaboratoryForm(i);
                      },

                      child: Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [

                          // ===========================
                          // ORIGINAL STAGE ICON
                          // ===========================

                          Column(
                            children: [

                              CircleAvatar(
                                radius: 20,
                                backgroundColor:
                                const Color(0xFFF1F5F9),
                                child: Icon(
                                  stages[i].$2,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                              ),

                              if (i < stages.length - 1)
                                Container(
                                  width: 2,
                                  height: 30,
                                  color: const Color(
                                    0xFFE2E8F0,
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(width: 14),

                          // ===========================
                          // STAGE NAME AND STATUS
                          // ===========================

                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 8,
                              ),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [

                                  Text(
                                    stages[i].$1,
                                    style: const TextStyle(
                                      fontWeight:
                                      FontWeight.w600,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  // =======================
                                  // STAGE PREVIEW STATUS
                                  // =======================

                                  Text(
                                    LaboratoryFormDrafts.hasDraft(
                                      specimen.id,
                                      LaboratoryStageCatalog
                                          .stages[i].id,
                                    )
                                        ? 'Local form preview saved'
                                        : 'Tap to open form',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // ===========================
                          // NAVIGATION INDICATOR
                          // ===========================

                          const Icon(
                            Icons.chevron_right,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ],
                      ),
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