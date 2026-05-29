import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'expert_home.dart' hide ExpertAccountPage;
import 'expert_artikel.dart';
import 'expert_consult.dart';
import 'expert_setting.dart';

const Color kJadMain = Color(0xFF5DCFCF);
const Color kJadTeal = Color(0xFF76EAD0);
const Color kJadBlue = Color(0xFF76D7EA);
const Color kJadLGreen = Color(0xFFD0FF99);
const Color kJadScaffold = Color(0xFFF0F4F3);

// ─── Models ───────────────────────────────────────────────────────────────────
class TimeSlot {
  int startHour;
  int startMin;
  int endHour;
  int endMin;

  TimeSlot({
    required this.startHour,
    required this.startMin,
    required this.endHour,
    required this.endMin,
  });

  String get label {
    final s = _fmt(startHour, startMin);
    final e = _fmt(endHour, endMin);
    return '$s – $e';
  }

  String _fmt(int h, int m) {
    final period = h >= 12 ? 'PM' : 'AM';
    final hh = h == 0
        ? 12
        : h > 12
            ? h - 12
            : h;
    final mm = m.toString().padLeft(2, '0');
    return '$hh:$mm $period';
  }
}

class DaySchedule {
  final String day;
  bool isActive;
  List<TimeSlot> slots;

  DaySchedule({
    required this.day,
    this.isActive = false,
    List<TimeSlot>? slots,
  }) : slots = slots ?? [];

  bool get is24h => isActive && slots.isEmpty;
}

// ─── Screen ───────────────────────────────────────────────────────────────────
class ExpertSettingJadwalPage extends StatefulWidget {
  const ExpertSettingJadwalPage({super.key});

  @override
  State<ExpertSettingJadwalPage> createState() =>
      _ExpertSettingJadwalPageState();
}

class _ExpertSettingJadwalPageState extends State<ExpertSettingJadwalPage> {
  int navIndex = 3;
  bool isSaving = false;

  int selectedDuration = 30;
  final List<int> durationOptions = [15, 30, 45, 60, 90, 120];

  late List<DaySchedule> schedule;

  @override
  void initState() {
    super.initState();

    schedule = [
      DaySchedule(
        day: 'Monday',
        isActive: true,
        slots: [
          TimeSlot(startHour: 9, startMin: 0, endHour: 12, endMin: 0),
          TimeSlot(startHour: 13, startMin: 0, endHour: 16, endMin: 0),
        ],
      ),
      DaySchedule(
        day: 'Tuesday',
        isActive: true,
        slots: [
          TimeSlot(startHour: 10, startMin: 0, endHour: 15, endMin: 0),
        ],
      ),
      DaySchedule(day: 'Wednesday', isActive: false),
      DaySchedule(
        day: 'Thursday',
        isActive: true,
        slots: [
          TimeSlot(startHour: 14, startMin: 0, endHour: 18, endMin: 0),
        ],
      ),
      DaySchedule(day: 'Friday', isActive: false),
      DaySchedule(day: 'Saturday', isActive: true),
      DaySchedule(day: 'Sunday', isActive: false),
    ];
  }

  List<TimeOfDay> _startTimes() {
    final List<TimeOfDay> times = [];

    for (int h = 0; h < 24; h++) {
      times.add(TimeOfDay(hour: h, minute: 0));
    }

    return times;
  }

  TimeOfDay _endTime(TimeOfDay start) {
    final total = start.hour * 60 + start.minute + selectedDuration;

    return TimeOfDay(
      hour: (total ~/ 60) % 24,
      minute: total % 60,
    );
  }

  String _fmtTime(TimeOfDay t) {
    final period = t.hour >= 12 ? 'PM' : 'AM';
    final h = t.hour == 0
        ? 12
        : t.hour > 12
            ? t.hour - 12
            : t.hour;
    final m = t.minute.toString().padLeft(2, '0');

    return '$h:$m $period';
  }

