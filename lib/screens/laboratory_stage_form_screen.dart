import 'package:flutter/material.dart';

// ======================================================
// LABORATORY FIELD TYPES
// ======================================================

enum LaboratoryFieldType {
  text,
  multiline,
  number,
  date,
  dateTime,
  dropdown,
  yesNo,
}

// ======================================================
// LABORATORY FIELD DEFINITION
// ======================================================

class LaboratoryFieldDefinition {
  final String id;
  final String label;
  final LaboratoryFieldType type;
  final bool required;
  final List<String> options;

  const LaboratoryFieldDefinition({
    required this.id,
    required this.label,
    required this.type,
    this.required = false,
    this.options = const [],
  });
}

// ======================================================
// LABORATORY STAGE DEFINITION
// ======================================================

class LaboratoryStageDefinition {
  final String id;
  final String name;
  final String formTitle;
  final IconData icon;
  final List<LaboratoryFieldDefinition> fields;

  const LaboratoryStageDefinition({
    required this.id,
    required this.name,
    required this.formTitle,
    required this.icon,
    required this.fields,
  });
}

// ======================================================
// LABORATORY STAGE CATALOG
// ======================================================

class LaboratoryStageCatalog {
  static const stages = <LaboratoryStageDefinition>[

    // ==================================================
    // STAGE 1: SPECIMEN DISPATCH
    // ==================================================

    LaboratoryStageDefinition(
      id: 'dispatch',
      name: 'Specimen Dispatch',
      formTitle: 'MSL Specimen Dispatch',
      icon: Icons.local_shipping_outlined,
      fields: [
        LaboratoryFieldDefinition(
          id: 'dispatchDateTime',
          label: 'Dispatch date time',
          type: LaboratoryFieldType.dateTime,
        ),
        LaboratoryFieldDefinition(
          id: 'transportMode',
          label: 'Transport mode',
          type: LaboratoryFieldType.dropdown,
          options: [
            'Vehicle',
            'Motorcycle',
            'Air',
            'Other',
          ],
        ),
        LaboratoryFieldDefinition(
          id: 'courierName',
          label: 'Courier name',
          type: LaboratoryFieldType.dropdown,
          options: [
            'Government courier',
            'Facility Staff',
            'Partner Courier',
            'Other',
          ],
        ),
        LaboratoryFieldDefinition(
          id: 'coldChainMaintained',
          label: 'Cold chain maintained',
          type: LaboratoryFieldType.yesNo,
        ),
        LaboratoryFieldDefinition(
          id: 'dispatchOfficer',
          label: 'Dispatch officer',
          type: LaboratoryFieldType.text,
        ),
      ],
    ),

    // ==================================================
    // STAGE 2: LAB RECEPTION
    // ==================================================

    LaboratoryStageDefinition(
      id: 'reception',
      name: 'Lab Reception',
      formTitle: 'MSL Lab Reception',
      icon: Icons.inventory_2_outlined,
      fields: [
        LaboratoryFieldDefinition(
          id: 'receiptDateTime',
          label: 'Receipt date time',
          type: LaboratoryFieldType.dateTime,
        ),
        LaboratoryFieldDefinition(
          id: 'labNumber',
          label: 'Lab number',
          type: LaboratoryFieldType.text,
        ),
        LaboratoryFieldDefinition(
          id: 'specimenVolume',
          label: 'Specimen volume',
          type: LaboratoryFieldType.number,
        ),
        LaboratoryFieldDefinition(
          id: 'specimenLeakage',
          label: 'Specimen leakage',
          type: LaboratoryFieldType.yesNo,
        ),
        LaboratoryFieldDefinition(
          id: 'specimenTemperature',
          label: 'Specimen temperature',
          type: LaboratoryFieldType.number,
        ),
        LaboratoryFieldDefinition(
          id: 'accepted',
          label: 'Accepted',
          type: LaboratoryFieldType.yesNo,
        ),
        LaboratoryFieldDefinition(
          id: 'receptionOfficer',
          label: 'Reception officer',
          type: LaboratoryFieldType.text,
        ),
      ],
    ),

    // ==================================================
    // STAGE 3: TESTING
    // ==================================================

    LaboratoryStageDefinition(
      id: 'testing',
      name: 'Testing',
      formTitle: 'MSL Testing',
      icon: Icons.biotech_outlined,
      fields: [
        LaboratoryFieldDefinition(
          id: 'testingReceiptDateTime',
          label: 'Testing receipt date time',
          type: LaboratoryFieldType.dateTime,
        ),
        LaboratoryFieldDefinition(
          id: 'testStartDateTime',
          label: 'Test start date time',
          type: LaboratoryFieldType.dateTime,
        ),
        LaboratoryFieldDefinition(
          id: 'testMethod',
          label: 'Test method',
          type: LaboratoryFieldType.dropdown,
          options: [
            'IgM ELISA',
            'RT-PCR',
          ],
        ),
        LaboratoryFieldDefinition(
          id: 'testingOfficer',
          label: 'Testing officer',
          type: LaboratoryFieldType.text,
        ),
      ],
    ),

    // ==================================================
    // STAGE 4: RESULTS
    // ==================================================

    LaboratoryStageDefinition(
      id: 'results',
      name: 'Results',
      formTitle: 'MSL Results',
      icon: Icons.assignment_outlined,
      fields: [
        LaboratoryFieldDefinition(
          id: 'resultsDateTime',
          label: 'Results date time',
          type: LaboratoryFieldType.dateTime,
        ),
        LaboratoryFieldDefinition(
          id: 'measlesIgm',
          label: 'Measles IgM',
          type: LaboratoryFieldType.dropdown,
          options: [
            'Positive',
            'Negative',
            'Equivocal',
            'Indeterminate',
            'Not Done',
          ],
        ),
        LaboratoryFieldDefinition(
          id: 'rubellaIgm',
          label: 'Rubella IgM',
          type: LaboratoryFieldType.dropdown,
          options: [
            'Positive',
            'Negative',
            'Equivocal',
            'Indeterminate',
            'Not Done',
          ],
        ),
        LaboratoryFieldDefinition(
          id: 'pcrDone',
          label: 'PCR done',
          type: LaboratoryFieldType.dropdown,
          options: [
            'Yes',
            'No',
          ],
        ),
        LaboratoryFieldDefinition(
          id: 'resultsComments',
          label: 'Results comments',
          type: LaboratoryFieldType.multiline,
        ),
        LaboratoryFieldDefinition(
          id: 'resultsOfficer',
          label: 'Results officer',
          type: LaboratoryFieldType.text,
        ),
      ],
    ),

    // ==================================================
    // STAGE 5: RESULTS RELEASE
    // ==================================================

    LaboratoryStageDefinition(
      id: 'release',
      name: 'Results Release',
      formTitle: 'MSL Results Release',
      icon: Icons.verified_outlined,
      fields: [
        LaboratoryFieldDefinition(
          id: 'authorizedBy',
          label: 'Authorized by',
          type: LaboratoryFieldType.text,
        ),
        LaboratoryFieldDefinition(
          id: 'authorizationDateTime',
          label: 'Authorization date time',
          type: LaboratoryFieldType.dateTime,
        ),
        LaboratoryFieldDefinition(
          id: 'notificationSent',
          label: 'Notification sent',
          type: LaboratoryFieldType.yesNo,
        ),
        LaboratoryFieldDefinition(
          id: 'notificationChannel',
          label: 'Notification channel',
          type: LaboratoryFieldType.dropdown,
          options: [
            'LTV',
            'SMS',
            'Email',
            'Telephone',
          ],
        ),
      ],
    ),

    // ==================================================
    // STAGE 6: RESULTS VIEW
    // ==================================================

    LaboratoryStageDefinition(
      id: 'view',
      name: 'Results View',
      formTitle: 'MSL Results View',
      icon: Icons.task_alt_outlined,
      fields: [
        LaboratoryFieldDefinition(
          id: 'viewedBy',
          label: 'Viewed by',
          type: LaboratoryFieldType.text,
        ),
        LaboratoryFieldDefinition(
          id: 'viewedDateTime',
          label: 'Viewed date time',
          type: LaboratoryFieldType.dateTime,
        ),
        LaboratoryFieldDefinition(
          id: 'followUpAction',
          label: 'Follow up action',
          type: LaboratoryFieldType.dropdown,
          options: [
            'No action',
            'Clinical follow-up',
            'Case Investigation',
            'Repeat Specimen',
            'Repeat Patient',
            'Refer Patient',
            'Other',
          ],
        ),
      ],
    ),
  ];
}

