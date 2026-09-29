/// The Bot Mode avatar: the desktop's "math face", ported.
///
/// Hermes Desktop draws a bot's face as an SVG it repaints every frame from
/// [BotFaceShape] + colour: a 52-point outline ring, two eyes that look
/// around, a blink, and — while the bot works — three dots underneath. This
/// file reproduces that face in Flutter so the Android roster wears the same
/// face the desktop does rather than a flat initial in a coloured box.
///
/// ## What is ported, and why it is not an approximation
///
/// The face is *derived*, not picked: [shapeForName] hashes the profile name
/// and takes a shape, so the same bot has the same silhouette everywhere
/// without persisting anything. [BotFaceShape] geometry, eye placement, catch
/// lights, [BotFacePose] curves, blink cadence and the working dots are all
/// transcribed from `apps/desktop/src/plugins/hermes-bots/avatar.tsx` so the
/// rendering matches frame for frame. Changing a constant here desynchronises
/// the app from the desktop; each one is annotated with its source.
///
/// ## Why the server's PNG is not used
///
/// Every profile on this gateway carries `has_avatar: true`, and
/// `profiles.get_asset` answers with a 160x160 PNG — but the desktop
/// deliberately *refuses to show those on the roster*. They are rasters the
/// desktop itself pushed back for the inter-agent notice pfp
/// (`isBackfilledFacePng`), and a baked PNG cannot animate. Showing one here
/// would freeze the face mid-pose, so [BotAvatarSource] draws the face for a
/// shape avatar and only shows a picture for a real photo
/// (`imageKind: photo` or a size that is not 160x160 backfill).
///
/// ## The clock
///
/// The desktop paints every face from one `requestAnimationFrame` loop and
/// samples `performance.now()`. [BotFaceClock] is the Flutter equivalent: a
/// single [Ticker] shared by every mounted face. A face computes its pose
/// from the clock's elapsed time on every tick, so a rebuild mid-frame is a
/// phase correction rather than a reset — a `setState` elsewhere on the
/// screen must not restart the sway from zero, which is the bug that makes a
/// "live" face visibly stutter.
library;

import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;

/// One face silhouette, as Hermes Bot Mode spells it on the wire.
///
/// The desktop accepts more values than it offers in its picker (platonic
/// solids, sigils, blobatar families), so an unknown value is a real state
/// rather than an error: [BotFaceShape] resolves it to [circle], matching the
/// desktop's own fallback.
enum BotFaceShape {
  /// Plain disc.
  circle,

  /// Rounded square (a "squircle": superellipse exponent 5).
  squircle,

  /// Horizontal capsule (superellipse exponent 8, squashed 0.72).
  pill,

  /// Equilateral triangle pointing up.
  triangle,

  /// Regular hexagon, flat-top.
  hexagon,

  /// Three puffs and a flat floor — the GitHub cloud silhouette.
  cloud,

  /// Fat water drop: pointed top, round bottom.
  drop,

  /// Soft body: a circle perturbed by two low harmonics.
  blob;

  /// Parses the wire value. Unknown or empty resolves to [circle].
  static BotFaceShape parse(String? value) {
    switch (value) {
      case 'squircle':
        return BotFaceShape.squircle;
      case 'pill':
        return BotFaceShape.pill;
      case 'triangle':
        return BotFaceShape.triangle;
      case 'hexagon':
        return BotFaceShape.hexagon;
      case 'cloud':
        return BotFaceShape.cloud;
      case 'drop':
      case 'teardrop':
        return BotFaceShape.drop;
      case 'blob':
        return BotFaceShape.blob;
      case 'circle':
      default:
        return BotFaceShape.circle;
    }
  }
}

/// Which avatar to draw: a live face, or a stored picture.
///
/// The two are not interchangeable — see the library docs for why the server
/// PNG behind a shape avatar must not be drawn.
enum BotAvatarKind {
  /// Draw the derivable face from shape + colour.
  face,

  /// Show a picture (an uploaded or AI-generated portrait).
  photo,

  /// A pixel pet rides beside the face. Not drawn here yet: the spritesheet is
  /// a 1536x1872 webp the desktop fetches and crops; the roster shows the face
  /// first and the companion is a follow-up.
  pet,
}

/// Resolves what a roster row actually shows.
///
/// Mirrors the desktop's `BotRow`: a real picture wins, a 160x160 backfill
/// raster of the vector face is ignored, and anything else is the drawn face.
class BotAvatarSource {
  /// The silhouette to draw, already resolved from the profile name when the
  /// profile does not pin one.
  final BotFaceShape shape;

