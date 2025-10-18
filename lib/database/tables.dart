// Database table definitions and SQL statements

/// Table name for tasks
const String taskTableName = 'tasks';

/// Table name for progress records
const String progressTableName = 'progress_records';

/// SQL statement to create tasks table
const String createTaskTableSql = '''
  CREATE TABLE $taskTableName (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    brief TEXT NOT NULL,
    deadline INTEGER,
    create_time INTEGER NOT NULL,
    update_time INTEGER NOT NULL,
    priority INTEGER NOT NULL,
    status INTEGER NOT NULL
  )
''';

/// SQL statement to create progress_records table
const String createProgressTableSql = '''
  CREATE TABLE $progressTableName (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    task_id INTEGER NOT NULL,
    date INTEGER NOT NULL,
    hours_spent REAL NOT NULL,
    FOREIGN KEY (task_id) REFERENCES $taskTableName (id) ON DELETE CASCADE,
    UNIQUE(task_id, date)
  )
''';

/// SQL statement to create index on task_id in progress_records table
const String createProgressIndexSql = '''
  CREATE INDEX idx_progress_task_id ON $progressTableName (task_id)
''';

