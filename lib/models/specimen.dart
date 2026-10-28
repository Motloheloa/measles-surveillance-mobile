
class Specimen {
  final String id;
  final String specimenId;
  final String patientLocalId;
  final String sampleType;
  final String collectedAt;
  final String syncStatus;
  final String createdAt;

  const Specimen({
    required this.id,
    required this.specimenId,
    required this.patientLocalId,
    required this.sampleType,
    required this.collectedAt,
    required this.syncStatus,
    required this.createdAt,
  });

  Map<String, Object?> toMap() => {
    'id': id,
    'specimen_id': specimenId,
    'patient_local_id': patientLocalId,
    'sample_type': sampleType,
    'collected_at': collectedAt,
    'sync_status': syncStatus,
    'created_at': createdAt,
  };

  factory Specimen.fromMap(Map<String, Object?> map) => Specimen(
    id: map['id'] as String,
    specimenId: map['specimen_id'] as String,
    patientLocalId: map['patient_local_id'] as String,
    sampleType: map['sample_type'] as String,
    collectedAt: map['collected_at'] as String,
    syncStatus: map['sync_status'] as String,
    createdAt: map['created_at'] as String,
  );
}
