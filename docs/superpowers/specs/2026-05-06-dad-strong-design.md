# Dad Strong App – Design Spec
_Created: 2026-05-06_

---

## Ziel

Eine minimalistische Krafttraining-App für einen Vater mit wenig Schlaf, wenig Zeit und viel Verantwortung. Kein Entertainment, kein Social, keine Gamification. Ein digitales Whiteboard das genau das tut was das analoge Brett tut – und nichts mehr.

---

## Trainingsplan (hardcoded, nicht änderbar)

### Training A
| Übung | Arbeitssätze | Wdh-Bereich | Progression bei | Besonderheit |
|-------|-------------|-------------|-----------------|--------------|
| LH-Kniebeuge | 2 | 4–8 | ≥ 8 Wdh | Erste Übung → spez. Warmup |
| LH-Bankdrücken | 2 | 4–8 | ≥ 8 Wdh | |
| LH-Rudern | 2 | 4–8 | ≥ 8 Wdh | |
| KH-Bulg. Split Squat | 1 pro Bein | 6–10 | ≥ 10 Wdh | Bilateral: L → 1min Pause → R |
| Farmer Walk L/R | 1 pro Seite | 60s | 60s geschafft | Zeitbasiert, Gewicht steigerbar |

### Training B
| Übung | Arbeitssätze | Wdh-Bereich | Progression bei | Besonderheit |
|-------|-------------|-------------|-----------------|--------------|
| LH-Kreuzheben | 2 | 4–6 | ≥ 6 Wdh | Erste Übung → spez. Warmup |
| LH-Schulterdrücken | 2 | 4–8 | ≥ 8 Wdh | |
| Klimmzüge | 2 | 6–10 | ≥ 10 Wdh | |
| KH-Step-Up | 1 pro Bein | 6–10 | ≥ 10 Wdh | Bilateral: L → 1min Pause → R |

---

## Anstrengungsmarker (manuell, kein automatisches System)

Der User setzt nach jedem Satz optional einen Anstrengungsmarker – ähnlich wie auf dem Whiteboard das `*` bei Bankdrücken.

| Marker | Bedeutung |
|--------|-----------|
| _(leer)_ | Hätte noch mehr Wiederholungen gehabt |
| `*` | Hätte keine weitere Wiederholung geschafft – nah am Limit |
| `**` | Absolut brutal – über die eigene Grenze gegangen |

- Der Marker wird **vom User manuell gesetzt** – die App setzt nichts automatisch
- Er wird zusammen mit Wdh und Gewicht gespeichert
- Er erscheint in der Historienansicht als `6 × 100 kg *`
- Die App erhöht **NIEMALS** automatisch das Gewicht – das entscheidet der User selbst

---

## Screen-Flow

```
HomeScreen
  └─▶ WorkoutScreen
        Phase 1: General Warmup
          └── 5 Runden × 30s AMRAP + 5s Wechselpause (visuell klar getrennt)
        Phase 2: Specific Warmup (nur für erste Übung: Kniebeuge / Kreuzheben)
          └── Stange → 50% × 5 → 70% × 5,3 → 90% × 1-2
              Je Satz: 1:30 Timer danach
        Phase 3: Arbeitssatz-Schleife
          └── SetScreen → RestScreen (auto-advance) → [nächster Satz]
        Phase 4: Übungswechsel-Pause (2 Min, skipbar)
          └── Zeigt nächste Übung + letztes Gewicht/Wdh als Motivation
        [Schleife für alle Übungen]
  └─▶ SummaryScreen (Gesamtdauer, gespeicherte Sätze mit Markern)

MonthlyProgressScreen
  └── Poppt automatisch auf wenn erster Trainingstag eines neuen Monats
  └── Zeigt % Steigerung pro Übung (Vergleich Monatsanfang vs. Monatsende)
```

---

## Screen-Beschreibungen

### HomeScreen
- Zeigt: „Nächstes Training: **A**" oder „**B**"
- Tags auf vergangenen Trainings: Datum + „✓" (abgehakt)
- Alternierung A/B wird automatisch getrackt (letztes gespeichertes Training bestimmt nächstes)
- Einziger Button: **Training starten**
- Oben: letzte 3 Trainings als kompakte Zeile (Datum + Typ)

