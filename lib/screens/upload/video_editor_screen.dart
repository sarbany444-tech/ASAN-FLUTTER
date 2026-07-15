import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/file_name_utils.dart';

/// Video editing screen — trim, text overlays, filter preview.
/// Full trim uses video_trimmer when a video path is provided.
class VideoEditorScreen extends StatefulWidget {
  const VideoEditorScreen({super.key, required this.videoName});
  final String videoName;

  @override
  State<VideoEditorScreen> createState() => _VideoEditorScreenState();
}

class _VideoEditorScreenState extends State<VideoEditorScreen> {
  double _trimStart = 0;
  double _trimEnd = 1;
  String _overlayText = '';
  String _filter = 'none';

  @override
  Widget build(BuildContext context) {
    final displayName = displayNameFromPath(widget.videoName);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Video'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, {
              'trimStart': _trimStart,
              'trimEnd': _trimEnd,
              'overlayText': _overlayText,
              'filter': _filter,
            }),
            child: const Text('Done', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: AppColors.primaryGreenDark,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.movie_edit, size: 64, color: Colors.white54),
                  const SizedBox(height: 12),
                  Text(
                    displayName,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  if (_overlayText.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _overlayText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Trim', style: Theme.of(context).textTheme.titleSmall),
                RangeSlider(
                  values: RangeValues(_trimStart, _trimEnd),
                  onChanged: (v) => setState(() {
                    _trimStart = v.start;
                    _trimEnd = v.end;
                  }),
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Text Overlay'),
                  onChanged: (v) => setState(() => _overlayText = v),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: ['none', 'warm', 'cool', 'vintage'].map((f) {
                    return ChoiceChip(
                      label: Text(f),
                      selected: _filter == f,
                      onSelected: (_) => setState(() => _filter = f),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
