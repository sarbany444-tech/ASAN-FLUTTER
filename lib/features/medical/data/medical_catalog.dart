import 'package:flutter/material.dart';

/// Health education categories for the medical platform section.
class MedicalCatalog {
  MedicalCatalog._();

  static const disclaimer =
      'This content is for educational purposes only and does not replace '
      'professional medical advice, diagnosis, or treatment. Always consult '
      'a qualified healthcare provider.';

  static const categories = [
    MedicalCategory(
      'health_education',
      'Health Education',
      'Learn fundamentals of health and wellness',
      Icons.health_and_safety_outlined,
      0xFF0277BD,
    ),
    MedicalCategory(
      'medical_lectures',
      'Medical Lectures',
      'Expert lectures from verified doctors',
      Icons.medical_information_outlined,
      0xFF1565C0,
    ),
    MedicalCategory(
      'first_aid',
      'First Aid',
      'Emergency response and basic first aid',
      Icons.emergency_outlined,
      0xFFC62828,
    ),
    MedicalCategory(
      'nutrition',
      'Nutrition',
      'Healthy eating and dietary guidance',
      Icons.restaurant_outlined,
      0xFF2E7D32,
    ),
    MedicalCategory(
      'mental_health',
      'Mental Health',
      'Wellbeing, stress, and emotional health',
      Icons.psychology_outlined,
      0xFF6A1B9A,
    ),
    MedicalCategory(
      'awareness',
      'Awareness Campaigns',
      'Public health awareness and prevention',
      Icons.campaign_outlined,
      0xFFE65100,
    ),
    MedicalCategory(
      'live_sessions',
      'Live Medical Sessions',
      'Join live Q&A with healthcare professionals',
      Icons.live_tv_outlined,
      0xFF00838F,
    ),
  ];
}

class MedicalCategory {
  const MedicalCategory(
    this.id,
    this.title,
    this.description,
    this.icon,
    this.color,
  );

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int color;
}
