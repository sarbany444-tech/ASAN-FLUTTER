import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../providers/auth_provider.dart';
import '../../services/live_stream_service.dart';
import '../../widgets/naseem_app_bar.dart';
import '../../widgets/naseem_button.dart';
import '../../widgets/premium_background.dart';
import '../../widgets/premium_states.dart';

class LiveStreamsScreen extends StatelessWidget {
  const LiveStreamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = LiveStreamService();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const NaseemAppBar(title: 'Live Islamic Streams'),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: NaseemButton(
          label: 'Go Live',
          icon: Icons.live_tv_rounded,
          onPressed: () => _startLive(context),
          expand: false,
        ),
      ),
      body: PremiumBackground(
        child: StreamBuilder(
          stream: service.watchLiveStreams(),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const PremiumLoading(message: 'Finding live streams…');
            }
            final streams = snap.data!;
            if (streams.isEmpty) {
              return PremiumEmptyState(
                title: 'No live streams right now',
                subtitle:
                    'Start a live Islamic lecture or Quran session',
                icon: Icons.live_tv_rounded,
                actionLabel: 'Go Live',
                onAction: () => _startLive(context),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              itemCount: streams.length,
              itemBuilder: (_, i) {
                final stream = streams[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: AppDecorations.glass(opacity: 0.82),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDecorations.radiusXl),
                    ),
                    leading: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.pink, Color(0xFFE02020)],
                        ),
                        borderRadius:
                            BorderRadius.circular(AppDecorations.radiusMd),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.pink.withValues(alpha: 0.4),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      stream.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${stream.hostName} · ${stream.viewerCount} watching',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: AppColors.textSecondary),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LiveViewerScreen(streamId: stream.id),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _startLive(BuildContext context) async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    final service = LiveStreamService();
    final streamId = await service.startLiveStream(
      hostId: user.uid,
      hostName: user.displayName,
      title: 'Live Islamic Session',
      category: 'lectures',
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Live stream started: $streamId'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.navyCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDecorations.radiusLg),
          ),
        ),
      );
    }
  }
}

class LiveViewerScreen extends StatefulWidget {
  const LiveViewerScreen({super.key, required this.streamId});
  final String streamId;

  @override
  State<LiveViewerScreen> createState() => _LiveViewerScreenState();
}

class _LiveViewerScreenState extends State<LiveViewerScreen> {
  final _commentController = TextEditingController();
  final _service = LiveStreamService();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      body: Stack(
        children: [
          const PremiumBackground(
            showPattern: false,
            child: SizedBox.expand(),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.pink, Color(0xFFE02020)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.pink.withValues(alpha: 0.45),
                        blurRadius: 32,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.live_tv_rounded,
                      size: 44, color: Colors.white),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Live Stream',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'WebRTC/RTMP player integrates here in production',
                    style: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: MediaQuery.paddingOf(context).bottom + 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: AppDecorations.glass(opacity: 0.92),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Say something…',
                        hintStyle: TextStyle(color: AppColors.textSecondary),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppDecorations.brandGradient,
                        borderRadius:
                            BorderRadius.circular(AppDecorations.radiusMd),
                      ),
                      child: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 20),
                    ),
                    onPressed: () {
                      if (user == null || _commentController.text.isEmpty) {
                        return;
                      }
                      _service.sendLiveComment(
                        streamId: widget.streamId,
                        userId: user.uid,
                        userName: user.displayName,
                        text: _commentController.text,
                      );
                      _commentController.clear();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
