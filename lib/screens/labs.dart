import 'package:material_ui/material_ui.dart';

import '../data.dart';
import '../nav.dart';
import '../theme.dart';

const _labs = [
  ('chits', 'Time-chit bank', 'note = hour?'),
  ('doubling', 'Productivity', 'n → n/2'),
  ('circulation', 'Circulation time', '52 / (P+C)'),
  ('machines', 'Machines', 'free time'),
];

class LabsScreen extends StatelessWidget {
  const LabsScreen({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<String>(
        valueListenable: AppNav.lab,
        builder: (context, requested, _) {
          final active = _labs.any((l) => l.$1 == requested) ? requested : 'chits';
          return ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              const PageIntro(
                eyebrow: 'Interactive labs',
                plain: 'Put the categories\n',
                emphasis: 'in motion.',
                body: 'Four arguments from the notebooks, turned into deliberately simple models. Change one relation at a time, inspect the result, and read the assumption note before applying a category to reality.',
                trailing: _Note('Models clarify mechanisms; they do not replace evidence.', icon: Icons.warning_amber),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: pagePadding,
                child: Row(
                  children: [
                    for (var i = 0; i < _labs.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Semantics(
                          button: true,
                          selected: active == _labs[i].$1,
                          child: Material(
                            color: active == _labs[i].$1 ? C.ink : Colors.transparent,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: active == _labs[i].$1 ? C.ink : C.lineSoft),
                            ),
                            child: InkWell(
                              onTap: () => AppNav.lab.value = _labs[i].$1,
                              child: Container(
                                width: 150,
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('0${i + 1}', style: mono(10, color: active == _labs[i].$1 ? C.accentSoft : C.coral, medium: true)),
                                    const SizedBox(height: 6),
                                    Text(_labs[i].$2, style: display(15, weight: 600, height: 1.2, color: active == _labs[i].$1 ? C.paper : C.ink)),
                                    const SizedBox(height: 4),
                                    Text(_labs[i].$3, style: mono(10.5, color: active == _labs[i].$1 ? C.paperDeep : C.muted)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Divider(color: C.ink),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                child: switch (active) {
                  'doubling' => const _DoublingLab(),
                  'circulation' => const _CirculationLab(),
                  'machines' => const _MachinesLab(),
                  _ => const _ChitsLab(),
                },
              ),
            ],
          );
        },
      );
}

class _Note extends StatelessWidget {
  const _Note(this.text, {this.icon = Icons.balance});
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.only(top: 2), child: Icon(icon, size: 17, color: C.muted)),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: display(13, weight: 470, color: C.muted, height: 1.45))),
        ],
      );
}

class _LabHead extends StatelessWidget {
  const _LabHead(this.eyebrow, this.title, this.body);
  final String eyebrow;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(eyebrow),
          Text(title, style: display(29, height: 1.08)),
          const SizedBox(height: 10),
          Text(body, style: reading(16.5, color: C.muted, height: 1.55)),
          const SizedBox(height: 20),
        ],
      );
}

class _SliderField extends StatelessWidget {
  const _SliderField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.step = 1,
    this.unit = '',
  });
  final String label;
  final int value;
  final int min;
  final int max;
  final int step;
  final String unit;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final divisions = ((max - min) / step).round();
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: display(14, weight: 540, height: 1.3))),
              Text('${grouped(value)}$unit', style: mono(14, medium: true)),
            ],
          ),
          Semantics(
            label: label,
            value: '${grouped(value)}$unit',
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                tickMarkShape: SliderTickMarkShape.noTickMark,
              ),
              child: Slider(
                value: value.clamp(min, max).toDouble(),
                min: min.toDouble(),
                max: max.toDouble(),
                divisions: divisions < 1 ? null : divisions,
                padding: const EdgeInsets.symmetric(vertical: 4),
                onChanged: max > min ? (v) => onChanged(v.round()) : null,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${grouped(min)}$unit', style: mono(10, color: C.muted)),
              Text('${grouped(max)}$unit', style: mono(10, color: C.muted)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metrics extends StatelessWidget {
  const _Metrics(this.items);
  final List<(String, String)> items;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(border: Border.all(color: C.lineSoft)),
        child: Column(
          children: [
            for (var row = 0; row < items.length; row += 2)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = row; i < row + 2 && i < items.length; i++)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            border: Border(
                              right: i.isEven ? const BorderSide(color: C.lineSoft) : BorderSide.none,
                              top: row > 0 ? const BorderSide(color: C.lineSoft) : BorderSide.none,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(items[i].$1.toUpperCase(), style: mono(9.5, color: C.muted, spacing: 0.5)),
                              const SizedBox(height: 8),
                              Text(items[i].$2, style: display(27, weight: 600, height: 1)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      );
}

class _FormulaLarge extends StatelessWidget {
  const _FormulaLarge(this.formula, this.value, this.caption);
  final String formula;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        color: C.ink,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(formula, style: reading(20, italic: true, color: C.accentSoft, height: 1.2)),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: mono(23, medium: true, color: C.paper, height: 1.2)),
            ),
            const SizedBox(height: 6),
            Text(caption.toUpperCase(), style: mono(9.5, color: C.paperDeep, spacing: 0.7)),
          ],
        ),
      );
}

