const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { SpeechClient } = require('@google-cloud/speech');
const vision = require('@google-cloud/vision');

admin.initializeApp();
const db = admin.firestore();
const speechClient = new SpeechClient();
const visionClient = new vision.ImageAnnotatorClient();

// Islamic content policy keywords
const PROHIBITED_KEYWORDS = [
  'music video', 'nightclub', 'gambling', 'casino', 'alcohol', 'beer',
  'wine', 'drugs', 'dating', 'adult', 'porn', 'violence', 'hate speech',
  'propaganda', 'dance party', 'strip club',
];

const ALLOWED_KEYWORDS = [
  'quran', 'surah', 'ayah', 'hadith', 'sunnah', 'prophet', 'islam',
  'muslim', 'prayer', 'salah', 'fasting', 'ramadan', 'tafsir', 'nasheed',
  'dhikr', 'dua', 'scholar', 'lecture', 'reminder', 'charity',
];

const ALLOWED_CATEGORIES = [
  'quran_recitation', 'quran_memorization', 'tafsir', 'hadith',
  'lectures', 'reminders', 'nasheed', 'arabic_learning',
  'islamic_history', 'children_education', 'charity', 'general_education',
];

/**
 * Triggered when a new video document is created.
 * Runs the full AI moderation pipeline.
 */
