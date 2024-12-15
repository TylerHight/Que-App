// lib/core/database/migrations/migrations_list.dart

import 'package:que_app/core/database/migrations/v1_initial_schema.dart';
import 'migration.dart';

final migrations = <Migration>[
  const V1InitialSchema(),
  // Add future migrations here
];