class HiveBoxNames {
  static const auth = 'auth_box';
  static const task = 'task_box';
  static const project = 'project_box';
  static const settings = 'settings_box';
}

class HiveAuthKeys {
  static const users = 'users';
  static const currentUserId = 'current_user_id';
  static const pinHash = 'pin_hash';
}

class HiveTaskKeys {
  static const tasks = 'tasks';
  static const syncedUserId = 'synced_user_id';
  static const pendingSyncOperations = 'pending_sync_operations';
}

class HiveProjectKeys {
  static const projects = 'projects';
  static const taskProjectMap = 'task_project_map';
  static const syncedUserId = 'project_synced_user_id';
}

class HiveSettingsKeys {
  static const themeMode = 'theme_mode';
  static const onboardingSeen = 'onboarding_seen';
  static const subscribed = 'subscribed';
  static const scheduledReminderNotificationIds =
      'scheduled_reminder_notification_ids';
}
