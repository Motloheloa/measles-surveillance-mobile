class Patient {
  final String id;
  final String patientId;
  final String firstName;
  final String surname;
  final String nationalId;
  final String sex;
  final String dateOfBirth;
  final String phone;
  final String village;
  final String orgUnit;
  final String syncStatus;
  final String createdAt;

  const Patient({
    required this.id,
    required this.patientId,
    required this.firstName,
    required this.surname,
    required this.nationalId,
    required this.sex,
    required this.dateOfBirth,
    required this.phone,
    required this.village,
    required this.orgUnit,
    required this.syncStatus,
    required this.createdAt,
  });

  String get fullName => '$firstName $surname'.trim();

  Map<String, Object?> toMap() => {
    'id': id,
    'patient_id': patientId,
    'first_name': firstName,
    'surname': surname,
    'national_id': nationalId,
    'sex': sex,
    'date_of_birth': dateOfBirth,
    'phone': phone,
    'village': village,
    'org_unit': orgUnit,
    'sync_status': syncStatus,
    'created_at': createdAt,
  };

  factory Patient.fromMap(Map<String, Object?> map) => Patient(
    id: map['id'] as String,
    patientId: map['patient_id'] as String,
    firstName: map['first_name'] as String,
    surname: map['surname'] as String,
    nationalId: map['national_id'] as String? ?? '',
    sex: map['sex'] as String,
    dateOfBirth: map['date_of_birth'] as String? ?? '',
    phone: map['phone'] as String? ?? '',
    village: map['village'] as String? ?? '',
    orgUnit: map['org_unit'] as String? ?? '',
    syncStatus: map['sync_status'] as String,
    createdAt: map['created_at'] as String,
  );
}
