import 'dart:io';
import 'dart:math' as math;

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
  static const _maxImageCount = 3;

  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _imagePicker = ImagePicker();
  final List<XFile> _selectedImages = [];

  bool _isSubmitting = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final remainingSlots = _maxImageCount - _selectedImages.length;
    if (remainingSlots <= 0) {
      _showImageLimitMessage();
      return;
    }

    try {
      final pickedImages = await _imagePicker.pickMultiImage(
        imageQuality: 85,
        limit: remainingSlots,
      );

      if (!mounted || pickedImages.isEmpty) {
        return;
      }

      setState(() {
        _selectedImages.addAll(pickedImages.take(remainingSlots));
      });

      if (pickedImages.length > remainingSlots) {
        _showImageLimitMessage();
      }
    } catch (_) {
      final pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedImage != null && mounted) {
        setState(() {
          _selectedImages.add(pickedImage);
        });
      }
    }
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
        images: List<XFile>.unmodifiable(_selectedImages),
      );

      if (!mounted) return;

      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        barrierColor: AppTheme.primaryDark.withValues(alpha: 0.35),
        builder: (context) => const _SuccessModal(),
      );

      if (!mounted) return;

      _messageController.clear();
      setState(_selectedImages.clear);
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FeedbackSubmissionException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(error.message),
              backgroundColor: AppTheme.error,
            ),
          );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  void _showImageLimitMessage() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Attach up to 3 images.'),
          backgroundColor: AppTheme.primaryDark,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(selectedRoute: FeedbackScreen.routeName),
      appBar: AppBar(
        leadingWidth: 68,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 34),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Feedback'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                  children: [
                    const Center(child: _FeedbackIllustration()),
                    const SizedBox(height: 34),
                    const Text(
                      'Tell us about your experience',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryText,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _messageController,
                      minLines: 4,
                      maxLines: 4,
                      textInputAction: TextInputAction.newline,
                      style: const TextStyle(
                        fontSize: 19,
                        color: Colors.black,
                        height: 1.48,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Start writing here...',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please tell us about your experience';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 26),
                    const Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 7,
                      runSpacing: 4,
                      children: [
                        Text(
                          'Add Screen shot',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryText,
                          ),
                        ),
                        Text(
                          '(Optional)',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.primaryText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _AttachmentPicker(
                      images: _selectedImages,
                      maxImages: _maxImageCount,
                      onPickImages: _pickImages,
                      onRemoveImage: _removeImage,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedbackIllustration extends StatelessWidget {
  const _FeedbackIllustration();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/feedback_illustration.png',
      width: 250,
      height: 180,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}

class _AttachmentPicker extends StatelessWidget {
  const _AttachmentPicker({
    required this.images,
    required this.maxImages,
    required this.onPickImages,
    required this.onRemoveImage,
  });

  final List<XFile> images;
  final int maxImages;
  final VoidCallback onPickImages;
  final ValueChanged<int> onRemoveImage;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return _UploadTile(onTap: onPickImages);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 18,
          runSpacing: 18,
          children: [
            for (var index = 0; index < images.length; index += 1)
              _ImagePreview(
                image: images[index],
                onRemove: () => onRemoveImage(index),
              ),
          ],
        ),
        if (images.length < maxImages) ...[
          const SizedBox(height: 28),
          _UploadTile(onTap: onPickImages),
        ],
      ],
    );
  }
}

class _UploadTile extends StatelessWidget {
  const _UploadTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 82,
      child: CustomPaint(
        painter: const _DashedRRectPainter(
          color: AppTheme.dashedBorder,
          radius: 16,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  _UploadIcon(),
                  SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Upload file',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryText,
                            height: 1.15,
                            letterSpacing: 0,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'PDF, JPEG or PNG less than 5MB',
                          maxLines: 1,
                          overflow: TextOverflow.visible,
                          softWrap: false,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.secondaryText,
                            height: 1.15,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UploadIcon extends StatelessWidget {
  const _UploadIcon();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.upload_file_outlined,
      color: AppTheme.primaryText,
      size: 34,
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.image, required this.onRemove});

  final XFile image;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      height: 84,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.file(
                File(image.path),
                height: 76,
                width: 76,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: -2,
            right: 0,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.close, color: Colors.black, size: 26),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  const _DashedRRectPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(1),
          Radius.circular(radius),
        ),
      );

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = math.min(distance + 9, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += 18;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}

class _SuccessModal extends StatelessWidget {
  const _SuccessModal();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 7,
              decoration: BoxDecoration(
                color: const Color(0xFFC9C7C7),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 68),
            const Icon(
              Icons.check_circle_outline,
              color: AppTheme.primaryDark,
              size: 88,
            ),
            const SizedBox(height: 28),
            const Text(
              'Thanks for Your Feedback!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryText,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'We’ve got your feedback—thanks for helping us get better.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppTheme.secondaryText,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 34),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Back to Home page'),
            ),
          ],
        ),
      ),
    );
  }
}