/// A horizontal bar split into labelled segments, sized by value.
class _SplitBar extends StatelessWidget {
  const _SplitBar(this.segments, {this.semantics, this.height = 56});
  final List<(String, double, Color, Color)> segments;
  final String? semantics;
  final double height;

  @override
  Widget build(BuildContext context) => Semantics(
        label: semantics ?? segments.map((s) => '${s.$1}: ${_h(s.$2)}').join(', '),
        child: ExcludeSemantics(
          child: SizedBox(
            height: height,
            child: Row(
              children: [
                for (final (label, value, bg, fg) in segments)
                  if (value > 0.0001)
                    Expanded(
                      flex: (value * 1000).round().clamp(1, 1 << 30),
                      child: Container(
                        color: bg,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          label,
                          maxLines: 2,
                          overflow: TextOverflow.clip,
                          style: display(11, weight: 600, color: fg, height: 1.15),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
      );
}

String _h(double hours) {
  final rounded = (hours * 10).round() / 10;
  return rounded == rounded.roundToDouble() ? '${rounded.round()} h' : '${rounded.toStringAsFixed(1)} h';
}

String _frac(int k, int n0Pct) {
  // Necessary share as a simple fraction when it is one, else a percentage.
  final denominator = 100 * (1 << k);
  var a = n0Pct, b = denominator;
  int gcd(int x, int y) => y == 0 ? x : gcd(y, x % y);
  final g = gcd(a, b);
  a ~/= g;
  b ~/= g;
  return b <= 128 ? '$a/$b' : '${(n0Pct / (1 << k)).toStringAsFixed(2)}%';
}

Widget _resetButton(VoidCallback onPressed) => TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.refresh, size: 16, color: C.ink),
      label: Text('Reset example', style: display(13, height: 1.2).copyWith(decoration: TextDecoration.underline)),
      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 44)),
    );

// ───────────────────────────── 01 · Time-chit bank ─────────────────────────────

class _ChitsLab extends StatefulWidget {
  const _ChitsLab();

  @override
  State<_ChitsLab> createState() => _ChitsLabState();
}

class _ChitsLabState extends State<_ChitsLab> {
  int embodied = 10, current = 5, stock = 100;

  @override
  Widget build(BuildContext context) {
    final gap = embodied - current;
    final stockGap = gap * stock;
    final tone = gap == 0 ? C.forest : C.error;
    final verdict = gap == 0
        ? 'No change in productivity: an hour-note still buys an hour’s worth of coats. The scheme looks workable—until productivity moves.'
        : gap > 0
            ? 'Coats now take $current h, but the bank promised $embodied notes each. Either it lowers the price—so a note no longer stands for an hour actually worked—or it holds the price and nobody buys the old coats.'
            : 'Coats now take $current h, more than the $embodied h they embodied. Holders of old coats gain a windfall at the bank’s fixed price, or the note must appreciate—again ceasing to mean one hour.';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _LabHead(
          'Lesson 04 · pp. 153–5',
          'Can an hour-note stay an hour?',
          'A people’s bank issues one note per hour of labour and buys coats at the hours they took to make. Then productivity changes. Watch what happens to the promise.',
        ),
        _SliderField(label: 'Hours the stocked coats took', value: embodied, min: 2, max: 20, unit: ' h', onChanged: (x) => setState(() => embodied = x)),
        _SliderField(label: 'Hours a coat takes now', value: current, min: 2, max: 20, unit: ' h', onChanged: (x) => setState(() => current = x)),
        _SliderField(label: 'Coats held by the bank', value: stock, min: 10, max: 500, step: 10, onChanged: (x) => setState(() => stock = x)),
        _resetButton(() => setState(() {
              embodied = 10;
              current = 5;
              stock = 100;
            })),
        const SizedBox(height: 16),
        Text('ONE COAT, MEASURED TWO WAYS', style: mono(10, spacing: 0.6)),
        const SizedBox(height: 8),
        _SplitBar(
          [('Bank price · $embodied notes', embodied.toDouble(), C.ink, C.paper), ('', (20 - embodied).toDouble(), C.paperDeep, C.ink)],
          height: 40,
          semantics: 'Bank price $embodied notes',
        ),
        const SizedBox(height: 6),
        _SplitBar(
          [('Value now · $current h', current.toDouble(), C.coral, C.ink), ('', (20 - current).toDouble(), C.paperDeep, C.ink)],
          height: 40,
          semantics: 'Value now $current hours',
        ),
        const SizedBox(height: 16),
        _FormulaLarge(
          'value = labour time necessary now',
          '1 coat = $current h, not $embodied h',
          'past hours count only as present necessary hours',
        ),
        const SizedBox(height: 16),
        _Metrics([
          ('Bank price per coat', '$embodied notes'),
          ('Value per coat now', '$current h'),
          ('Gap per coat', gap == 0 ? '0' : '${gap > 0 ? '+' : '−'}${gap.abs()} h'),
          (stockGap >= 0 ? 'Bank exposure on stock' : 'Windfall to holders', '${grouped(stockGap.abs())} notes'),
        ]),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: C.raised, border: Border(left: BorderSide(color: tone, width: 3))),
          child: Semantics(liveRegion: true, child: Text(verdict, style: reading(16, height: 1.5))),
        ),
        const SizedBox(height: 16),
        const _Note('Marx’s conclusion: to keep notes equal to hours the bank would have to buy and sell everything at fixed rates—becoming the despotic manager of production—or let notes float, which is money again.'),
      ],
    );
  }
}