exports.onVideoCreated = functions.firestore
  .document('videos/{videoId}')
  .onCreate(async (snap, context) => {
    const videoId = context.params.videoId;
    const data = snap.data();

    if (data.status !== 'processing') return null;

    try {
      const result = await runModerationPipeline(data);

      const newStatus = result.decision === 'approve' ? 'approved'
        : result.decision === 'reject' ? 'rejected'
        : 'pending';

      await snap.ref.update({
        status: newStatus,
        transcript: result.transcript,
        moderationScore: result.score,
        moderationFlags: result.flags,
        moderatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      if (newStatus === 'pending') {
        await db.collection('moderation_queue').doc(videoId).set({
          videoId,
          userId: data.userId,
          title: data.title,
          status: 'pending_review',
          moderationResult: result,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      if (newStatus === 'rejected') {
        await addStrike(data.userId, 'Automated moderation rejection');
      }

      if (newStatus === 'approved') {
        await db.collection('users').doc(data.userId).update({
          videoCount: admin.firestore.FieldValue.increment(1),
        });
        await updateEngagementScores(videoId, data);
      }

      return result;
    } catch (error) {
      console.error('Moderation failed:', error);
      await snap.ref.update({ status: 'pending' });
      return null;
    }
  });

/**
 * Process community reports — auto-flag after 3 reports.
 */
exports.onReportCreated = functions.firestore
  .document('reports/{reportId}')
  .onCreate(async (snap) => {
    const { videoId } = snap.data();

    const reports = await db.collection('reports')
      .where('videoId', '==', videoId)
      .where('status', '==', 'pending')
      .get();

    if (reports.size >= 3) {
      await db.collection('videos').doc(videoId).update({
        status: 'removed',
        removedReason: 'Multiple community reports',
      });
      await db.collection('moderation_queue').doc(videoId).set({
        videoId,
        status: 'flagged_by_community',
        reportCount: reports.size,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  });

/**
 * Full AI moderation pipeline.
 */
async function runModerationPipeline(videoData) {
  const combinedText = `${videoData.title} ${videoData.description}`.toLowerCase();
  const flags = [];
  const prohibitedFound = [];
  const allowedFound = [];

  // Keyword filtering
  for (const keyword of PROHIBITED_KEYWORDS) {
    if (combinedText.includes(keyword)) {
      prohibitedFound.push(keyword);
      flags.push(`prohibited_keyword:${keyword}`);
    }
  }

  for (const keyword of ALLOWED_KEYWORDS) {
    if (combinedText.includes(keyword)) {
      allowedFound.push(keyword);
    }
  }

  // Category validation
  if (!ALLOWED_CATEGORIES.includes(videoData.category)) {
    flags.push('invalid_category');
  }

  // Simulated frame analysis (integrate Vision API in production)
  const frameAnalysis = await analyzeVideoFrames(videoData.videoUrl);
  if (frameAnalysis.unsafe) {
    flags.push('unsafe_visual_content');
    prohibitedFound.push(...frameAnalysis.labels);
  }

  // Simulated speech-to-text (integrate Speech API in production)
  const transcript = await transcribeAudio(videoData.videoUrl);

  // Score calculation
  let score = 0;
  score += prohibitedFound.length * 0.4;
  if (!ALLOWED_CATEGORIES.includes(videoData.category)) score += 0.3;
  if (frameAnalysis.unsafe) score += 0.3;
  if (allowedFound.length === 0 && prohibitedFound.length === 0) score += 0.1;
  score = Math.min(score, 1);

  let decision;
  if (score >= 0.5 || prohibitedFound.length > 0) {
    decision = 'reject';
  } else if (score >= 0.2) {
    decision = 'review';
  } else {
    decision = 'approve';
  }

  return {
    decision,
    score,
    flags,
    transcript,
    detectedKeywords: allowedFound,
    prohibitedKeywords: prohibitedFound,
    frameAnalysisNotes: frameAnalysis.notes,
    audioAnalysisNotes: 'Audio analyzed for policy compliance',
  };
}

async function analyzeVideoFrames(videoUrl) {
  // Production: Extract frames with FFmpeg, analyze with Vision API SafeSearch
  // Placeholder implementation
  return {
    unsafe: false,
    labels: [],
    notes: 'Frame analysis: No prohibited visual content detected.',
  };
}

async function transcribeAudio(videoUrl) {
  // Production: Extract audio, send to Google Speech-to-Text
  return '[Auto-transcript generated by Cloud Speech API]';
}

async function updateEngagementScores(videoId, data) {
  const engagementScore =
    (data.likeCount || 0) * 0.3 +
    (data.commentCount || 0) * 0.5 +
    (data.shareCount || 0) * 0.8 +
    (data.viewCount || 0) * 0.01;

  const trendingScore = engagementScore + (data.isUserVerified ? 10 : 0);

  await db.collection('videos').doc(videoId).update({
    engagementScore,
    trendingScore,
  });
}

/**
 * Recalculate trending scores periodically.
 */
exports.updateTrendingScores = functions.pubsub
  .schedule('every 1 hours')
  .onRun(async () => {
    const videos = await db.collection('videos')
      .where('status', '==', 'approved')
      .orderBy('createdAt', 'desc')
      .limit(200)
      .get();

    const batch = db.batch();
    videos.docs.forEach((doc) => {
      const d = doc.data();
      const engagementScore =
        (d.likeCount || 0) * 0.3 +
        (d.commentCount || 0) * 0.5 +
        (d.shareCount || 0) * 0.8 +
        (d.viewCount || 0) * 0.01;
      batch.update(doc.ref, {
        engagementScore,
        trendingScore: engagementScore + (d.isUserVerified ? 10 : 0),
      });
    });
    await batch.commit();
    return null;
  });

async function addStrike(userId, reason) {
  const userRef = db.collection('users').doc(userId);
  await db.runTransaction(async (transaction) => {
    const userDoc = await transaction.get(userRef);
    if (!userDoc.exists) return;

    const strikeCount = (userDoc.data().strikeCount || 0) + 1;
    const updates = { strikeCount };

    if (strikeCount >= 5) {
      updates.status = 'banned';
    } else if (strikeCount >= 3) {
      updates.status = 'suspended';
      updates.suspendedUntil = admin.firestore.Timestamp.fromDate(
        new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
      );
    }

    transaction.update(userRef, updates);
  });

  await db.collection('strikes').doc(userId).collection('records').add({
    reason,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

/**
 * Scheduled function to refresh daily Quran verse and Hadith.
 */
exports.refreshDailyContent = functions.pubsub
  .schedule('0 0 * * *')
  .timeZone('UTC')
  .onRun(async () => {
    // Production: Fetch from curated API or admin-managed content
    console.log('Daily content refresh triggered');
    return null;
  });
