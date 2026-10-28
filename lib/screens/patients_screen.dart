

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../models/patient.dart';
import 'patient_details_screen.dart';
class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  List<Patient> patients = [];
  bool loading = true;
  String searchQuery = '';
  @override
  void initState() {
    super.initState();
    loadPatients();
  }

  Future<void> loadPatients() async {
    final records = await AppDatabase.instance.getPatients();

    if (!mounted) return;

    setState(() {
      patients = records;
      loading = false;
    });
  }


  Future<void> registerPatient() async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      builder: (_) => const PatientRegistrationSheet(),
    );

    if (saved == true && mounted) {
      await loadPatients();
    }
  }



  @override
  Widget build(BuildContext context) {
    const teal = Color(0xFF0F766E);

    final filtered = patients.where((patient) {
      final query = searchQuery.trim().toLowerCase();
      return patient.fullName.toLowerCase().contains(query) ||
          patient.patientId.toLowerCase().contains(query) ||
          patient.nationalId.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Patients',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: loadPatients,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: registerPatient,
        backgroundColor: teal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Register patient'),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${patients.length} registered patients',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 14),
                TextField(
                  onChanged: (value) {
                    setState(() => searchQuery = value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search name, patient ID or national ID',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: const Color(0xFFF3F6F8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                ? const Center(
              child: Text('No matching patients found'),
            )
                : RefreshIndicator(
              onRefresh: loadPatients,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  14, 16, 14, 110,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final patient = filtered[index];

                  return Card(
                    color: Colors.white,
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(14),
                      leading: const CircleAvatar(
                        radius: 25,
                        backgroundColor: Color(0xFFE0F2F1),
                        child: Icon(
                          Icons.person_outline,
                          color: teal,
                        ),
                      ),
                      title: Text(
                        patient.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text('ID: ${patient.patientId}'),
                            const SizedBox(height: 5),
                            Text(
                              patient.syncStatus == 'pending'
                                  ? '● Pending synchronization'
                                  : '● ${patient.syncStatus}',
                              style: const TextStyle(
                                color: Color(0xFFB7791F),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PatientDetailsScreen(
                              patient: patient,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class PatientRegistrationSheet extends StatefulWidget {
  const PatientRegistrationSheet({super.key});

  @override
  State<PatientRegistrationSheet> createState() =>
      _PatientRegistrationSheetState();
}

class _PatientRegistrationSheetState
    extends State<PatientRegistrationSheet> {
  final formKey = GlobalKey<FormState>();

  final patientId = TextEditingController();
  final firstName = TextEditingController();
  final surname = TextEditingController();
  final nationalId = TextEditingController();
  final phone = TextEditingController();
  final village = TextEditingController();

  String sex = 'Male';
  DateTime? dob;
  bool saving = false;

  @override
  void dispose() {
    patientId.dispose();
    firstName.dispose();
    surname.dispose();
    nationalId.dispose();
    phone.dispose();
    village.dispose();
    super.dispose();
  }

  String formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Widget input(
      String label,
      TextEditingController controller, {
        bool required = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (required &&
              (value == null || value.trim().isEmpty)) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }

  Future<void> save() async {
    if (saving || !formKey.currentState!.validate()) return;

    setState(() => saving = true);

    final record = Patient(
      id: const Uuid().v4(),
      patientId: patientId.text.trim(),
      firstName: firstName.text.trim(),
      surname: surname.text.trim(),
      nationalId: nationalId.text.trim(),
      sex: sex,
      dateOfBirth: dob == null ? '' : formatDate(dob!),
      phone: phone.text.trim(),
      village: village.text.trim(),
      orgUnit: '',
      syncStatus: 'pending',
      createdAt: DateTime.now().toUtc().toIso8601String(),
    );

    try {
      await AppDatabase.instance.insertPatient(record);

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
        heightFactor: 0.9,
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Register patient',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Patient information is saved on this device.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              input('Patient ID', patientId, required: true),
              input('First name', firstName, required: true),
              input('Surname', surname, required: true),
              input('National ID', nationalId),

              DropdownButtonFormField<String>(
                value: sex,
                decoration: const InputDecoration(
                  labelText: 'Sex',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Male',
                    child: Text('Male'),
                  ),
                  DropdownMenuItem(
                    value: 'Female',
                    child: Text('Female'),
                  ),
                ],
                onChanged: saving
                    ? null
                    : (value) {
                  if (value != null) {
                    setState(() => sex = value);
                  }
                },
              ),

              const SizedBox(height: 14),

              OutlinedButton.icon(
                onPressed: saving
                    ? null
                    : () async {
                  final selected = await showDatePicker(
                    context: context,
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                    initialDate: dob ?? DateTime(2000),
                  );

                  if (selected != null && mounted) {
                    setState(() => dob = selected);
                  }
                },
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text(
                  dob == null
                      ? 'Select date of birth'
                      : 'Date of birth: ${formatDate(dob!)}',
                ),
              ),

              const SizedBox(height: 14),
              input('Phone', phone),
              input('Village', village),

              const SizedBox(height: 18),

              FilledButton.icon(
                onPressed: saving ? null : save,
                icon: saving
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  saving ? 'Saving...' : 'Save patient offline',
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