// ───────────────────────── 02 · Productivity arithmetic ─────────────────────────

class _DoublingLab extends StatefulWidget {
  const _DoublingLab();

  @override
  State<_DoublingLab> createState() => _DoublingLabState();
}

class _DoublingLabState extends State<_DoublingLab> {
  int day = 12, necessaryPct = 50, doublings = 3;

  @override
  Widget build(BuildContext context) {
    final rows = [
      for (var k = 0; k <= doublings; k++) (k, necessaryPct / 100 / (1 << k)),
    ];
    final n = rows.last.$2;
    final surplusShare = 1 - n;
    final lastGain = doublings == 0 ? 0.0 : (1 - rows.last.$2) - (1 - rows[rows.length - 2].$2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _LabHead(
          'Lesson 11 · pp. 333–41',
          'Double productivity, again and again.',
          'Each doubling halves the necessary part of the working day. Watch how much surplus labour each doubling actually adds.',
        ),
        _SliderField(label: 'Working day', value: day, min: 6, max: 14, unit: ' h', onChanged: (x) => setState(() => day = x)),
        _SliderField(label: 'Necessary labour at start', value: necessaryPct, min: 10, max: 90, step: 5, unit: '%', onChanged: (x) => setState(() => necessaryPct = x)),
        _SliderField(label: 'Productivity doublings', value: doublings, min: 0, max: 6, onChanged: (x) => setState(() => doublings = x)),
        _resetButton(() => setState(() {
              day = 12;
              necessaryPct = 50;
              doublings = 3;
            })),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Text('WORKING DAY AFTER $doublings DOUBLING${doublings == 1 ? '' : 'S'}', style: mono(10, spacing: 0.6))),
            Text('${_h(day * surplusShare).toUpperCase()} SURPLUS', style: mono(10, color: C.coral, medium: true, spacing: 0.6)),
          ],
        ),
        const SizedBox(height: 8),
        _SplitBar([
          ('Necessary', day * n, C.forest, C.paper),
          ('Surplus', day * surplusShare, C.coral, C.ink),
        ]),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(border: Border.all(color: C.lineSoft)),
          child: Column(
            children: [
              _row(['STEP', 'NECESSARY', 'SURPLUS', 'ADDED'], header: true),
              for (final (k, share) in rows)
                _row([
                  k == 0 ? 'start' : '×${1 << k}',
                  _frac(k, necessaryPct),
                  _h(day * (1 - share)),
                  k == 0 ? '—' : '+${_h(day * (rows[k - 1].$2 - share))}',
                ], highlight: k == doublings),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _Metrics([
          ('Necessary labour', _h(day * n)),
          ('Surplus labour', _h(day * surplusShare)),
          ('Last doubling added', doublings == 0 ? '—' : _h(day * lastGain)),
          ('Rate of surplus value', '${grouped(surplusShare / n * 100)}%'),
        ]),
        const SizedBox(height: 16),
        const _Note('Each doubling adds half as much surplus labour as the one before, because it halves an ever smaller necessary part. The rate s/n soars while the absolute gain shrinks: the larger the surplus already, the less a new rise in productivity can add.'),
      ],
    );
  }

  Widget _row(List<String> cells, {bool header = false, bool highlight = false}) => Container(
        color: highlight ? C.accentSoft.withValues(alpha: 0.45) : (header ? C.paperDeep : null),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            for (var i = 0; i < cells.length; i++)
              Expanded(
                flex: i == 0 ? 2 : 3,
                child: Text(
                  cells[i],
                  textAlign: i == 0 ? TextAlign.start : TextAlign.end,
                  style: mono(header ? 9.5 : 12, color: header ? C.muted : C.ink, medium: !header && i == 3, spacing: header ? 0.6 : 0),
                ),
              ),
          ],
        ),
      );
}