  /// The body colour. Falls back to the deterministic hue for [profileName],
  /// exactly like the desktop, so an unpinned bot is not grey.
  final Color color;

  /// Which avatar this is.
  final BotAvatarKind kind;

  /// The picture to show when [kind] is [BotAvatarKind.photo].
  final Uint8List? image;

  const BotAvatarSource({
    required this.shape,
    required this.color,
    this.kind = BotAvatarKind.face,
    this.image,
  });

  /// Builds the source for one bot.
  ///
  /// [imageBytes] is what `profiles.get_asset` returned, if anything. It is
  /// honoured only when the profile is not a shape avatar — see [kind]'s note
  /// about backfilled rasters.
  factory BotAvatarSource.resolve({
    required String profileName,
    String? shape,
    String? colorHex,
    String? imageKind,
    bool hasAvatar = false,
    Uint8List? imageBytes,
  }) {
    final bytes = imageBytes;
    // A stored picture is only a picture when the profile says so, or when the
    // bytes are clearly not the server's backfill raster of the vector face
    // (which the desktop also refuses to render, and for the same reason: a
    // baked PNG cannot animate).
    final isPhoto = imageKind == 'photo' ||
        (bytes != null &&
            bytes.length > 2 &&
            !_isBackfillRaster(bytes));
    return BotAvatarSource(
      // `parse` takes String? and resolves null/unknown to circle, and
      // `shapeForName` is the desktop's deterministic hue-mod shape. Both are
      // tried explicitly — writing `parse(shape ?? shapeForName(...))` merges
      // a String? and a BotFaceShape into Object, which analyze rejects.
      shape: shape != null && shape.isNotEmpty
          ? BotFaceShape.parse(shape)
          : shapeForName(profileName),
      color: colorFor(profileName, colorHex),
      kind: isPhoto ? BotAvatarKind.photo : BotAvatarKind.face,
      image: isPhoto ? bytes : null,
    );
  }

  /// Whether [bytes] is the 160x160 PNG the desktop rasterizes from the SVG
  /// face and pushes back for inter-agent notices.
  ///
  /// Read from the PNG IHDR the same way `isBackfilledFacePng` reads the data
  /// URL: width 160 and height 160, and nothing larger, is the signature.
  /// A real portrait comes off a phone camera at 256 or bigger, so the size
  /// alone separates the two.
  static bool _isBackfillRaster(Uint8List bytes) {
    const pngMagic = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
    if (bytes.length < 24) return false;
    for (var i = 0; i < pngMagic.length; i++) {
      if (bytes[i] != pngMagic[i]) return false;
    }
    // IHDR width/height are big-endian at bytes 16..24, after the 8-byte
    // signature and the 4-byte length + 4-byte 'IHDR' type.
    final width = (bytes[16] << 24) |
        (bytes[17] << 16) |
        (bytes[18] << 8) |
        bytes[19];
    final height = (bytes[20] << 24) |
        (bytes[21] << 16) |
        (bytes[22] << 8) |
        bytes[23];
    return width == 160 && height == 160;
  }
}

/// The friendly violet the primary profile has always worn, and the last
/// resort for a bot whose name derives nothing.
const Color kPrimaryAvatarColor = Color(0xFF8B5CF6);

/// The desktop's deterministic hue: `hash(name) % 360` at 68% sat / 58% light.
///
/// Same algorithm, same constants — a bot's fallback colour therefore matches
/// the desktop's instead of being a locally invented one.
Color colorFor(String profileName, String? colorHex) {
  if (colorHex != null && colorHex.isNotEmpty) {
    final parsed = parseHexColor(colorHex);
    if (parsed != null) return parsed;
  }
  return _hsl(hashString(profileName) % 360, 0.68, 0.58);
}

/// The desktop's `hashString`: `(hash * 31 + char) >>> 0`.
int hashString(String value) {
  var hash = 0;
  for (final codeUnit in value.codeUnits) {
    hash = (hash * 31 + codeUnit) & 0xFFFFFFFF;
  }
  return hash;
}

