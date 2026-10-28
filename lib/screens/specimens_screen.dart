
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../models/patient.dart';
import '../models/specimen.dart';
import 'specimen_details_screen.dart';

class SpecimensScreen extends StatefulWidget {
  const SpecimensScreen({super.key});

  @override
  State<SpecimensScreen> createState() => _SpecimensScreenState();
}

class _SpecimensScreenState extends State<SpecimensScreen> {
  List<Specimen> specimens = [];
  List<Patient> patients = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadRecords();
  }

  Future<void> loadRecords() async {
    final db = AppDatabase.instance;
    final loadedSpecimens = await db.getSpecimens();
    final loadedPatients = await db.getPatients();

    if (!mounted) return;

    setState(() {
      specimens = loadedSpecimens;
      patients = loadedPatients;
      loading = false;
    });
  }

  String patientName(String id) {
    for (final patient in patients) {
      if (patient.id == id) return patient.fullName;
    }
    return 'Unknown patient';
  }


  Future<void> registerSpecimen() async {
    await loadRecords();

    if (!mounted) return;

    if (patients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Register a patient before collecting a specimen.',
          ),
        ),
      );
      return;
    }

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => SpecimenRegistrationSheet(
        patients: patients,
      ),
    );

    if (saved == true && mounted) {
      await loadRecords();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Specimens')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: registerSpecimen,
        icon: const Icon(Icons.add),
        label: const Text('Collect specimen'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : specimens.isEmpty
          ? const Center(
        child: Text('No specimens saved on this device yet.'),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: specimens.length,
        itemBuilder: (context, index) {
          final specimen = specimens[index];

          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.science_outlined),
              ),
              title: Text(specimen.specimenId),
              subtitle: Text(
                '${patientName(specimen.patientLocalId)} · '
                    '${specimen.sampleType}',
              ),
              trailing: const Chip(label: Text('Pending')),


              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SpecimenDetailsScreen(
                      specimen: specimen,
                    ),
                  ),
                );
              },


            ),
          );
        },
      ),
    );
  }
}




class SpecimenRegistrationSheet extends StatefulWidget {
  final List<Patient> patients;
  final String? initialPatientId;

  const SpecimenRegistrationSheet({
    super.key,
    required this.patients,
    this.initialPatientId,
  });

  @override
  State<SpecimenRegistrationSheet> createState() =>
      _SpecimenRegistrationSheetState();
}



class _SpecimenRegistrationSheetState
    extends State<SpecimenRegistrationSheet> {
  final formKey = GlobalKey<FormState>();
  final specimenId = TextEditingController();

  String? selectedPatient;
  String sampleType = 'SERUM';
  DateTime collectedAt = DateTime.now();
  bool saving = false;
  @override
  void initState() {
    super.initState();
    selectedPatient = widget.initialPatientId;
  }

  @override
  void dispose() {
    specimenId.dispose();
    super.dispose();
  }

  String formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> save() async {
    if (saving || !formKey.currentState!.validate()) return;

    final patientId = selectedPatient;
    if (patientId == null) return;

    setState(() => saving = true);

    try {
      final record = Specimen(
        id: const Uuid().v4(),
        specimenId: specimenId.text.trim(),
        patientLocalId: patientId,
        sampleType: sampleType,
        collectedAt: collectedAt.toIso8601String(),
        syncStatus: 'pending',
        createdAt: DateTime.now().toUtc().toIso8601String(),
      );

      await AppDatabase.instance.insertSpecimen(record);

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: FractionallySizedBox(
        heightFactor: 0.85,
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Collect specimen',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Each specimen must be linked to a patient.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: specimenId,
                decoration: const InputDecoration(
                  labelText: 'Specimen ID',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Specimen ID is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 14),

              DropdownButtonFormField<String>(
                value: selectedPatient,
                decoration: const InputDecoration(
                  labelText: 'Associated patient',
                  border: OutlineInputBorder(),
                ),
                items: widget.patients.map((patient) {
                  return DropdownMenuItem(
                    value: patient.id,
                    child: Text(
                      '${patient.fullName} (${patient.patientId})',
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: saving
                    ? null
                    : (value) {
                  setState(() => selectedPatient = value);
                },
                validator: (value) {
                  if (value == null) return 'Select a patient';
                  return null;
                },
              ),

              const SizedBox(height: 14),

              DropdownButtonFormField<String>(
                value: sampleType,
                decoration: const InputDecoration(
                  labelText: 'Sample type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'SERUM',
                    child: Text('Serum'),
                  ),
                  DropdownMenuItem(
                    value: 'THROAT',
                    child: Text('Throat swab'),
                  ),
                  DropdownMenuItem(
                    value: 'NASOPHARYNGEAL',
                    child: Text('Nasopharyngeal swab'),
                  ),
                  DropdownMenuItem(
                    value: 'URINE',
                    child: Text('Urine'),
                  ),
                ],
                onChanged: saving
                    ? null
                    : (value) {
                  if (value != null) {
                    setState(() => sampleType = value);
                  }
                },
              ),

              const SizedBox(height: 14),

              ListTile(
                title: const Text('Collection date'),
                subtitle: Text(formatDate(collectedAt)),
                trailing: const Icon(Icons.calendar_today),
                onTap: saving
                    ? null
                    : () async {
                  final selected = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    initialDate: collectedAt,
                  );

                  if (selected != null && mounted) {
                    setState(() => collectedAt = selected);
                  }
                },
              ),

              const SizedBox(height: 20),

              FilledButton.icon(
                onPressed: saving ? null : save,
                icon: const Icon(Icons.save_outlined),
                label: Text(
                  saving ? 'Saving...' : 'Save specimen offline',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}

