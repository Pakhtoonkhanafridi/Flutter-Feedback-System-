import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/feedback_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({required this.feedbackService, super.key});

  static const routeName = '/feedback';

  final FeedbackService feedbackService;

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  static const _maxImages = 3;

  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _imagePicker = ImagePicker();
  final List<XFile> _images = [];

  bool _isSubmitting = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final remainingSlots = _maxImages - _images.length;
    if (remainingSlots <= 0) {
      _showSnackBar('Attach up to 3 images.');
      return;
    }

    final pickedImages = await _imagePicker.pickMultiImage(
      imageQuality: 84,
      limit: remainingSlots,
    );

    if (pickedImages.isEmpty || !mounted) {
      return;
    }

    setState(() {
      _images.addAll(pickedImages.take(remainingSlots));
    });
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid || _isSubmitting) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await widget.feedbackService.submit(
        message: _messageController.text,
        images: List<XFile>.unmodifiable(_images),
      );

      if (!mounted) {
        return;
      }

      _messageController.clear();
      setState(_images.clear);
      _showSnackBar('Feedback submitted. Thank you.');
    } on FeedbackSubmissionException catch (error) {
      if (mounted) {
        _showSnackBar(error.message);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _removeImage(XFile image) {
    setState(() => _images.remove(image));
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  @override
  Widget build(BuildContext context) {
    final canAddImages = _images.length < _maxImages;

    return Scaffold(
      drawer: const AppDrawer(selectedRoute: FeedbackScreen.routeName),
      appBar: AppBar(title: const Text('Feedback')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              const Text(
                'Tell us what happened',
                style: TextStyle(
                  color: AppTheme.ink,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.12,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your message goes directly to the team.',
                style: TextStyle(
                  color: AppTheme.mutedInk,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              if (!widget.feedbackService.isConfigured) ...[
                const _ConfigNotice(),
                const SizedBox(height: 14),
              ],
              TextFormField(
                controller: _messageController,
                minLines: 7,
                maxLines: 10,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  labelText: 'Feedback',
                  hintText: 'Write your feedback here...',
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Feedback is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Images',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    '${_images.length}/$_maxImages',
                    style: const TextStyle(
                      color: AppTheme.mutedInk,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _ImageGrid(
                images: _images,
                canAddImages: canAddImages,
                onAddImages: _pickImages,
                onRemoveImage: _removeImage,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                icon: _isSubmitting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_outlined),
                label: Text(
                  _isSubmitting ? 'Submitting...' : 'Submit feedback',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfigNotice extends StatelessWidget {
  const _ConfigNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3EA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFD3BF)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppTheme.coral),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Backend credentials are missing for this build.',
              style: TextStyle(
                color: AppTheme.ink,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageGrid extends StatelessWidget {
  const _ImageGrid({
    required this.images,
    required this.canAddImages,
    required this.onAddImages,
    required this.onRemoveImage,
  });

  final List<XFile> images;
  final bool canAddImages;
  final VoidCallback onAddImages;
  final ValueChanged<XFile> onRemoveImage;

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[
      for (final image in images)
        _ImagePreview(image: image, onRemove: () => onRemoveImage(image)),
      if (canAddImages) _AddImageTile(onTap: onAddImages),
    ];

    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: tiles,
    );
  }
}

class _AddImageTile extends StatelessWidget {
  const _AddImageTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppTheme.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined, color: AppTheme.teal),
            SizedBox(height: 6),
            Text(
              'Add',
              style: TextStyle(
                color: AppTheme.mutedInk,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.image, required this.onRemove});

  final XFile image;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(File(image.path), fit: BoxFit.cover),
          Positioned(
            top: 4,
            right: 4,
            child: Material(
              color: Colors.black.withValues(alpha: 0.62),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onRemove,
                child: const Padding(
                  padding: EdgeInsets.all(5),
                  child: Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