/// The desktop's `defaultShapeFor`: hash, modulo the picker's shape list.
///
/// The picker order is the LICENSE: `['circle', 'blob', 'squircle', 'pill',
/// 'triangle', 'hexagon', 'cloud', 'drop']` — note `blob` is second, which is
/// easy to get wrong by reading the wire values instead.
BotFaceShape shapeForName(String profileName) {
  const shapes = [
    BotFaceShape.circle,
    BotFaceShape.blob,
    BotFaceShape.squircle,
    BotFaceShape.pill,
    BotFaceShape.triangle,
    BotFaceShape.hexagon,
    BotFaceShape.cloud,
    BotFaceShape.drop,
  ];
  final index = hashString(profileName) % shapes.length;
  return shapes[index];
}

/// Parses `#rrggbb` (with or without the leading `#`), or returns null.
Color? parseHexColor(String? hex) {
  final raw = hex?.replaceFirst('#', '').trim() ?? '';
  if (raw.length != 6) return null;
  final value = int.tryParse(raw, radix: 16);
  return value == null ? null : Color(0xFF000000 | value);
}

/// HSL → RGB, for the deterministic-hue fallback.
Color _hsl(int hueDegrees, double saturation, double lightness) {
  final h = (hueDegrees % 360) / 360.0;
  final s = saturation.clamp(0.0, 1.0);
  final l = lightness.clamp(0.0, 1.0);
  final chroma = (1 - (2 * l - 1).abs()) * s;
  final x = chroma * (1 - ((h * 6) % 2 - 1).abs());
  final m = l - chroma / 2;
  double r, g, b;
  final sector = (h * 6).floor() % 6;
  switch (sector) {
    case 0:
      r = chroma;
      g = x;
      b = 0.0;
    case 1:
      r = x;
      g = chroma;
      b = 0.0;
    case 2:
      r = 0.0;
      g = chroma;
      b = x;
    case 3:
      r = 0.0;
      g = x;
      b = chroma;
    case 4:
      r = x;
      g = 0.0;
      b = chroma;
    default:
      r = chroma;
      g = 0.0;
      b = x;
  }
  return Color.fromRGBO(
    ((r + m) * 255).round().clamp(0, 255),
    ((g + m) * 255).round().clamp(0, 255),
    ((b + m) * 255).round().clamp(0, 255),
    1.0,
  );
}

/// One frame of a face: head orientation, gaze, blink, and the working dots.
class BotFacePose {
  /// Pseudo-3D rotation in degrees — drives the horizontal scale of the body.
  final double turn;

  /// Lean in degrees — applied as a real rotation about the face's centre.
  final double tilt;

  /// Roll in degrees — applied before the turn/tilt projection.
  final double roll;

  /// Eye offset in face units.
  final double gazeX;
  final double gazeY;

  /// Whether the eyes are shut this frame.
  final bool blink;

  /// Opacities of the three working dots.
  final double d0;
  final double d1;
  final double d2;

  const BotFacePose({
    this.turn = 0,
    this.tilt = 0,
    this.roll = 0,
    this.gazeX = 0,
    this.gazeY = 0,
    this.blink = false,
    this.d0 = 0,
    this.d1 = 0,
    this.d2 = 0,
  });

  /// Blends two poses, for the 0.4 s ease the desktop applies when a bot's
  /// mood changes. A bare `work` → `idle` swap would snap; this is why.
  BotFacePose lerp(BotFacePose to, double t) {
    final k = t.clamp(0.0, 1.0);
    double mix(double a, double b) => a + (b - a) * k;
    return BotFacePose(
      turn: mix(turn, to.turn),
      tilt: mix(tilt, to.tilt),
      roll: mix(roll, to.roll),
      gazeX: mix(gazeX, to.gazeX),
      gazeY: mix(gazeY, to.gazeY),
      blink: k < 0.5 ? blink : to.blink,
      d0: mix(d0, to.d0),
      d1: mix(d1, to.d1),
      d2: mix(d2, to.d2),
    );
  }