// ======================================================
// TEMPORARY IN-MEMORY FORM STORAGE
// ======================================================

class LaboratoryFormDrafts {
  static final Map<String, Map<String, Map<String, String>>>
  _drafts = {};

  static Map<String, String> read(
      String specimenLocalId,
      String stageId,
      ) {
    return Map<String, String>.from(
      _drafts[specimenLocalId]?[stageId] ??
          <String, String>{},
    );
  }

  static bool hasDraft(
      String specimenLocalId,
      String stageId,
      ) {
    return _drafts[specimenLocalId]
        ?.containsKey(stageId) ??
        false;
  }

  static void save(
      String specimenLocalId,
      String stageId,
      Map<String, String> values,
      ) {
    _drafts.putIfAbsent(
      specimenLocalId,
          () => <String, Map<String, String>>{},
    )[stageId] = Map<String, String>.from(values);
  }

  // ====================================================
  // NEW: CHECK STAGE COMPLETION
  // ====================================================

  static bool isComplete(
      String specimenLocalId,
      LaboratoryStageDefinition stage,
      ) {
    final values = _drafts[specimenLocalId]?[stage.id];

    if (values == null || stage.fields.isEmpty) {
      return false;
    }

    for (final field in stage.fields) {
      final value = values[field.id]?.trim() ?? '';

      if (value.isEmpty) {
        return false;
      }

      if (field.type == LaboratoryFieldType.number &&
          num.tryParse(value) == null) {
        return false;
      }

      if (field.type == LaboratoryFieldType.yesNo &&
          value != 'Yes' &&
          value != 'No') {
        return false;
      }

      if (field.type == LaboratoryFieldType.dropdown &&
          !field.options.contains(value)) {
        return false;
      }

      if (field.type == LaboratoryFieldType.date ||
          field.type == LaboratoryFieldType.dateTime) {
        if (DateTime.tryParse(value) == null) {
          return false;
        }
      }
    }

    return true;
  }

