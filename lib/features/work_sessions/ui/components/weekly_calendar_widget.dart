import 'package:flutter/material.dart';
import '../../utils/calendar_utils.dart';

/// A horizontal & vertical scrolling weekly calendar grid with sticky headers.
class WeeklyCalendarWidget extends StatefulWidget {
  final List<dynamic> sessions;
  final DateTime referenceDate;

  const WeeklyCalendarWidget({
    super.key,
    required this.sessions,
    required this.referenceDate,
  });

  @override
  State<WeeklyCalendarWidget> createState() => _WeeklyCalendarWidgetState();
}

class _WeeklyCalendarWidgetState extends State<WeeklyCalendarWidget> {
  static const double _hourHeight = 60.0;
  static const double _timeColumnWidth = 50.0;
  static const double _dayColumnWidth = 100.0;

  late final ScrollController _daysScrollController;
  late final ScrollController _gridHorizontalController;

  @override
  void initState() {
    super.initState();
    _daysScrollController = ScrollController();
    _gridHorizontalController = ScrollController();

    // SRP: Sincronização lógica dos cabeçalhos horizontais (Dias)
    _gridHorizontalController.addListener(() {
      if (_daysScrollController.hasClients && _gridHorizontalController.hasClients) {
        _daysScrollController.jumpTo(_gridHorizontalController.offset);
      }
    });
  }

  @override
  void dispose() {
    _daysScrollController.dispose();
    _gridHorizontalController.dispose();
    super.dispose();
  }