  /// The pose at time [t] seconds for [mood].
  ///
  /// Transcribed from `facePose` in the desktop's avatar.tsx. The numbers are
  /// the animation, not decoration: `sin(t * 0.48) * 8` IS the sway speed.
  static BotFacePose at(BotFaceMood mood, double t) {
    switch (mood) {
      case BotFaceMood.work:
        return BotFacePose(
          turn: -11 + math.sin(t * 0.48) * 8,
          tilt: math.sin(t * 0.42) * 8 + math.sin(t * 1.1) * 1.6,
          roll: math.sin(t * 0.75) * 4.2,
          gazeX: math.sin(t * 0.55) * 3.6,
          gazeY: -1.6 + math.sin(t * 0.38) * 2,
          blink: (t % 1.45) > 1.26,
          d0: 0.2 + 0.8 * math.max(0, math.sin(t * 2.6)),
          d1: 0.2 + 0.8 * math.max(0, math.sin(t * 2.6 - 0.7)),
          d2: 0.2 + 0.8 * math.max(0, math.sin(t * 2.6 - 1.4)),
        );
      case BotFaceMood.think:
        return BotFacePose(
          turn: -18 + math.sin(t * 0.55) * 14,
          tilt: math.sin(t * 0.48) * 12 + math.sin(t * 1.35) * 3,
          roll: math.sin(t * 0.95) * 10,
          gazeX: math.sin(t * 0.7) * 3.6,
          gazeY: -2.2 + math.sin(t * 0.4) * 2.2,
          blink: (t % 1.45) > 1.26,
          d0: 0.2 + 0.8 * math.max(0, math.sin(t * 2.4)),
          d1: 0.2 + 0.8 * math.max(0, math.sin(t * 2.4 - 0.7)),
          d2: 0.2 + 0.8 * math.max(0, math.sin(t * 2.4 - 1.4)),
        );
      case BotFaceMood.idle:
        return BotFacePose(
          turn: math.sin(t * 0.5) * 1.5,
          tilt: math.sin(t * 0.27),
          roll: math.sin(t * 0.85) * 1.2,
        );
    }
  }
}

/// Whether a bot is doing something right now.
enum BotFaceMood {
  /// Idle: a small sway, occasional blink.
  idle,

  /// Thinking/working: leans, looks up, three dots pulse beneath.
  work,

  /// Deeper think pose (leaned further). Same dots, faster.
  think,
}

/// One point of a face outline, in the desktop's 40x40 coordinate box.
///
/// A class rather than a record: this is allocated 52+ times per shape per
/// repaint, and named accessors keep the transcription readable where the
/// desktop writes `[x, y]`.
class BotFacePoint {
  final double x;
  final double y;

