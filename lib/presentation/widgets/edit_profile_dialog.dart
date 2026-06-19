import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../providers/edit_profile_provider.dart';

/// Modal dialog for editing user profile.
/// Shows text field for full name with validation and loading state.
class EditProfileDialog extends ConsumerStatefulWidget {
  final String currentName;

  const EditProfileDialog({
    required this.currentName,
    super.key,
  });

  @override
  ConsumerState<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends ConsumerState<EditProfileDialog> {
  late TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Validates and submits the form.
  /// Shows error snackbar on failure, pops dialog on success.
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final newName = _nameController.text.trim();
    await ref.read(editProfileProvider.notifier).updateFullName(newName);

    if (mounted) {
      final state = ref.read(editProfileProvider);
      state.when(
        data: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(AppStrings.profileUpdatedSuccess),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pop();
        },
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              backgroundColor: AppColors.danger,
            ),
          );
        },
        loading: () {},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final editState = ref.watch(editProfileProvider);
    final isLoading = editState is AsyncLoading;

    return AlertDialog(
      title: const Text(AppStrings.editProfileTitle),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          enabled: !isLoading,
          decoration: InputDecoration(
            labelText: AppStrings.fullNameLabel,
            hintText: AppStrings.fullNameHint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusButton),
            ),
            contentPadding: const EdgeInsets.all(AppDimens.sp12),
          ),
          validator: (value) {
            return AppValidators.fullName(value);
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _handleSave,
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.textOnPrimary),
                  ),
                )
              : const Text(AppStrings.save),
        ),
      ],
    );
  }
}