  DateTime _getStartOfWeek(DateTime date) {
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: date.weekday - 1));
  }

  /// SRP: Helper function para calcular a duração exata e legível de qualquer intervalo de tempo
  String _formatDiff(DateTime start, DateTime end) {
    final diff = end.difference(start);
    final hours = diff.inHours;
    final minutes = diff.inMinutes.remainder(60);
    if (hours > 0) return '${hours}h ${minutes}m';
    if (minutes > 0) return '${minutes}m';
    return '< 1m';
  }

  @override
  Widget build(BuildContext context) {
    final startOfWeek = _getStartOfWeek(widget.referenceDate);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // 1. STICKY TOP HEADER: Dias da Semana
        Row(
          children: [
            const SizedBox(width: _timeColumnWidth), // Canto vazio sobre as horas
            Expanded(
              child: SingleChildScrollView(
                controller: _daysScrollController,
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(), // Controlado pelo Scroll da grelha
                child: Row(
                  children: List.generate(7, (dayIndex) {
                    final currentDate = startOfWeek.add(Duration(days: dayIndex));
                    return Container(
                      width: _dayColumnWidth,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        border: Border(
                          bottom: BorderSide(color: colorScheme.outlineVariant),
                          right: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                        ),
                      ),
                      child: Text(
                        '${currentDate.day}/${currentDate.month}',
                        style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
        
        // 2. SCROLLABLE BODY
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // STICKY LEFT COLUMN: Horas
                SizedBox(
                  width: _timeColumnWidth,
                  child: Column(
                    children: List.generate(25, (index) {
                      return SizedBox(
                        height: _hourHeight,
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              '${index.toString().padLeft(2, '0')}:00',
                              style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                
                // MAIN GRID: Grelha com deslize horizontal
                Expanded(
                  child: SingleChildScrollView(
                    controller: _gridHorizontalController,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      height: 24 * _hourHeight,
                      child: Row(
                        children: List.generate(7, (dayIndex) {
                          final currentDate = startOfWeek.add(Duration(days: dayIndex));
                          return _buildDayColumn(currentDate, colorScheme);
                        }),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Constrói a coluna de 24h para um dia e desenha a cronologia exata 
  /// intercalando trabalho efetivo com as pausas.
  Widget _buildDayColumn(DateTime currentDate, ColorScheme colorScheme) {
    final List<dynamic> daySessions = widget.sessions.where((s) {
      if (s['started_at'] == null || s['date'] == null) return false;
      final sessionDate = DateTime.parse(s['date'] as String);
      return sessionDate.year == currentDate.year && 
             sessionDate.month == currentDate.month && 
             sessionDate.day == currentDate.day;
    }).toList();

    return Container(
      width: _dayColumnWidth,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
        ),
      ),
      child: Stack(
        children: [
          // Background hour dividers
          ...List.generate(24, (index) => Positioned(
            top: index * _hourHeight,
            left: 0,
            right: 0,
            child: Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.2)),
          )),
          
          // Draw Chronological Blocks (Work -> Pause -> Work)
          ...daySessions.expand((session) {
            final List<Widget> blocks = [];
            final timeParts = (session['started_at'] as String).split(':');
            final startDt = DateTime(currentDate.year, currentDate.month, currentDate.day, int.parse(timeParts[0]), int.parse(timeParts[1]));
            
            DateTime endDt;
            if (session['ended_at'] != null) {
              final endParts = (session['ended_at'] as String).split(':');
              endDt = DateTime(currentDate.year, currentDate.month, currentDate.day, int.parse(endParts[0]), int.parse(endParts[1]));
            } else {
              endDt = DateTime.now(); // Turno ainda a decorrer
            }

            final bool isCompleted = session['status'] == 'completed';
            DateTime currentWorkStart = startDt;

            if (session['pauses'] != null) {
              final pauses = List<dynamic>.from(session['pauses']);
              
              // Garante que as pausas são processadas pela ordem correta do tempo
              pauses.sort((a, b) {
                final aTime = (a['started_at'] as String).split(':');
                final bTime = (b['started_at'] as String).split(':');
                final aDt = DateTime(currentDate.year, currentDate.month, currentDate.day, int.parse(aTime[0]), int.parse(aTime[1]));
                final bDt = DateTime(currentDate.year, currentDate.month, currentDate.day, int.parse(bTime[0]), int.parse(bTime[1]));
                return aDt.compareTo(bDt);
              });

              for (var pause in pauses) {
                final pStartParts = (pause['started_at'] as String).split(':');
                final pStartDt = DateTime(currentDate.year, currentDate.month, currentDate.day, int.parse(pStartParts[0]), int.parse(pStartParts[1]));
                
                DateTime pEndDt;
                if (pause['ended_at'] != null) {
                  final pEndParts = (pause['ended_at'] as String).split(':');
                  pEndDt = DateTime(currentDate.year, currentDate.month, currentDate.day, int.parse(pEndParts[0]), int.parse(pEndParts[1]));
                } else {
                  pEndDt = DateTime.now(); // Pausa encontra-se a decorrer neste momento
                }

                // 1. Desenha o Bloco de Trabalho ANTES desta pausa (se existir tempo útil)
                if (currentWorkStart.isBefore(pStartDt)) {
                  blocks.add(
                    Positioned(
                      top: CalendarUtils.calculateTopOffset(currentWorkStart, _hourHeight),
                      left: 2, right: 2,
                      height: CalendarUtils.calculateSessionHeight(currentWorkStart, pStartDt, _hourHeight),
                      child: _WorkBlock(
                        isCompleted: isCompleted,
                        durationText: _formatDiff(currentWorkStart, pStartDt),
                      ),
                    )
                  );
                }

                // 2. Desenha o Bloco da Pausa (separado e não sobreposto)
                blocks.add(
                  Positioned(
                    top: CalendarUtils.calculateTopOffset(pStartDt, _hourHeight),
                    left: 2, right: 2,
                    height: CalendarUtils.calculateSessionHeight(pStartDt, pEndDt, _hourHeight),
                    child: _PauseBlock(durationText: _formatDiff(pStartDt, pEndDt)),
                  )
                );

                // O próximo bloco de trabalho só poderá começar após o fim desta pausa
                currentWorkStart = pEndDt;
              }
            }

            // 3. Desenha o último Bloco de Trabalho após a última pausa (ou o bloco inteiro se não houve pausas)
            // Se o turno estiver atualmente em pausa, currentWorkStart e endDt são iguais (DateTime.now()), logo é ignorado.
            if (currentWorkStart.isBefore(endDt)) {
              blocks.add(
                Positioned(
                  top: CalendarUtils.calculateTopOffset(currentWorkStart, _hourHeight),
                  left: 2, right: 2,
                  height: CalendarUtils.calculateSessionHeight(currentWorkStart, endDt, _hourHeight),
                  child: _WorkBlock(
                    isCompleted: isCompleted,
                    durationText: _formatDiff(currentWorkStart, endDt),
                  ),
                )
              );
            }

            return blocks;
          }),
        ],
      ),
    );
  }
}

/// Extracted Component for the main Work Session fragments
class _WorkBlock extends StatelessWidget {
  final bool isCompleted;
  final String durationText;
  
  const _WorkBlock({required this.isCompleted, required this.durationText});

  @override
  Widget build(BuildContext context) {
    Color bgColor = isCompleted ? Colors.green.shade100.withValues(alpha: 0.9) : Colors.blue.shade100.withValues(alpha: 0.9);
    Color borderColor = isCompleted ? Colors.green.shade400 : Colors.blue.shade400;
    Color textColor = isCompleted ? Colors.green.shade900 : Colors.blue.shade900;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Text(
        durationText,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Extracted Component for Pause Fragments
class _PauseBlock extends StatelessWidget {
  final String durationText;
  
  const _PauseBlock({required this.durationText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.orange.shade100.withValues(alpha: 0.95), // Tom laranja claro distinto
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.orange.shade400, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.coffee, size: 10, color: Colors.deepOrange),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              durationText,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange.shade900),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}