  const BotFacePoint(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      other is BotFacePoint && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'BotFacePoint($x, $y)';
}

/// The 52-point outline ring of [shape], in the desktop's 40x40 box.
///
/// Transcribed from `sampleFaceRing`. Every branch is a different silhouette,
/// and the constants inside them are the shape — a "rounded rect" drawn here
/// instead of the exponent-5 superellipse reads as a squircle only until you
/// put them side by side.
List<BotFacePoint> faceRing(BotFaceShape shape, {int steps = 52}) {
  final pts = <BotFacePoint>[];
  switch (shape) {
    case BotFaceShape.drop:
      return _dropRing(steps);
    case BotFaceShape.cloud:
      return _cloudRing(steps);
    case BotFaceShape.circle:
    case BotFaceShape.squircle:
    case BotFaceShape.pill:
    case BotFaceShape.triangle:
    case BotFaceShape.hexagon:
    case BotFaceShape.blob:
      for (var i = 0; i < steps; i++) {
        final a = (i / steps) * math.pi * 2 - math.pi / 2;
        final c = math.cos(a);
        final s = math.sin(a);
        var rx = 16.0;
        var ry = 16.0;
        switch (shape) {
          case BotFaceShape.circle:
            rx = ry = 16.2;
          case BotFaceShape.blob:
            rx = ry = 16 + 1.7 * math.sin(3 * a) + 0.7 * math.cos(5 * a);
          case BotFaceShape.squircle:
            // Superellipse exponent 5 — this is what makes a squircle a
            // squircle rather than a rounded square.
            const p = 5.0;
            final d = _superEllipse(_abs(c), _abs(s), p);
            rx = ry = d == 0 ? 16.2 : 16.2 / d;
          case BotFaceShape.pill:
            // Exponent 8, with y squashed to 0.72 so the capsule is wide.
            const p = 8.0;
            final d = _superEllipse(_abs(c), _abs(s / 0.72), p);
            rx = ry = d == 0 ? 16 : 16 / d;
          case BotFaceShape.triangle:
            final u = (a + math.pi / 2 + math.pi * 2) % (math.pi * 2);
            final sector = (u / ((math.pi * 2) / 3)) % 1;
            rx = ry = 13.5 / math.max(0.42, math.cos((sector - 0.5) * 1.9));
          case BotFaceShape.hexagon:
            final seg = math.pi / 3;
            final hex =
                math.cos(seg / 2) / math.cos(a - seg * _jsRound(a / seg));
            rx = ry = 16.2 * hex;
          default:
            rx = ry = 16.2;
        }
        pts.add(BotFacePoint(20 + rx * c, 20 + ry * s));
      }
      return pts;
  }
}

/// `pow(|x|^p + |y|^p, 1/p)` — the superellipse radius the desktop uses.
double _superEllipse(double x, double y, double p) {
  final v = math.pow(x, p) + math.pow(y, p);
  return v == 0 ? 0 : math.pow(v, 1 / p).toDouble();
}

double _abs(double v) => v < 0 ? -v : v;

/// `Math.round` from JavaScript: half toward +Infinity, not away from zero.
///
/// Dart's `round` rounds half away from zero, which differs for negative
/// inputs — and `a / seg` is negative for half the ring, so using Dart's here
/// would put the hexagon's vertices in the wrong sector. `floorToDouble` is
/// the same operation JavaScript's `Math.floor` performs.
double _jsRound(double v) => (v + 0.5).floorToDouble();

/// The water drop: a cubic up the left side, a round bottom, a cubic down.
///
/// Control points transcribed from `sampleDropRing`; the point count per side
/// is `steps ~/ 3`, so raising [steps] refines the curve rather than adding
/// copies of the same vertices.
List<BotFacePoint> _dropRing(int steps) {
  final pts = <BotFacePoint>[];
  final n = math.max(8, steps ~/ 3);

  // Left flank: cubic from (20,3) through (6,20) to (6,27).
  for (var i = 0; i < n; i++) {
    pts.add(_cubicAt(const BotFacePoint(20, 3), const BotFacePoint(20, 3),
      const BotFacePoint(6, 20), const BotFacePoint(6, 27), i / n));
  }
  // Round bottom: an ellipse of half-width 14, half-height 13.5 centred at
  // (20, 27), traversed over the upper half only.
  for (var i = 0; i <= n; i++) {
    final t = (i / n) * math.pi;
    pts.add(BotFacePoint(20 - 14 * math.cos(t), 27 + 13.5 * math.sin(t)));
  }
  // Right flank: the mirror cubic back up to the tip.
  for (var i = 1; i <= n; i++) {
    pts.add(_cubicAt(const BotFacePoint(34, 27), const BotFacePoint(34, 20),
        const BotFacePoint(20, 3), const BotFacePoint(20, 3), i / n));
  }
  return pts;
}

BotFacePoint _cubicAt(
  BotFacePoint p0,
  BotFacePoint p1,
  BotFacePoint p2,
  BotFacePoint p3,
  double t,
) {
  final u = 1 - t;
  final x = u * u * u * p0.x +
      3 * u * u * t * p1.x +
      3 * u * t * t * p2.x +
      t * t * t * p3.x;
  final y = u * u * u * p0.y +
      3 * u * u * t * p1.y +
      3 * u * t * t * p2.y +
      t * t * t * p3.y;
  return BotFacePoint(x, y);
}

/// The GitHub cloud: two elliptical puffs, an arc, and a flat floor.
///
/// `sampleCloudRing` builds these from SVG arc parameters and resamples them
/// by arc *length* so the 52 points stay evenly spaced along a perimeter made
/// of unequal segments. The resampling is not cosmetic: without it the flat
/// floor and the biggest puff get the same number of points as the smallest,
/// and the outline wobbles as the face turns.
List<BotFacePoint> _cloudRing(int steps) {
  final total = math.max(64, steps);

  // The three arcs, in SVG endpoint form → centre/radii/angles.
  final a1 = _svgArc(11, 32, 7.5, 7.5, 0, 1, 10, 17.1);
  final a2 = _svgArc(10, 17.1, 9.5, 9.5, 0, 1, 29, 12.5);
  final a3 = _svgArc(29, 12.5, 7, 7, 0, 1, 30, 32);

  final lengths = <double>[
    _abs(a1.dTheta) * a1.rx,
    _abs(a2.dTheta) * a2.rx,
    _abs(a3.dTheta) * a3.rx,
    19, // the flat floor, measured directly
  ];
  var sum = 0.0;
  for (final l in lengths) {
    sum += l;
  }

  final n1 = math.max(8, (total * lengths[0] / sum).round());
  final n2 = math.max(10, (total * lengths[1] / sum).round());
  final n3 = math.max(10, (total * lengths[2] / sum).round());
  final n4 = math.max(4, total - n1 - n2 - n3);

  final pts = <BotFacePoint>[];
  pts.addAll(_sampleArc(a1, n1));
  pts.addAll(_sampleArc(a2, n2));
  pts.addAll(_sampleArc(a3, n3));
  for (var i = 0; i < n4; i++) {
    pts.add(BotFacePoint(30 + (11 - 30) * (i / n4), 32));
  }
  return pts;
}

class _FaceArc {
  final double cx;
  final double cy;
  final double rx;
  final double ry;
  final double theta1;
  final double dTheta;