  void _showAddSlotPicker(int dayIndex) {
    _showSlotPicker(dayIndex: dayIndex);
  }

  void _editSlot(int dayIndex, int slotIndex) {
    _showSlotPicker(
      dayIndex: dayIndex,
      slotIndex: slotIndex,
    );
  }

  void _showSlotPicker({
    required int dayIndex,
    int? slotIndex,
  }) {
    final day = schedule[dayIndex];
    final starts = _startTimes();
    final bool isEdit = slotIndex != null;

    TimeOfDay selectedStart;

    if (isEdit) {
      final slot = day.slots[slotIndex];
      selectedStart = TimeOfDay(
        hour: slot.startHour,
        minute: slot.startMin,
      );
    } else {
      selectedStart = starts.first;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (sheetCtx, setSheet) {
            final media = MediaQuery.of(sheetCtx);
            final maxSheetHeight = media.size.height * 0.86;

            return Padding(
              padding: EdgeInsets.only(
                bottom: media.viewInsets.bottom,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: maxSheetHeight,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(26),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 42,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: kJadTeal.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.access_time_rounded,
                                color: kJadMain,
                                size: 19,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                isEdit
                                    ? 'Edit Time Slot — ${day.day}'
                                    : 'Add Time Slot — ${day.day}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Session duration: $selectedDuration min · End time is calculated automatically',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Start Time',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 6),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              childAspectRatio: 2.15,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                            ),
                            itemCount: starts.length,
                            itemBuilder: (ctx, i) {
                              final t = starts[i];
                              final isSel = t == selectedStart;

                              return GestureDetector(
                                onTap: () {
                                  setSheet(() {
                                    selectedStart = t;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSel
                                        ? kJadMain
                                        : const Color(0xFFF0F4F3),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSel
                                          ? kJadMain
                                          : Colors.grey.shade200,
                                      width: 1.2,
                                    ),
                                    boxShadow: isSel
                                        ? [
                                            BoxShadow(
                                              color: kJadMain.withOpacity(0.22),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Text(
                                    _fmtTime(t),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color:
                                          isSel ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: kJadTeal.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 17,
                                color: kJadMain,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Session: ${_fmtTime(selectedStart)} – ${_fmtTime(_endTime(selectedStart))} ($selectedDuration min)',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: kJadMain,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        GestureDetector(
                          onTap: () {
                            final end = _endTime(selectedStart);

                            setState(() {
                              final newSlot = TimeSlot(
                                startHour: selectedStart.hour,
                                startMin: selectedStart.minute,
                                endHour: end.hour,
                                endMin: end.minute,
                              );

                              if (isEdit) {
                                day.slots[slotIndex] = newSlot;
                              } else {
                                day.slots.add(newSlot);
                              }

                              day.slots.sort(
                                (a, b) =>
                                    (a.startHour * 60 + a.startMin).compareTo(
                                  b.startHour * 60 + b.startMin,
                                ),
                              );
                            });

                            Navigator.pop(sheetCtx);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [kJadBlue, kJadMain],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: kJadMain.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              isEdit ? 'Save Changes' : 'Add Slot',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _deleteSlot(int dayIndex, int slotIndex) {
    setState(() {
      schedule[dayIndex].slots.removeAt(slotIndex);
    });
  }

  void _handleSave() {
    setState(() => isSaving = true);

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;

      setState(() => isSaving = false);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kJadTeal, kJadMain],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: kJadMain.withOpacity(0.3),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Schedule Saved!',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your availability has been updated. Users can now book sessions based on your new schedule.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: kJadMain,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: kJadMain.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      'Done',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void onNavTapped(int index) {
    if (index == navIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ExpertHomePage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ExpertArticlePage()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ExpertConsultPage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ExpertAccountPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kJadScaffold,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDurationPicker(),
                  const SizedBox(height: 20),
                  Text(
                    'Availability',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Set your consultation hours. Toggle a day ON without adding time slots to mark yourself as available 24/7 for that day.',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...schedule.asMap().entries.map(
                        (e) => _buildDayCard(e.key, e.value),
                      ),
                  const SizedBox(height: 16),
                  _buildTipsCard(),
                  const SizedBox(height: 24),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kJadBlue, kJadTeal],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Manage Schedule',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDurationPicker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kJadBlue, kJadTeal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: kJadMain.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.timer_outlined,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Session Duration',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Time slot options will adjust to match this duration',
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: durationOptions.map((d) {
              final isSel = d == selectedDuration;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDuration = d;

                    for (final day in schedule) {
                      day.slots.clear();
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSel ? Colors.white : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          isSel ? Colors.white : Colors.white.withOpacity(0.4),
                    ),
                  ),
                  child: Text(
                    d < 60
                        ? '$d min'
                        : '${d ~/ 60}h${d % 60 > 0 ? ' ${d % 60}m' : ''}',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSel ? kJadMain : Colors.white,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(int index, DaySchedule day) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: day.isActive
            ? Border.all(
                color: kJadTeal.withOpacity(0.3),
                width: 1.2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    day.day,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color:
                          day.isActive ? Colors.black87 : Colors.grey.shade500,
                    ),
                  ),
                ),
                Switch(
                  value: day.isActive,
                  activeColor: kJadMain,
                  activeTrackColor: kJadTeal.withOpacity(0.4),
                  onChanged: (val) {
                    setState(() {
                      day.isActive = val;
                    });
                  },
                ),
              ],
            ),
            if (day.isActive) ...[
              if (day.slots.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: kJadLGreen.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.all_inclusive_rounded,
                          size: 13,
                          color: Color(0xFF2E7D32),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Available 24/7',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ...day.slots.asMap().entries.map((e) {
                final i = e.key;
                final slot = e.value;

                return Container(
                  margin: const EdgeInsets.only(top: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: kJadScaffold,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: kJadTeal.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: kJadMain,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          slot.label,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _editSlot(index, i),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: kJadTeal.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.edit_outlined,
                            size: 14,
                            color: kJadMain,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _deleteSlot(index, i),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            size: 14,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _showAddSlotPicker(index),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: kJadTeal.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: kJadTeal.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add_rounded,
                        size: 16,
                        color: kJadMain,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Add Time Slot',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: kJadMain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 4),
              Text(
                'Unavailable',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kJadLGreen.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: kJadLGreen,
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: kJadLGreen.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              size: 16,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scheduling Tips',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '• Toggle a day ON without adding slots → available 24/7 that day\n'
                  '• Add specific slots to control when users can book\n'
                  '• Changing session duration clears existing slots',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: isSaving ? null : _handleSave,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSaving
                ? [Colors.grey.shade300, Colors.grey.shade300]
                : [kJadBlue, kJadMain],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSaving
              ? []
              : [
                  BoxShadow(
                    color: kJadMain.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: isSaving
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Saving...',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : Text(
                'Save Schedule',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final List<Map<String, dynamic>> items = [
      {
        'label': 'Home',
        'icon': 'assets/images/home.png',
        'fallback': Icons.home_outlined,
      },
      {
        'label': 'Articles',
        'icon': 'assets/images/article.png',
        'fallback': Icons.article_outlined,
      },
      {
        'label': 'Consultations',
        'icon': 'assets/images/consultation.png',
        'fallback': Icons.chat_bubble_outline,
      },
      {
        'label': 'Account',
        'icon': 'assets/images/user.png',
        'fallback': Icons.person_outline,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final bool isSel = navIndex == index;

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onNavTapped(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        items[index]['icon'] as String,
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
                        color: isSel ? kJadMain : Colors.grey.shade400,
                        errorBuilder: (_, __, ___) => Icon(
                          items[index]['fallback'] as IconData,
                          color: isSel ? kJadMain : Colors.grey.shade400,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[index]['label'] as String,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                          color: isSel ? kJadMain : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