### WorkoutScreen – Phase 1: General Warmup
- 5 Runden × 30s Countdown + 5s Wechselpause
- Großer Timer, Rundenanzahl sichtbar (z.B. „Runde 3 / 5")
- Kein Übungs-Tracking – nur Timer
- Am Ende: automatischer Übergang zu Phase 2

### WorkoutScreen – Phase 2: Specific Warmup
- Zeigt berechnete Gewichte basierend auf letztem **Arbeitssatz-Gewicht** (Gesamtgewicht inkl. Stange):
  - Stange (20 kg fix)
  - 50% des letzten Gewichts → gerundet auf nächste 2.5 kg × 5 Wdh
  - 70% → gerundet auf nächste 2.5 kg × 5, dann × 3 Wdh
  - 90% → gerundet auf nächste 2.5 kg × 1-2 Wdh
- Beim **ersten Training überhaupt** (keine Historie): nur Stange anzeigen, kein Prozent-Warmup
- Nach jedem Satz: 1:30 Timer (nicht skipbar)
- User bestätigt jeden Satz manuell (kein Auto-Log, Warmup wird **nicht** gespeichert)

### WorkoutScreen – SetScreen (Arbeitssatz)
- Große Übungsbezeichnung (z.B. „Kniebeuge")
- „Satz 1 von 2"
- Letztes Ergebnis gut sichtbar: „Letztes Mal: 6 × 100 kg"
- Zielbereich: „Ziel: 4–8 Wdh"
- Großer zentraler Button: **„Satz starten"** → wechselt zu RestScreen
- Oben rechts: Gesamtdauer des Trainings (läuft immer mit, mm:ss)

### WorkoutScreen – RestScreen (Pause nach Satz)
- Oben: „Zu schlagen: 6 × 100 kg" (letztes Ergebnis)
- Mitte: großer Ring-Timer (wie Meditations-Ring in polizen_app) – **3 Minuten**
- Timer läuft automatisch, nicht pausierbar, nicht swipebar
- Unten links: scrollbarer Reps-Picker (Zahlen, wie Ladder-App-Referenz)
- Unten rechts: scrollbarer Gewichts-Picker (in 0.5kg-Schritten)
- **Standardwert beider Picker:** letztes gespeichertes Ergebnis dieser Übung; beim ersten Training überhaupt: 0 Wdh / 20 kg (Stange)
- Unten Mitte (unter Timer): Anstrengungsmarker – 3 Optionen tippbar: `–` / `*` / `**` (Standard: `–`)
- Wenn Timer auf 10s → Froschklicker-Sound (schnelles Klicken)
- Wenn Timer auf 0 → Piep-Sound + **Auto-Save** (Wdh + Gewicht + Marker) + automatischer Übergang
- Oben rechts: Gesamtdauer (läuft mit)

### WorkoutScreen – Übungswechsel-Pause (2 Min, skipbar)
- „Als nächstes: Bankdrücken"
- Letztes Ergebnis der nächsten Übung: „Letztes Mal: 8 × 100 kg *"
- Timer 2:00, skipbar
- Ruhige Darstellung, minimaler Text

### Sonderfall: Bulg. Split Squat & Step-Up (bilateral)
- SetScreen zeigt „Linkes Bein"
- RestScreen: 1 Minute (nicht skipbar) mit gleicher Picker-UI
- Danach: SetScreen „Rechtes Bein"
- Danach: normale 2-Min Übungswechsel-Pause

### Sonderfall: Farmer Walk (zeitbasiert)
- SetScreen: „Farmer Walk Links – 60 Sekunden"
- RestScreen: Gewichts-Picker (kein Reps-Picker, stattdessen „60s" fest angezeigt)
- 1 Minute Pause zwischen Seiten

### SummaryScreen
- „Training A abgeschlossen"
- Gesamtdauer
- Kompakte Übersicht aller Arbeitssätze mit Wdh / Gewicht / Marker (z.B. `6 × 100 kg *`)
- **Auto-Save** – kein Speichern-Button, Training wird beim Abschließen automatisch gespeichert

### MonthlyProgressScreen
- Erscheint automatisch am ersten Trainingstag eines neuen Monats, **nur wenn** im Vormonat mindestens 2 Trainings gespeichert wurden (sonst kein Popup)
- Vergleich: bestes Gewicht der ersten Woche des Vormonats vs. letztes Gewicht des Vormonats
- Listet alle Übungen mit % Veränderung
- Beispiel: „Kniebeuge: +8%" oder „Kreuzheben: ±0%"
- Kein Chart, nur Zahlen
- Dismiss-Button: „Weiter zum Training"

---

## Initiale Seed-Daten (Whiteboard-Stand bei App-Start)

Beim ersten App-Start werden die aktuellen Whiteboard-Werte als letzte Session vorgeladen, damit Warmup-Berechnung und „Letztes Mal"-Anzeige sofort funktionieren.

### Letztes Training A (Seed)
| Übung | Satz 1 | Satz 2 |
|-------|--------|--------|
| LH-Kniebeuge | 6 × 100 kg | 5 × 100 kg |
| LH-Bankdrücken | 8 × 100 kg | 8 × 100 kg |
| LH-Rudern | 8 × 100 kg | 8 × 100 kg |
| KH-Bulg. Split Squat (L) | 3 × 60 kg | – |
| KH-Bulg. Split Squat (R) | 3 × 60 kg | – |
| Farmer Walk (L) | 60s × 20 kg | – |
| Farmer Walk (R) | 60s × 20 kg | – |

### Letztes Training B (Seed)
| Übung | Satz 1 | Satz 2 |
|-------|--------|--------|
| LH-Kreuzheben | 6 × 100 kg | 6 × 100 kg |
| LH-Schulterdrücken | 8 × 100 kg | 8 × 100 kg |
| Klimmzüge | 8 × BK | 8 × BK |
| KH-Step-Up (L) | 3 × 60 kg | – |
| KH-Step-Up (R) | 3 × 60 kg | – |

_BK = Bodyweight (Klimmzüge ohne Zusatzgewicht)_
_Seed-Datum: 2026-05-05 (Training A), 2026-05-01 (Training B) – als vergangene Sessions gespeichert_

---

## Datenmodell

```
WorkoutSession
  ├── id (String, UUID)
  ├── type (enum: A | B)
  ├── date (DateTime)
  ├── totalDurationSeconds (int)
  └── exerciseLogs (List<ExerciseLog>)

ExerciseLog
  ├── exerciseId (String, z.B. "squat")
  └── sets (List<WorkoutSet>)

WorkoutSet
  ├── setIndex (int)
  ├── reps (int, 0 bei zeitbasiert)
  ├── weightKg (double)
  ├── durationSeconds (int, 0 bei reps-basiert)
  └── effort (enum: none | single | double)  // –, *, **
```

---

## Architektur

**Stack:** Flutter + Dart, Riverpod, Hive, auto_route

**Schichten (Clean Architecture):**

```
lib/
├── core/
│   ├── constants/     # exercises_data.dart, timer_constants.dart
│   ├── error/         # failure.dart
│   ├── routes/        # app_router.dart (auto_route)
│   └── theme/         # colors.dart, typography.dart
├── domain/
│   ├── entities/      # WorkoutSession, ExerciseLog, WorkoutSet, Exercise
│   ├── repositories/  # workout_repository.dart (abstract)
│   └── usecases/      # save_session, get_last_session, get_monthly_progress
├── data/
│   ├── models/        # Hive-annotierte DTOs
│   ├── datasources/   # workout_local_datasource.dart
│   └── repositories/  # workout_repository_impl.dart
└── presentation/
    ├── providers/     # workout_session_provider, rest_timer_provider,
    │                  # training_history_provider, monthly_progress_provider
    ├── pages/
    │   ├── home/
    │   ├── workout/   # view + widgets (warmup, work_set, rest, prep)
    │   └── monthly_summary/
    └── widgets/       # rest_ring_widget, scroll_picker_widget
```

**State Management:**
- `WorkoutSessionNotifier` (StateNotifier): verwaltet aktive Session (Phase, aktuelle Übung, aktueller Satz, Logs)
- `RestTimerNotifier` (StateNotifier): Countdown, Klicker/Piep-Events
- `TrainingHistoryNotifier` (AsyncNotifier): liest/schreibt Hive

---

## Pakete

| Paket | Version | Zweck |
|-------|---------|-------|
| `flutter_riverpod` | ^2.6.x | State Management |
| `riverpod_annotation` | ^2.6.x | Code-Generator |
| `hive_flutter` | ^1.1.x | Lokale Datenbank |
| `hive_generator` | ^2.x | Code-Generator für Hive |
| `auto_route` | ^10.x | Navigation |
| `auto_route_generator` | ^10.x | Code-Generator |
| `build_runner` | ^2.4.x | Code-Generator Runner |
| `audioplayers` | ^6.x | Timer-Sounds (Klicker + Piep) |
| `google_fonts` | ^6.x | Typografie |
| `uuid` | ^4.x | IDs für Sessions |

---

## Design-System

**Dark Mode only.**

| Rolle | Hex |
|-------|-----|
| Background | `#0A0A0A` |
| Karten / Flächen | `#141414` |
| Akzent | `#E8E8E8` (weiß-grau, taktisch) |
| Progression-Stern | `#C8A951` (gedämpftes Gold) |
| Text primär | `#FFFFFF` |
| Text sekundär | `#666666` |
| Timer-Ring aktiv | `#FFFFFF` |
| Timer-Ring Hintergrund | `#1E1E1E` |

**Typografie:** Google Fonts – `Inter` (klar, funktional, militärisch-reduziert)

---

## Was bewusst NICHT gebaut wird (MVP)

- Keine Onboarding-Screens
- Kein Settings-Screen (nichts ist konfigurierbar)
- Keine Charts oder Visualisierungen (nur Zahlen)
- Keine Push-Notifications
- Keine Cloud / kein Backend
- Keine Anmeldung
- Kein Social
- Keine Übungsvideos
- Kein Volumen-Tracking (keine Summen, keine Tonnage)
- Keine Kalender-Ansicht
- Kein manuelles Gewicht-Erhöhen durch die App