  const _FaceArc({
    required this.cx,
    required this.cy,
    required this.rx,
    required this.ry,
    required this.theta1,
    required this.dTheta,
  });
}

/// SVG arc endpoint → centre parameterisation, per the SVG spec.
_FaceArc _svgArc(
  double x1,
  double y1,
  double rx,
  double ry,
  int fa,
  int fs,
  double x2,
  double y2,
) {
  var rxA = rx;
  var ryA = ry;
  final dx = (x1 - x2) / 2;
  final dy = (y1 - y2) / 2;
  var rx2 = rxA * rxA;
  var ry2 = ryA * ryA;
  final lam = (dx * dx) / rx2 + (dy * dy) / ry2;
  if (lam > 1) {
    final s = math.sqrt(lam);
    rxA *= s;
    ryA *= s;
    rx2 = rxA * rxA;
    ry2 = ryA * ryA;
  }
  final num = rx2 * ry2 - rx2 * dy * dy - ry2 * dx * dx;
  final den = rx2 * dy * dy + ry2 * dx * dx;
  var sq = math.sqrt(math.max(0, num / den));
  if (fa == fs) sq = -sq;
  final cx = sq * (rxA * dy / ryA) + (x1 + x2) / 2;
  final cy = sq * (-ryA * dx / rxA) + (x1 + y2) / 2;

  double angle(double ux, double uy, double vx, double vy) {
    final n = math.sqrt(ux * ux + uy * uy) * math.sqrt(vx * vx + vy * vy);
    final dot = ((ux * vx + uy * vy) / (n == 0 ? 1 : n)).clamp(-1.0, 1.0);
    var a = math.acos(dot);
    if (ux * vy - uy * vx < 0) a = -a;
    return a;
  }

  final theta1 = angle(1, 0, (x1 - cx) / rxA, (y1 - cy) / ryA);
  var dTheta = angle(
    (x1 - cx) / rxA,
    (y1 - cy) / ryA,
    (x2 - cx) / rxA,
    (y2 - cy) / ryA,
  );
  if (fs == 0 && dTheta > 0) dTheta -= math.pi * 2;
  if (fs == 1 && dTheta < 0) dTheta += math.pi * 2;

  return _FaceArc(
    cx: cx,
    cy: cy,
    rx: rxA,
    ry: ryA,
    theta1: theta1,
    dTheta: dTheta,
  );
}

List<BotFacePoint> _sampleArc(_FaceArc arc, int n) {
  final pts = <BotFacePoint>[];
  for (var i = 0; i < n; i++) {
    final th = arc.theta1 + arc.dTheta * (i / n);
    pts.add(BotFacePoint(
      arc.cx + arc.rx * math.cos(th),
      arc.cy + arc.ry * math.sin(th),
    ));
  }
  return pts;
}

/// Projects one outline point into the current pose's pseudo-3D frame.
///
/// `projectFacePoint`: rotate about the face centre by [roll], then scale x by
/// how much of the head is turned toward the viewer and y by how far it is
/// tilted up/down. This is the whole illusion — the outline is re-projected
/// every frame, which is why the face cannot be a baked image.
BotFacePoint projectFacePoint(
  BotFacePoint p,
  double turn,
  double tilt,
  double roll,
) {
  final dx = p.x - 20;
  final dy = p.y - 20;
  final r = roll * math.pi / 180;
  final xr = dx * math.cos(r) - dy * math.sin(r);
  final yr = dx * math.sin(r) + dy * math.cos(r);
  final sx = 0.74 + 0.26 * _abs(math.cos(turn * math.pi / 180));
  final sy = 0.8 + 0.2 * _abs(math.cos(tilt * math.pi / 180));
  return BotFacePoint(20 + xr * sx, 20 + yr * sy);
}

/// What the clock needs from a live face.
///
/// Declared as a private interface so the clock can be unit-tested with a
/// stub that needs no widget tree; the render path uses the real
/// `_BotFaceState`, which implements it.
abstract interface class _BotFaceLive {}

/// The one shared clock for every mounted face.
///
/// Reproduces the desktop's single `requestAnimationFrame` loop: one ticker,
/// every face samples the same elapsed time. A per-face ticker would drift
/// apart within seconds, so a roster would show faces swaying out of step —
/// which is what a list of independent animations looks like when it is wrong.
///
/// The clock notifies; it does not build. Each [BotFace] listens and repaints
/// only itself, so one face being added or removed does not rebuild every
/// other face on the screen.
class BotFaceClock extends ChangeNotifier {
  static final BotFaceClock instance = BotFaceClock._();