  // ====================================================
  // NEW: CHECK WHETHER STAGE IS UNLOCKED
  // ====================================================

  static bool canOpen(
      String specimenLocalId,
      int stageIndex,
      ) {
    if (stageIndex < 0 ||
        stageIndex >= LaboratoryStageCatalog.stages.length) {
      return false;
    }

    if (stageIndex == 0) {
      return true;
    }

    for (var i = 0; i < stageIndex; i++) {
      final previousStage =
      LaboratoryStageCatalog.stages[i];

      if (!isComplete(specimenLocalId, previousStage)) {
        return false;
      }
    }

    return true;
  }
}

// ======================================================
// LABORATORY STAGE FORM SCREEN
// ======================================================

class LaboratoryStageFormScreen extends StatefulWidget {
  final String specimenLocalId;
  final String specimenId;
  final LaboratoryStageDefinition stage;
  final Map<String, String> initialValues;

  const LaboratoryStageFormScreen({
    super.key,
    required this.specimenLocalId,
    required this.specimenId,
    required this.stage,
    this.initialValues = const {},
  });

  @override
  State<LaboratoryStageFormScreen> createState() =>
      _LaboratoryStageFormScreenState();
}

class _LaboratoryStageFormScreenState
    extends State<LaboratoryStageFormScreen> {
  static const teal = Color(0xFF0F766E);

  final formKey = GlobalKey<FormState>();

  final Map<String, TextEditingController> controllers = {};

  final Map<String, String?> dropdownValues = {};

  // ====================================================
  // INITIALIZE FORM
  // ====================================================

  @override
  void initState() {
    super.initState();

    final values = <String, String>{
      ...LaboratoryFormDrafts.read(
        widget.specimenLocalId,
        widget.stage.id,
      ),
      ...widget.initialValues,
    };

    for (final field in widget.stage.fields) {
      if (field.type == LaboratoryFieldType.dropdown ||
          field.type == LaboratoryFieldType.yesNo) {
        final value = values[field.id];

        dropdownValues[field.id] =
        value == null || value.isEmpty
            ? null
            : value;
      } else {
        controllers[field.id] = TextEditingController(
          text: values[field.id] ?? '',
        );
      }
    }
  }

  // ====================================================
  // DISPOSE CONTROLLERS
  // ====================================================

  @override
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  // ====================================================
  // DATE FORMAT
  // ====================================================

  String twoDigits(int number) {
    return number.toString().padLeft(2, '0');
  }

  // ====================================================
  // DATE AND TIME PICKER
  // ====================================================

  Future<void> pickDate(
      LaboratoryFieldDefinition field,
      ) async {
    final controller = controllers[field.id]!;

    final current = DateTime.tryParse(
      controller.text,
    );

    final date = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date == null || !mounted) return;

    String value =
        '${date.year}-${twoDigits(date.month)}-${twoDigits(date.day)}';

    if (field.type == LaboratoryFieldType.dateTime) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          current ?? DateTime.now(),
        ),
      );

      if (time == null || !mounted) return;

      value =
      '$value ${twoDigits(time.hour)}:${twoDigits(time.minute)}';
    }

    setState(() {
      controller.text = value;
    });
  }

  // ====================================================
  // REQUIRED FIELD VALIDATION
  // ====================================================

  String? validateRequired(
      LaboratoryFieldDefinition field,
      String? value,
      ) {
    if (value == null || value.trim().isEmpty) {
      return '${field.label} is required';
    }

    return null;
  }

  // ====================================================
  // BUILD DYNAMIC FORM FIELD
  // ====================================================

  Widget buildField(
      LaboratoryFieldDefinition field,
      ) {
    const border = OutlineInputBorder();

    // All fields are required for sequential completion.
    final label = '${field.label} *';

    // ==================================================
    // DROPDOWN AND YES/NO FIELDS
    // ==================================================

    if (field.type == LaboratoryFieldType.dropdown ||
        field.type == LaboratoryFieldType.yesNo) {
      final options =
      field.type == LaboratoryFieldType.yesNo
          ? ['Yes', 'No']
          : field.options;

      final selected = dropdownValues[field.id];

      final available = <String>{
        ...options,
        if (selected != null && selected.isNotEmpty)
          selected,
      }.toList();

      return DropdownButtonFormField<String>(
        value: available.contains(selected)
            ? selected
            : null,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          border: border,
        ),
        items: available.map((option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(
              option,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            dropdownValues[field.id] = value;
          });
        },
        validator: (value) {
          final error = validateRequired(field, value);

          if (error != null) return error;

          if (field.type == LaboratoryFieldType.dropdown &&
              !field.options.contains(value)) {
            return 'Select a valid ${field.label.toLowerCase()}';
          }

          return null;
        },
      );
    }

    // ==================================================
    // DATE AND DATE-TIME FIELDS
    // ==================================================

    if (field.type == LaboratoryFieldType.date ||
        field.type == LaboratoryFieldType.dateTime) {
      return TextFormField(
        controller: controllers[field.id],
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: border,
          suffixIcon: const Icon(
            Icons.calendar_month_outlined,
          ),
        ),
        onTap: () => pickDate(field),
        validator: (value) {
          final error = validateRequired(field, value);

          if (error != null) return error;

          if (DateTime.tryParse(value!) == null) {
            return 'Select a valid date';
          }

          return null;
        },
      );
    }

    // ==================================================
    // TEXT, NUMBER AND MULTILINE FIELDS
    // ==================================================

    return TextFormField(
      controller: controllers[field.id],
      minLines:
      field.type == LaboratoryFieldType.multiline
          ? 3
          : 1,
      maxLines:
      field.type == LaboratoryFieldType.multiline
          ? 6
          : 1,
      keyboardType:
      field.type == LaboratoryFieldType.number
          ? const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      )
          : field.type == LaboratoryFieldType.multiline
          ? TextInputType.multiline
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: border,
        alignLabelWithHint:
        field.type == LaboratoryFieldType.multiline,
      ),
      validator: (value) {
        final requiredError =
        validateRequired(field, value);

        if (requiredError != null) {
          return requiredError;
        }

        if (field.type == LaboratoryFieldType.number &&
            num.tryParse(value!.trim()) == null) {
          return 'Enter a valid number';
        }

        return null;
      },
    );
  }

  // ====================================================
  // SAVE FORM PREVIEW
  // ====================================================

  void savePreview() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final values = <String, String>{};

    for (final field in widget.stage.fields) {
      if (field.type == LaboratoryFieldType.dropdown ||
          field.type == LaboratoryFieldType.yesNo) {
        values[field.id] =
            dropdownValues[field.id] ?? '';
      } else {
        values[field.id] =
            controllers[field.id]?.text.trim() ?? '';
      }
    }

    LaboratoryFormDrafts.save(
      widget.specimenLocalId,
      widget.stage.id,
      values,
    );

    Navigator.pop(context, true);
  }

  // ====================================================
  // MAIN SCREEN
  // ====================================================

  @override
  Widget build(BuildContext context) {
    final stage = widget.stage;

    final hasFields = stage.fields.isNotEmpty;

    final hasDraft = LaboratoryFormDrafts.hasDraft(
      widget.specimenLocalId,
      stage.id,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: Text(stage.name),
        backgroundColor: Colors.white,
      ),

      body: SafeArea(
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [

              // ========================================
              // FORM HEADER
              // ========================================

              Card(
                color: Colors.white,
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        stage.formTitle,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF123047),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Specimen: ${widget.specimenId}',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Icon(
                            hasDraft
                                ? Icons.edit_note
                                : Icons.science_outlined,
                            color: teal,
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: Text(
                              hasDraft
                                  ? 'Preview values entered'
                                  : 'No local preview entered',
                              style: const TextStyle(
                                color: teal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ========================================
              // FORM FIELDS
              // ========================================

              if (!hasFields)
                Card(
                  color: Colors.white,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.description_outlined,
                          size: 42,
                          color: teal,
                        ),

                        const SizedBox(height: 12),

                        Text(
                          '${stage.name} form',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          'The stage screen is ready. '
                              'Its exact form fields and '
                              'dropdown options still need '
                              'to be copied from the web '
                              'application metadata.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                Card(
                  color: Colors.white,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                      children: [
                        for (final field in stage.fields) ...[
                          buildField(field),
                          const SizedBox(height: 18),
                        ],

                        const SizedBox(height: 8),

                        FilledButton.icon(
                          onPressed: savePreview,
                          style: FilledButton.styleFrom(
                            backgroundColor: teal,
                            foregroundColor: Colors.white,
                            padding:
                            const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                          ),
                          icon: const Icon(
                            Icons.save_outlined,
                          ),
                          label: const Text(
                            'Save form preview',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              const Text(
                'UI preview only. Values are held '
                    'in memory and will be lost when '
                    'the app restarts. Nothing is sent '
                    'to DHIS2.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}