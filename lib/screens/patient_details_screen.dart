

import 'package:flutter/material.dart';

import '../database/app_database.dart';
import '../models/patient.dart';
import '../models/specimen.dart';
import 'specimens_screen.dart';
import 'specimen_details_screen.dart';

class PatientDetailsScreen extends StatefulWidget {
  final Patient patient;

  const PatientDetailsScreen({
    super.key,
    required this.patient,
  });

  @override
  State<PatientDetailsScreen> createState() =>
      _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  static const teal = Color(0xFF0F766E);

  List<Specimen> specimens = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadSpecimens();
  }

  Future<void> loadSpecimens() async {
    final records = await AppDatabase.instance
        .getSpecimensForPatient(widget.patient.id);

    if (!mounted) return;

    setState(() {
      specimens = records;
      loading = false;
    });
  }

  Future<void> collectSpecimen() async {
    final patients = await AppDatabase.instance.getPatients();

    if (!mounted) return;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => SpecimenRegistrationSheet(
        patients: patients,
        initialPatientId: widget.patient.id,
      ),
    );

    if (saved == true && mounted) {
      await loadSpecimens();
    }
  }

  Widget infoRow(String label, String value) {
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
              value.isEmpty ? 'Not provided' : value,
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
    final patient = widget.patient;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient details'),
        backgroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: loadSpecimens,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: teal,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white24,
                    child: Icon(
                      Icons.person_outline,
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    patient.fullName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Patient ID: ${patient.patientId}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 14),
                  Chip(
                    label: Text(
                      patient.syncStatus == 'pending'
                          ? 'Saved offline · Pending sync'
                          : patient.syncStatus,
                    ),
                    backgroundColor: Colors.white,
                    side: BorderSide.none,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            const Text(
              'Patient information',
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
                    infoRow('First name', patient.firstName),
                    const Divider(height: 1),
                    infoRow('Surname', patient.surname),
                    const Divider(height: 1),
                    infoRow('Sex', patient.sex),
                    const Divider(height: 1),
                    infoRow('Date of birth', patient.dateOfBirth),
                    const Divider(height: 1),
                    infoRow('Village', patient.village),
                    const Divider(height: 1),
                    infoRow('Phone', patient.phone),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Associated specimens',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text('${specimens.length}'),
                  backgroundColor: const Color(0xFFE0F2F1),
                ),
              ],
            ),

            const SizedBox(height: 10),

            if (loading)
              const Center(child: CircularProgressIndicator())
            else if (specimens.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.science_outlined,
                      size: 42,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 12),
                    Text('No specimens collected yet'),
                    SizedBox(height: 4),
                    Text(
                      'Collect the first specimen for this patient.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
              ...specimens.map(
                    (specimen) => Card(
                  color: Colors.white,
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE0F2F1),
                      child: Icon(
                        Icons.science_outlined,
                        color: teal,
                      ),
                    ),
                    title: Text(
                      specimen.specimenId,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${specimen.sampleType} · '
                          '${specimen.collectedAt.split('T').first}',
                    ),
                    trailing: const Chip(
                      label: Text('Pending'),
                    ),


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
                ),
              ),

            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: collectSpecimen,
        backgroundColor: teal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Collect specimen'),
      ),
    );
  }
}