  BotFaceClock._();

  Ticker? _ticker;
  final _faces = <_BotFaceLive>{};
  Duration _last = Duration.zero;
  double _elapsed = 0;

  /// Seconds since the clock most recently started.
  double get elapsed => _elapsed;

  /// Whether the clock has any face to drive. A paused clock reports the last
  /// elapsed time, so a face rebuilt while nothing else moves paints the pose
  /// it was in rather than snapping back to zero.
  bool get isActive => _faces.isNotEmpty;

  void _add(_BotFaceLive face) {
    if (!_faces.add(face)) return;
    if (_faces.length == 1) _start();
  }

  void _remove(_BotFaceLive face) {
    if (!_faces.remove(face)) return;
    if (_faces.isEmpty) _stop();
  }

  void _start() {
    _last = Duration.zero;
    _elapsed = 0;
    _ticker?.dispose();
    final ticker = _ticker = Ticker(_onTick);
    ticker.start();
  }

  void _stop() {
    _ticker?.dispose();
    _ticker = null;
  }

  void _onTick(Duration now) {
    // The first frame after a start carries no usable delta: `_last` is zero
    // by then, so the delta is zero and the elapsed time does not jump.
    final delta = _last == Duration.zero ? Duration.zero : now - _last;
    _last = now;
    _elapsed += delta.inMicroseconds / 1000000.0;
    notifyListeners();
  }
}

/// A live bot face, or the stored picture the profile actually uses.
///
/// Rendered as a [CustomPaint] driven by [BotFaceClock], so a whole roster
/// shares one ticker and stays in step.
class BotFace extends StatefulWidget {
  /// The face to draw.
  final BotAvatarSource source;

  /// Whether the bot is working, which selects the leaning, dot-pulsing pose.
  final BotFaceMood mood;

  /// Edge length in logical pixels. The desktop draws at 34 in the roster and
  /// 32 in the picker; 40 here because a touch target this small reads as
  /// cramped on a phone, and the geometry scales rather than crops.
  final double size;

  const BotFace({
    required this.source,
    this.mood = BotFaceMood.idle,
    this.size = 40,
    super.key,
  });

  @override
  State<BotFace> createState() => _BotFaceState();
}

class _BotFaceState extends State<BotFace> implements _BotFaceLive {
  BotFaceClock get _clock => BotFaceClock.instance;

  /// The pose currently painted, and the pose it is easing from. The desktop
  /// keeps these in a WeakMap keyed by the SVG element, so a face keeps its
  /// phase across rebuilds instead of restarting.
  BotFacePose _from = const BotFacePose();
  BotFacePose _pose = const BotFacePose();
  double _since = 0;

  @override
  void initState() {
    super.initState();
    _clock._add(this);
    _since = _clock.elapsed - 0.4;
    _pose = BotFacePose.at(widget.mood, _clock.elapsed);
    _from = _pose;
  }

  @override
  void dispose() {
    _clock._remove(this);
    super.dispose();
  }

  @override
  void didUpdateWidget(BotFace oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A mood change starts a 0.4 s ease over, exactly like the desktop's
    // settlePose: the new pose is the target, the old one is where it starts.
    if (oldWidget.mood != widget.mood) {
      _from = _pose;
      _since = _clock.elapsed;
    }
  }

  /// Resolves the pose to paint for the clock's current elapsed time.
  ///
  /// Called from [build], which the clock already triggers — so this is a pure
  /// function of time rather than a second `setState`. Calling setState from
  /// inside the listener would schedule a rebuild the clock has already
  /// caused, and the face would paint a frame late.
  BotFacePose _poseFor(double t) {
    final target = BotFacePose.at(widget.mood, t);
    // Blend over 0.4 s from the previous pose. Without it, a bot that starts
    // working snaps straight into the lean.
    final progress = ((t - _since) / 0.4).clamp(0.0, 1.0);
    final blend = 1 - (1 - progress) * (1 - progress);
    final next = _from.lerp(target, blend);
    _pose = next;
    return next;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _clock,
      builder: (context, _) {
        final pose = _poseFor(_clock.elapsed);
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _BotFacePainter(
              source: widget.source,
              mood: widget.mood,
              pose: pose,
            ),
          ),
        );
      },
    );
  }
}