// ─────────────────────────── 03 · Circulation time ───────────────────────────

class _CirculationLab extends StatefulWidget {
  const _CirculationLab();

  @override
  State<_CirculationLab> createState() => _CirculationLabState();
}

class _CirculationLabState extends State<_CirculationLab> {
  int capital = 1000, production = 4, circulation = 8, rate = 25;

  @override
  Widget build(BuildContext context) {
    final turnover = production + circulation;
    final turnovers = 52 / turnover;
    final perTurnover = capital * rate / 100;
    final annual = perTurnover * turnovers;
    final ideal = perTurnover * 52 / production;
    final lost = circulation / turnover * 100;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _LabHead(
          'Lesson 16 · pp. 516–48, 650–68',
          'Circulation time as devaluation.',
          'Capital creates surplus value only while it is in production. Lengthen or shorten circulation and watch the annual surplus change.',
        ),
        _SliderField(label: 'Capital advanced', value: capital, min: 100, max: 5000, step: 100, onChanged: (x) => setState(() => capital = x)),
        _SliderField(label: 'Surplus value per production period', value: rate, min: 5, max: 100, step: 5, unit: '%', onChanged: (x) => setState(() => rate = x)),
        _SliderField(label: 'Production time', value: production, min: 1, max: 26, unit: ' wk', onChanged: (x) => setState(() => production = x)),
        _SliderField(label: 'Circulation time', value: circulation, min: 0, max: 26, unit: ' wk', onChanged: (x) => setState(() => circulation = x)),
        _resetButton(() => setState(() {
              capital = 1000;
              production = 4;
              circulation = 8;
              rate = 25;
            })),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Text('ONE TURNOVER · $turnover WEEKS', style: mono(10, spacing: 0.6))),
            Text('${turnovers.toStringAsFixed(1)} PER YEAR', style: mono(10, color: C.coral, medium: true, spacing: 0.6)),
          ],
        ),
        const SizedBox(height: 8),
        _SplitBar(
          [
            ('Production · $production wk', production.toDouble(), C.forest, C.paper),
            ('Circulation · $circulation wk', circulation.toDouble(), C.lineStrong, C.paper),
          ],
          semantics: 'One turnover: $production weeks production, $circulation weeks circulation',
        ),
        const SizedBox(height: 16),
        _FormulaLarge('S = K · s′ · 52 / (P + C)', '${grouped(capital)} · $rate% · 52/$turnover = ${grouped(annual)}', 'annual surplus value'),
        const SizedBox(height: 16),
        _Metrics([
          ('Turnovers per year', turnovers.toStringAsFixed(1)),
          ('Annual rate on capital', '${grouped(annual / capital * 100)}%'),
          ('Without circulation time', grouped(ideal)),
          ('Lost to circulation', '${lost.toStringAsFixed(0)}%'),
        ]),
        const SizedBox(height: 16),
        const _Note('Simplification: the whole capital passes through production and circulation in sequence. Marx notes that continuous production requires splitting capital so part produces while part circulates (p. 548)—which ties up more capital instead of losing time.'),
      ],
    );
  }
}

