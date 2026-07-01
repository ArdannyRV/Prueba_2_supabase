enum SyncStatus {
  pendingCreate,
  pendingUpdate,
  pendingDelete,
  synced,
  conflict,
}

extension SyncStatusExtension on SyncStatus {
  String toDb() {
    switch (this) {
      case SyncStatus.pendingCreate:
        return 'pending_create';
      case SyncStatus.pendingUpdate:
        return 'pending_update';
      case SyncStatus.pendingDelete:
        return 'pending_delete';
      case SyncStatus.synced:
        return 'synced';
      case SyncStatus.conflict:
        return 'conflict';
    }
  }

  static SyncStatus fromDb(String status) {
    switch (status) {
      case 'pending_create':
        return SyncStatus.pendingCreate;
      case 'pending_update':
        return SyncStatus.pendingUpdate;
      case 'pending_delete':
        return SyncStatus.pendingDelete;
      case 'synced':
        return SyncStatus.synced;
      case 'conflict':
        return SyncStatus.conflict;
      default:
        return SyncStatus.synced;
    }
  }
}