/// Draws one frame of a face.
///
/// The 40x40 box the desktop uses is kept verbatim and scaled here, so every
/// constant below is the desktop's constant rather than a re-derived one.
class _BotFacePainter extends CustomPainter {
  final BotAvatarSource source;
  final BotFaceMood mood;
  final BotFacePose pose;

  _BotFacePainter({
    required this.source,
    required this.mood,
    required this.pose,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // The face box is 40 wide and 44 tall: the three working dots live below
    // the 40 outline and would be clipped otherwise. The widget is square, so
    // the extra 4 units are what the dots get.
    const box = Size(40, 44);
    final scale = math.min(size.width / box.width, size.height / box.height);
    canvas.save();
    canvas.translate(
      (size.width - box.width * scale) / 2,
      (size.height - box.height * scale) / 2,
    );
    canvas.scale(scale);

    final body = Paint()..color = source.color;
    final path = Path();

    // The cloud is a fixed path on the desktop: re-projecting its sampled
    // ring wobbles the puff seams. Everything else is projected per frame.
    final ring = faceRing(source.shape);
    final projected = [
      for (final p in ring) projectFacePoint(p, pose.turn, pose.tilt, pose.roll),
    ];
    path.moveTo(projected.first.x, projected.first.y);
    for (final p in projected.skip(1)) {
      path.lineTo(p.x, p.y);
    }
    path.close();
    canvas.drawPath(path, body);

    // Eyes sit 15.4 and 24.6 across; 17.2 down, except the cloud's body is
    // lower so its eyes drop to 22. Catchlights ride the pupils.
    final eyeY =
        (source.shape == BotFaceShape.cloud ? 22.0 : 17.2) + pose.gazeY;
    final eyeL = 15.4 + pose.gazeX;
    final eyeR = 24.6 + pose.gazeX;

    // Pupils flip light on a dark body so the eyes stay readable on the ink
    // and oxblood swatches.
    final dark = _isDark(source.color);
    final eyeFill =
        dark ? const Color(0xF2EBC3F2) : const Color(0xD9000000);
    final catchlight =
        dark ? const Color(0x99000000) : const Color(0xD9FFFFFF);
    final eyeHeight = mood == BotFaceMood.idle ? 4.6 : 5.2;

    if (!pose.blink) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(eyeL, eyeY),
          width: 4.4,
          height: eyeHeight,
        ),
        Paint()..color = eyeFill,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(eyeR, eyeY),
          width: 4.4,
          height: eyeHeight,
        ),
        Paint()..color = eyeFill,
      );
      final hl = Paint()..color = catchlight;
      canvas.drawCircle(Offset(eyeL - 0.6, eyeY - 0.7), 0.65, hl);
      canvas.drawCircle(Offset(eyeR - 0.6, eyeY - 0.7), 0.65, hl);
    } else {
      // Shut: two short horizontal strokes, one per eye.
      final shut = Paint()
        ..color = eyeFill
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(eyeL - 2.6, eyeY),
        Offset(eyeL + 2.6, eyeY),
        shut,
      );
      canvas.drawLine(
        Offset(eyeR - 2.6, eyeY),
        Offset(eyeR + 2.6, eyeY),
        shut,
      );
    }

    // The three working dots, always mounted and hidden by opacity — the
    // desktop never mounts or unmounts them either.
    final dot = Paint()..color = source.color;
    void dotAt(double cx, double opacity) {
      if (opacity <= 0) return;
      dot.color = source.color.withValues(alpha: opacity);
      canvas.drawCircle(Offset(cx, 41.2), 1.15, dot);
    }

    dotAt(16.4, pose.d0);
    dotAt(20, pose.d1);
    dotAt(23.6, pose.d2);

    canvas.restore();
  }

  /// The desktop's luminance rule, with its threshold.
  static bool _isDark(Color color) {
    final r = color.r * 255;
    final g = color.g * 255;
    final b = color.b * 255;
    return 0.2126 * r + 0.7152 * g + 0.0722 * b < 110;
  }

  @override
  bool shouldRepaint(_BotFacePainter oldDelegate) =>
      oldDelegate.pose != pose || oldDelegate.source != source;
}