// ─────────────────────── 04 · Machines & disposable time ───────────────────────

class _MachinesLab extends StatefulWidget {
  const _MachinesLab();

  @override
  State<_MachinesLab> createState() => _MachinesLabState();
}

class _MachinesLabState extends State<_MachinesLab> {
  int day = 8, necessary = 6, productivity = 4, fund = 1;

  @override
  Widget build(BuildContext context) {
    final n = necessary / productivity;
    final surplus = day - n;
    final work = (n + fund).clamp(0, day.toDouble()).toDouble();
    final socialFund = work - n;
    final free = day - work;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _LabHead(
          'Lesson 17 · pp. 690–712',
          'The moving contradiction.',
          'Machinery multiplies output per hour. Capital keeps the working day and turns the saving into surplus labour. Compare that with a day in which the saving becomes disposable time.',
        ),
        _SliderField(label: 'Working day', value: day, min: 4, max: 12, unit: ' h', onChanged: (x) => setState(() {
              day = x;
              if (necessary > x) necessary = x;
            })),
        _SliderField(label: 'Necessary labour before machines', value: necessary.clamp(1, day), min: 1, max: day, unit: ' h', onChanged: (x) => setState(() => necessary = x)),
        _SliderField(label: 'Productivity of labour', value: productivity, min: 1, max: 20, unit: '×', onChanged: (x) => setState(() => productivity = x)),
        _SliderField(label: 'Common fund (investment, care, public needs)', value: fund, min: 0, max: 4, unit: ' h', onChanged: (x) => setState(() => fund = x)),
        _resetButton(() => setState(() {
              day = 8;
              necessary = 6;
              productivity = 4;
              fund = 1;
            })),
        const SizedBox(height: 16),
        Text('UNDER CAPITAL · THE DAY STAYS $day H', style: mono(10, spacing: 0.6)),
        const SizedBox(height: 8),
        _SplitBar([
          ('Necessary', n, C.forest, C.paper),
          ('Surplus labour', surplus, C.coral, C.ink),
        ]),
        const SizedBox(height: 14),
        Text('WITH DISPOSABLE TIME · WORK ${_h(work).toUpperCase()}', style: mono(10, spacing: 0.6)),
        const SizedBox(height: 8),
        _SplitBar([
          ('Necessary', n, C.forest, C.paper),
          ('Fund', socialFund, C.plum, C.paper),
          ('Free time', free, C.accentSoft, C.ink),
        ]),
        const SizedBox(height: 16),
        _FormulaLarge(
          'use value ↑   value →',
          'output ×$productivity · value $day h',
          'material wealth multiplies; value is still counted in hours',
        ),
        const SizedBox(height: 16),
        _Metrics([
          ('Output per working day', '×$productivity'),
          ('New value per day', '$day h'),
          ('Value per unit', '${grouped(100 / productivity)}%'),
          ('Possible free time', '${_h(free)}/day'),
        ]),
        const SizedBox(height: 16),
        const _Note('Teaching model only. It shows the tension Marx names—labour time shrinks as a source of material wealth yet remains the measure of value—not a forecast of how automation will play out.'),
      ],
    );
  }
}
