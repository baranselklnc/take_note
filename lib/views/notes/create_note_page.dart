import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../viewmodels/notes_viewmodel.dart';
import '../../shared/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

/// Create note page
class CreateNotePage extends HookConsumerWidget {
  const CreateNotePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final titleController = useTextEditingController();
    final contentController = useTextEditingController();
    final isSaving = useState(false);

    void saveNote() async {
      if (formKey.currentState!.validate()) {
        isSaving.value = true;

        try {
          await ref.read(notesViewModelProvider.notifier).createNote(
            titleController.text.trim(),
            contentController.text.trim(),
          );

          if (context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notunuz başarıyla oluşturuldu')),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Notunu kaydetemedik hata alıyoruz: $e'),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        } finally {
          isSaving.value = false;
        }
      }
    }


    return Scaffold(
      appBar: AppBar(
        title: const Text('Not Oluştur'),
        actions: [
          TextButton(
            onPressed: isSaving.value ? null : saveNote,
            child: isSaving.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Kaydet'),
          ),
        ],
      ),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title field
              TextFormField(
                controller: titleController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Başlık',
                  hintText: 'Not başlığını girin...',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lütfen bir başlık girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.defaultPadding),

              // Content field
              Expanded(
                child: TextFormField(
                  controller: contentController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    labelText: 'İçerik',
                    hintText: 'Notunuzu yazmaya başlayın...',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen bir içerik girin';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
