import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/content_policy.dart';
import '../../core/utils/web_video_blob.dart';
import '../../data/dev_accounts.dart';
import '../../models/enums.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';
import '../../services/discovery_service.dart';
import '../../services/moderation_service.dart';
import '../../services/recommendation_service.dart';
import '../../services/video_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../widgets/naseem_button.dart';
import '../../widgets/premium_background.dart';
import '../../widgets/premium_states.dart';
import '../../widgets/upload_video_preview.dart';

/// TikTok-style upload: full-screen preview, caption overlay, one-tap Post.
class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key, this.onPosted});

  final VoidCallback? onPosted;

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _captionController = TextEditingController();
  final _videoService = VideoService();
  final _moderationService = ModerationService();
  final _recommendation = RecommendationService();
  final _discovery = DiscoveryService();
  final _picker = ImagePicker();

  Uint8List? _pickedVideoBytes;
  String? _pickedVideoName;
  String? _previewBlobUrl;
  String _videoMimeType = 'video/mp4';
  XFile? _pickedVideoFile;

  String _selectedCategory = 'reminders';
  VideoPrivacy _privacy = VideoPrivacy.public;
  bool _isUploading = false;

  bool get _hasSelectedVideo =>
      kIsWeb ? _pickedVideoBytes != null : _pickedVideoFile != null;

  @override
  void dispose() {
    _revokePreviewBlob();
    _captionController.dispose();
    super.dispose();
  }

  static const _maxWebUploadBytes = 200 * 1024 * 1024; // 200 MB

  UserModel? _uploadUser(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    if (user != null) return user;
    if (AppConstants.bypassAuthForDevelopment) return DevAccounts.guestCreator;
    return null;
  }

  Future<Uint8List?> _readWebVideoBytes(PlatformFile file) async {
    if (file.bytes != null && file.bytes!.isNotEmpty) {
      return file.bytes;
    }

    final stream = file.readStream;
    if (stream == null) return null;

    final builder = BytesBuilder(copy: false);
    await for (final chunk in stream) {
      builder.add(chunk);
    }
    final bytes = builder.takeBytes();
    return bytes.isEmpty ? null : bytes;
  }

  void _revokePreviewBlob() {
    if (kIsWeb && _previewBlobUrl != null && _previewBlobUrl!.isNotEmpty) {
      revokeWebBlobUrl(_previewBlobUrl!);
    }
    _previewBlobUrl = null;
  }

  static String _mimeForFileName(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.webm')) return 'video/webm';
    if (lower.endsWith('.mov')) return 'video/quicktime';
    if (lower.endsWith('.mkv')) return 'video/x-matroska';
    return 'video/mp4';
  }

  Future<void> _pickVideoFromGallery() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
        withData: kIsWeb,
        withReadStream: kIsWeb,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final name = file.name.trim().isNotEmpty ? file.name.trim() : 'video.mp4';
      final mime = _mimeForFileName(name);

      if (kIsWeb) {
        final bytes = await _readWebVideoBytes(file);
        if (bytes == null || bytes.isEmpty) {
          if (!mounted) return;
          _showMessage(
            'Could not read the video. Try a smaller MP4 file (under 200 MB).',
            isError: true,
          );
          return;
        }
        if (bytes.length > _maxWebUploadBytes) {
          if (!mounted) return;
          _showMessage(
            'Video is too large for web upload (max 200 MB).',
            isError: true,
          );
          return;
        }

        _revokePreviewBlob();
        setState(() {
          _pickedVideoBytes = bytes;
          _pickedVideoName = name;
          _videoMimeType = mime;
          _pickedVideoFile = null;
          _previewBlobUrl = createWebBlobUrl(bytes, mime);
        });
        return;
      }

      setState(() {
        _pickedVideoBytes = null;
        _pickedVideoName = name;
        _videoMimeType = mime;
        _pickedVideoFile = file.xFile;
        _previewBlobUrl = null;
      });
    } catch (e) {
      if (!mounted) return;
      _showMessage('Could not pick video: $e');
    }
  }

  Future<void> _recordVideo() async {
    final picked = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(minutes: 3),
    );
    if (picked == null) return;

    final name = 'recording_${DateTime.now().millisecondsSinceEpoch}.mp4';
    setState(() {
      _pickedVideoFile = picked;
      _pickedVideoName = name;
      _videoMimeType = 'video/mp4';
      _pickedVideoBytes = null;
      _previewBlobUrl = null;
    });
  }

  void _clearVideo({bool revokeBlob = true}) {
    if (revokeBlob) {
      _revokePreviewBlob();
    } else {
      _previewBlobUrl = null;
    }
    setState(() {
      _pickedVideoBytes = null;
      _pickedVideoName = null;
      _pickedVideoFile = null;
    });
  }

  void _showMessage(String text, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: isError ? 5 : 3),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDecorations.radiusLg),
        ),
      ),
    );
  }

  Future<void> _openPostSettings() async {
    var category = _selectedCategory;
    var privacy = _privacy;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.navyCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDecorations.radiusXl),
        ),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Post settings',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Category',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: category,
                    isExpanded: true,
                    dropdownColor: AppColors.navyLight,
                    style: const TextStyle(color: AppColors.textPrimary),
                    items: ContentPolicy.allowedCategories.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(ContentPolicy.categoryLabels[cat] ?? cat),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setSheetState(() => category = v);
                    },
                  ),
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Who can watch',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<VideoPrivacy>(
                    value: privacy,
                    isExpanded: true,
                    dropdownColor: AppColors.navyLight,
                    style: const TextStyle(color: AppColors.textPrimary),
                    items: VideoPrivacy.values.map((p) {
                      return DropdownMenuItem(value: p, child: Text(p.value));
                    }).toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setSheetState(() => privacy = v);
                    },
                  ),
                  const SizedBox(height: 20),
                  NaseemButton(
                    label: 'Done',
                    onPressed: () {
                      setState(() {
                        _selectedCategory = category;
                        _privacy = privacy;
                      });
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _post() async {
    if (!_hasSelectedVideo) {
      _showMessage('Select a video first', isError: true);
      return;
    }

    final user = _uploadUser(context);
    if (user == null || !user.canUpload) {
      _showMessage(
        'Sign in to post videos (dev guest should be auto-signed in).',
        isError: true,
      );
      return;
    }

    final caption = _captionController.text.trim();
    final title = caption.isNotEmpty
        ? (caption.length > 80 ? '${caption.substring(0, 80)}…' : caption)
        : (_pickedVideoName ?? 'New video');

    if (!AppConstants.bypassAuthForDevelopment &&
        !_moderationService.validateSync(
          title: title,
          description: caption,
          category: _selectedCategory,
        )) {
      _showMessage('Caption violates content policy', isError: true);
      return;
    }

    setState(() => _isUploading = true);

    final hashtags = _recommendation.extractHashtags(caption);
    final mentions = _recommendation.extractMentions(caption);
    final fileName = _pickedVideoName ?? 'video.mp4';
    final previewUrlForFeed = _previewBlobUrl;

    try {
      await _videoService.uploadVideo(
        videoBytes: kIsWeb ? _pickedVideoBytes : null,
        videoFile: kIsWeb ? null : _pickedVideoFile,
        webPreviewUrl: kIsWeb ? previewUrlForFeed : null,
        fileName: fileName,
        mimeType: _videoMimeType,
        userId: user.uid,
        userDisplayName: user.displayName,
        userPhotoUrl: user.photoUrl,
        title: title,
        description: caption,
        category: _selectedCategory,
        isUserVerified: user.isVerified || user.role.isScholar,
        hashtags: hashtags,
        mentions: mentions,
        privacy: _privacy.value,
        captions: caption.isNotEmpty ? caption : null,
      );

      if (hashtags.isNotEmpty) {
        try {
          await _discovery.upsertHashtags(hashtags);
        } catch (_) {}
      }

      if (AppConstants.bypassAuthForDevelopment && mounted) {
        await context.read<FeedProvider>().loadFeed(
              type: FeedType.forYou,
              userId: user.uid,
            );
      }

      if (!mounted) return;
      setState(() => _isUploading = false);
      _showMessage(
        AppConstants.bypassAuthForDevelopment
            ? 'Posted! Opening your Feed…'
            : 'Video submitted for review',
      );

      _captionController.clear();
      _clearVideo(revokeBlob: false);
      widget.onPosted?.call();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      _showMessage('Post failed: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      body: _hasSelectedVideo ? _buildComposeView() : _buildPickView(),
    );
  }

  Widget _buildPickView() {
    final bottomNavInset =
        MediaQuery.paddingOf(context).bottom + kBottomNavigationBarHeight + 12;

    return PremiumBackground(
      child: SafeArea(
        child: Column(
          children: [
            _buildTopBar(showPost: false),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppDecorations.purplePinkGradient,
                          boxShadow: AppDecorations.purpleGlow,
                        ),
                        child: const Icon(
                          Icons.video_library_outlined,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Create a post',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        kIsWeb
                            ? 'Choose a video from your device'
                            : 'Record or choose from gallery',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 32),
                      if (!kIsWeb)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: NaseemButton(
                            label: 'Record',
                            icon: Icons.videocam_outlined,
                            onPressed: _recordVideo,
                            outlined: true,
                          ),
                        ),
                      NaseemButton(
                        label: kIsWeb ? 'Select video' : 'Upload from gallery',
                        icon: Icons.upload_file_rounded,
                        onPressed: _pickVideoFromGallery,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, bottomNavInset),
              child: TextButton.icon(
                onPressed: _openPostSettings,
                icon: const Icon(Icons.settings_outlined,
                    color: AppColors.textSecondary),
                label: const Text(
                  'Category & privacy settings',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComposeView() {
    final categoryLabel =
        ContentPolicy.categoryLabels[_selectedCategory] ?? _selectedCategory;
    final bottomNavInset =
        MediaQuery.paddingOf(context).bottom + kBottomNavigationBarHeight + 12;

    return Stack(
      fit: StackFit.expand,
      children: [
        UploadVideoPreview(
          previewUrl: kIsWeb ? _previewBlobUrl : null,
          mobileFile: kIsWeb ? null : _pickedVideoFile,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.55),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.85),
              ],
              stops: const [0.0, 0.35, 1.0],
            ),
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              _buildTopBar(showPost: true),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    _SideTool(
                      icon: Icons.tune_rounded,
                      label: categoryLabel.split(' ').first,
                      onTap: _openPostSettings,
                    ),
                    const Spacer(),
                    _SideTool(
                      icon: Icons.close_rounded,
                      label: 'Remove',
                      onTap: () => _clearVideo(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller: _captionController,
                  maxLines: 3,
                  minLines: 1,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  decoration: const InputDecoration(
                    hintText: 'Describe your video… #hashtags @mentions',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, bottomNavInset),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_pickedVideoName != null)
                      Text(
                        _pickedVideoName!,
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 12),
                    NaseemButton(
                      label: 'Publish',
                      loading: _isUploading,
                      onPressed: _isUploading ? null : _post,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Category: $categoryLabel · ${_privacy.value}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_isUploading)
          Container(
            color: AppColors.overlay,
            child: const PremiumLoading(message: 'Posting…'),
          ),
      ],
    );
  }

  Widget _buildTopBar({required bool showPost}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: _hasSelectedVideo ? _clearVideo : null,
          ),
          const Expanded(
            child: Text(
              'New post',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (showPost)
            GestureDetector(
              onTap: _isUploading ? null : _post,
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  gradient: _isUploading ? null : AppDecorations.brandGradient,
                  color: _isUploading
                      ? AppColors.primaryGreen.withValues(alpha: 0.35)
                      : null,
                  borderRadius:
                      BorderRadius.circular(AppDecorations.radiusLg),
                  boxShadow: _isUploading ? null : AppDecorations.goldGlow,
                ),
                child: const Text(
                  'Post',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 88),
        ],
      ),
    );
  }
}

class _SideTool extends StatelessWidget {
  const _SideTool({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: AppDecorations.glass(opacity: 0.85),
            child: Icon(icon, color: AppColors.textPrimary, size: 22),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 64,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
