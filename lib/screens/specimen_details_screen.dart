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

  @override
  void initState() {
    super.initState();
    loadPatient();
  }

  // --------------------------------------------------
  // LOAD ASSOCIATED PATIENT
  // --------------------------------------------------

  Future<void> loadPatient() async {
    try {
      final patients =
      await AppDatabase.instance.getPatients();

      Patient? associated;

      for (final record in patients) {
        if (record.id ==
            widget.specimen.patientLocalId) {
          associated = record;
          break;
        }
      }

      if (!mounted) return;

      setState(() {
        patient = associated;
        loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to load associated patient: $error',
          ),
        ),
      );
    }
  }

  // --------------------------------------------------
  // OPEN LABORATORY STAGE FORM
  // --------------------------------------------------

  Future<void> openLaboratoryStage(
      LaboratoryStageDefinition stage,
      ) async {
    final saved = await Navigator.push<bool>(
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

    if (saved == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${stage.name} form preview saved '
                'temporarily.',
          ),
          backgroundColor: teal,
        ),
      );
    }
  }

  // --------------------------------------------------
  // SPECIMEN INFORMATION ROW
  // --------------------------------------------------

  Widget detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
      ),
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

  // --------------------------------------------------
  // LABORATORY STAGE ROW
  // --------------------------------------------------

  Widget buildLaboratoryStage(
      LaboratoryStageDefinition stage,
      bool isLast,
      ) {
    final hasPreview =
    LaboratoryFormDrafts.hasDraft(
      widget.specimen.id,
      stage.id,
    );

    final hasFields = stage.fields.isNotEmpty;

    String status;

    if (hasPreview) {
      status = 'Form preview entered';
    } else if (!hasFields) {
      status = 'Form fields not configured';
    } else {
      status = 'Tap to open form';
    }

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => openLaboratoryStage(stage),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 8,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------------------------------------
            // STAGE ICON AND TIMELINE CONNECTOR
            // ------------------------------------------

            Column(
              children: [
                CircleAvatar(
                  radius: 21,
                  backgroundColor: hasPreview
                      ? const Color(0xFFE0F2F1)
                      : const Color(0xFFF1F5F9),
                  child: Icon(
                    hasPreview
                        ? Icons.edit_note
                        : stage.icon,
                    color: hasPreview
                        ? teal
                        : Colors.grey,
                    size: 21,
                  ),
                ),

                if (!isLast)
                  Container(
                    width: 2,
                    height: 34,
                    color: const Color(0xFFE2E8F0),
                  ),
              ],
            ),

            const SizedBox(width: 14),

            // ------------------------------------------
            // STAGE NAME AND STATUS
            // ------------------------------------------

            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 5,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      stage.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      status,
                      style: TextStyle(
                        color: hasPreview
                            ? teal
                            : Colors.grey,
                        fontSize: 12,
                      ),
                    ),

                    if (hasPreview) ...[
                      const SizedBox(height: 4),
                      const Text(
                        'Tap to view or edit preview',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ------------------------------------------
            // OPEN FORM INDICATOR
            // ------------------------------------------

            const Padding(
              padding: EdgeInsets.only(top: 9),
              child: Icon(
                Icons.chevron_right,
                color: Colors.grey,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // LABORATORY JOURNEY
  // --------------------------------------------------

  Widget buildLaboratoryJourney() {
    final stages =
        LaboratoryStageCatalog.stages;

    return Card(
      color: Colors.white,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            for (var i = 0; i < stages.length; i++)
              buildLaboratoryStage(
                stages[i],
                i == stages.length - 1,
              ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // MAIN SCREEN
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final specimen = widget.specimen;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

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
          // --------------------------------------
          // SPECIMEN HEADER CARD
          // --------------------------------------

          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: teal,
              borderRadius:
              BorderRadius.circular(22),
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
                  textAlign: TextAlign.center,
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

          // --------------------------------------
          // SPECIMEN INFORMATION
          // --------------------------------------

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
                    specimen.collectedAt
                        .split('T')
                        .first,
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

          // --------------------------------------
          // ASSOCIATED PATIENT
          // --------------------------------------

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
                backgroundColor:
                Color(0xFFE0F2F1),
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
                    : 'Patient ID: '
                    '${patient!.patientId}',
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

          // --------------------------------------
          // LABORATORY JOURNEY HEADING
          // --------------------------------------

          const Text(
            'Laboratory journey',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Tap a laboratory stage to open '
                'its corresponding form.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 14),

          // --------------------------------------
          // LABORATORY STAGE FORMS
          // --------------------------------------

          buildLaboratoryJourney(),

          const SizedBox(height: 16),

          // --------------------------------------
          // PREVIEW NOTICE
          // --------------------------------------

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2F1),
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: const Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: teal,
                  size: 20,
                ),

                SizedBox(width: 10),

                Expanded(
                  child: Text(
                    'Laboratory forms are currently '
                        'in preview mode. Values entered '
                        'are kept temporarily in memory. '
                        'They are not yet saved to the '
                        'database or synchronized with DHIS2.',
                    style: TextStyle(
                      color: teal,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
