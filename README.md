# week3ict107

A Flutter app built for ICT107 Week 3, covering:

- **Task 1** — Git/GitHub repository workflow.
- **Task 2** — Client-side data management: a local SQLite database
  (via `sqflite`) with full CRUD, plus quick-import from a bundled
  JSON asset.

## Getting Started

```bash
flutter pub get
flutter run
```

## Task 2: SQLite CRUD

- [lib/models/note.dart](lib/models/note.dart) — the `Note` data model
  (maps to/from both SQLite rows and JSON).
- [lib/db/database_helper.dart](lib/db/database_helper.dart) — a
  singleton `DatabaseHelper` that opens `notes.db` and exposes
  Create/Read/Update/Delete methods backed by raw SQL
  (`INSERT`, `SELECT`, `UPDATE`, `DELETE`).
- [lib/screens/notes_screen.dart](lib/screens/notes_screen.dart) — the
  CRUD screen: add/edit notes via a dialog, toggle "done" with a
  checkbox, delete with confirmation, and an **Import from JSON**
  button (top-right of the app bar) that reads
  [assets/notes.json](assets/notes.json) and bulk-inserts it into the
  database.
- Reach the screen from the home page via the **"Open SQLite Notes
  (CRUD)"** button or the **SQLite** footer tab.

sqflite only ships native SQLite bindings for Android/iOS/macOS, so
`database_helper.dart` swaps in `sqflite_common_ffi` on Windows/Linux
desktop so the same CRUD code also runs there.

## Task 1: Git / GitHub strategy

This repo uses a simple **trunk-based** workflow suited to a
single-developer coursework project:

- `main` is always kept in a working, buildable state.
- Small feature branches (e.g. `feature/sqlite-crud`,
  `feature/json-import`) are created for each task, merged into
  `main` via a Pull Request once done, then deleted.
- Commits are small and scoped to one logical change, with messages
  in the form `type: short description` (e.g. `feat: add SQLite CRUD
  notes screen`).

**Pull strategy** (before starting new work, or on another machine):

```bash
git checkout main
git pull origin main
```

**Push strategy** (after finishing a change):

```bash
git checkout -b feature/my-change
git add <files>
git commit -m "feat: describe the change"
git push -u origin feature/my-change
# open a Pull Request on GitHub, review, then merge into main
```

For quick coursework iterations directly on `main`:

```bash
git pull origin main      # always pull before you start
git add <files>
git commit -m "feat: describe the change"
git push origin main
```

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)
