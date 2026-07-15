import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/enums.dart';
import '../../../providers/auth_provider.dart';

class CreatorVerificationService {
  CreatorVerificationService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _requests =>
      _firestore.collection(AppConstants.verificationRequestsCollection);

  Future<void> submitRequest({
    required String userId,
    required String displayName,
    required CreatorVerificationType type,
    String? credentials,
  }) async {
    await _requests.doc(userId).set({
      'userId': userId,
      'displayName': displayName,
      'creatorVerificationType': type.value,
      'credentials': credentials,
      'status': VerificationStatus.pending.value,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _firestore.collection(AppConstants.usersCollection).doc(userId).update({
      'creatorVerificationType': type.value,
      'verificationStatus': VerificationStatus.pending.value,
    });
  }

  Stream<List<Map<String, dynamic>>> pendingRequests() {
    return _requests
        .where('status', isEqualTo: VerificationStatus.pending.value)
        .snapshots()
        .map((snap) => snap.docs.map((d) => {...d.data(), 'id': d.id}).toList());
  }

  Future<void> approveRequest(String userId, String adminId) async {
    final doc = await _requests.doc(userId).get();
    if (!doc.exists) return;
    final type = doc.data()!['creatorVerificationType'] as String;

    await _requests.doc(userId).update({
      'status': VerificationStatus.approved.value,
      'reviewedBy': adminId,
      'reviewedAt': FieldValue.serverTimestamp(),
    });

    await _firestore.collection(AppConstants.usersCollection).doc(userId).update({
      'creatorVerificationType': type,
      'verificationStatus': VerificationStatus.approved.value,
      'isVerified': true,
      if (type == CreatorVerificationType.teacher.value) 'role': UserRole.teacher.value,
    });
  }

  Future<void> rejectRequest(String userId, String adminId) async {
    await _requests.doc(userId).update({
      'status': VerificationStatus.rejected.value,
      'reviewedBy': adminId,
      'reviewedAt': FieldValue.serverTimestamp(),
    });

    await _firestore.collection(AppConstants.usersCollection).doc(userId).update({
      'verificationStatus': VerificationStatus.rejected.value,
    });
  }
}

class CreatorVerificationScreen extends StatefulWidget {
  const CreatorVerificationScreen({super.key});

  @override
  State<CreatorVerificationScreen> createState() =>
      _CreatorVerificationScreenState();
}

class _CreatorVerificationScreenState extends State<CreatorVerificationScreen> {
  final _service = CreatorVerificationService();
  final _credentialsController = TextEditingController();
  CreatorVerificationType _selectedType = CreatorVerificationType.teacher;
  bool _submitting = false;

  @override
  void dispose() {
    _credentialsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    final auth = context.read<AuthProvider>();

    setState(() => _submitting = true);
    try {
      await _service.submitRequest(
        userId: user.uid,
        displayName: user.displayName,
        type: _selectedType,
        credentials: _credentialsController.text.trim(),
      );
      await auth.refreshUser();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification request submitted')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Creator Verification')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Apply for a verified creator badge',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Teachers, scholars, doctors, nurses, and institutions can apply '
            'for verification. Admin approval is required.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Text('Creator Type', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          RadioGroup<CreatorVerificationType>(
            groupValue: _selectedType,
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedType = value);
              }
            },
            child: Column(
              children: CreatorVerificationType.values
                  .map(
                    (type) => RadioListTile<CreatorVerificationType>(
                      title: Text(type.label),
                      value: type,
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _credentialsController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Credentials / Description',
              hintText: 'Degree, institution, license number, etc.',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Submit Application'),
          ),
        ],
      ),
    );
  }
}
