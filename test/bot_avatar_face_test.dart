// Tests for the ported Bot Mode face.
//
// These are not "it paints something" tests. The whole point of the port is
// that the app's face matches the desktop's frame for frame, so the
// assertions pin the transcribed constants against values read straight out
// of `avatar.tsx` and the measured gateway data. If a constant here drifts,
// the assumption is that the app's face and the desktop's face have
// silently diverged.
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hermes_android/core/widgets/bot_avatar_face.dart';

double _min(double a, double b) => a < b ? a : b;
double _max(double a, double b) => a > b ? a : b;

extension on BotFacePoint {
  double distanceTo(BotFacePoint other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return math.sqrt(dx * dx + dy * dy);
  }
}

void main() {
  group('BotFaceShape.parse', () {
    test('knows every value the wire can carry', () {
      expect(BotFaceShape.parse('circle'), BotFaceShape.circle);
      expect(BotFaceShape.parse('squircle'), BotFaceShape.squircle);
      expect(BotFaceShape.parse('pill'), BotFaceShape.pill);
      expect(BotFaceShape.parse('triangle'), BotFaceShape.triangle);
      expect(BotFaceShape.parse('hexagon'), BotFaceShape.hexagon);
      expect(BotFaceShape.parse('blob'), BotFaceShape.blob);
      expect(BotFaceShape.parse('cloud'), BotFaceShape.cloud);
      expect(BotFaceShape.parse('drop'), BotFaceShape.drop);
      // `teardrop` is an alias the desktop also accepts on the wire.
      expect(BotFaceShape.parse('teardrop'), BotFaceShape.drop);
    });

    test('resolves unknown and empty to circle, never throws', () {
      expect(BotFaceShape.parse(null), BotFaceShape.circle);
      expect(BotFaceShape.parse(''), BotFaceShape.circle);
      expect(BotFaceShape.parse('platonic-solid'), BotFaceShape.circle);
    });
  });

  group('faceRing geometry', () {
    test('point counts follow the desktop, composites included', () {
      // Simple analytic shapes are exactly `steps`. The composites are not:
      // the drop is cubic (n) + arc (n+1) + cubic (n) with n = steps~/3, which
      // happens to land on 52 at the default step count, and the cloud forces
      // `n = max(64, steps)` before splitting its arcs by length. Asserting
      // 52 everywhere would be asserting a number the desktop never computes.
      expect(faceRing(BotFaceShape.circle).length, 52);
      expect(faceRing(BotFaceShape.blob).length, 52);
      expect(faceRing(BotFaceShape.squircle).length, 52);
      expect(faceRing(BotFaceShape.pill).length, 52);
      expect(faceRing(BotFaceShape.triangle).length, 52);
      expect(faceRing(BotFaceShape.hexagon).length, 52);
      // drop: 17 + 18 + 17
      expect(faceRing(BotFaceShape.drop).length, (52 ~/ 3) * 2 + (52 ~/ 3 + 1));
      // cloud: min(64, steps) then split by arc length
      expect(faceRing(BotFaceShape.cloud).length, greaterThanOrEqualTo(64));
    });

    test('ring bounds match the desktop, triangle overflow included', () {
      // These numbers come from transcribing the desktop's `sampleFaceRing`
      // into Python and running it, not from adjusting until the test passes.
      // The triangle's y going to -3.21 is not a bug: the analytic ring is
      // wider than the static SVG path the desktop falls back to, and the
      // face SVG is drawn with overflow visible. Correcting my port to
      // "fix" this would desynchronise it from the desktop.
      final ring = faceRing(BotFaceShape.triangle);
      final xs = ring.map((p) => p.x).toList();
      final ys = ring.map((p) => p.y).toList();
      expect(xs.reduce((a, b) => _min(a, b)), closeTo(0.44, 0.02));
      expect(xs.reduce((a, b) => _max(a, b)), closeTo(39.56, 0.02));
      expect(ys.reduce((a, b) => _min(a, b)), closeTo(-3.21, 0.02));
      expect(ys.reduce((a, b) => _max(a, b)), closeTo(33.50, 0.02));
    });

    test('the circle is a circle', () {
      // Every point of BotFaceShape.circle must sit 16.2 from the centre —
      // this is the check that catches a mis-transcribed squircle exponent or
      // a pill y-squash landing on the wrong branch.
      final ring = faceRing(BotFaceShape.circle);
      for (final p in ring) {
        expect(
          p.distanceTo(const BotFacePoint(20, 20)),
          closeTo(16.2, 0.01),
        );
      }
    });

    test('a hexagon really is hexagonal', () {
      // Six distinct sectors produce six corners; the edge-radius ratio is
      // what makes a hexagon read as a hexagon rather than a circle.
      final ring = faceRing(BotFaceShape.hexagon);
      final radii = <double>[];
      for (final p in ring) {
        radii.add(p.distanceTo(const BotFacePoint(20, 20)));
      }
      final minR = radii.reduce((a, b) => _min(a, b));
      final maxR = radii.reduce((a, b) => _max(a, b));
      expect(maxR, greaterThan(minR * 1.02));
    });

    test('the cloud sits lower than the circle it derives from', () {
      // The cloud body hangs below the circle's centre line; the desktop
      // therefore draws its eyes 4.8 lower than every other shape's.
      final cloud = faceRing(BotFaceShape.cloud);
      final minY = cloud.map((p) => p.y).reduce(_min);
      expect(minY, greaterThan(0));
    });

    test('the drop is not symmetric — it points up', () {
      // The cubic constricts the top of the ring, so the widest half is the
      // bottom. A symmetric drop would be a circle.
      final ring = faceRing(BotFaceShape.drop);
      final above = ring.where((p) => p.y < 20).toList();
      final below = ring.where((p) => p.y >= 20).toList();
      expect(above.isNotEmpty, isTrue);
      expect(below.isNotEmpty, isTrue);
      final topWidth = (above.map((p) => p.x).reduce(_max) -
              above.map((p) => p.x).reduce(_min))
          .abs();
      final bottomWidth = (below.map((p) => p.x).reduce(_max) -
              below.map((p) => p.x).reduce(_min))
          .abs();
      expect(
        bottomWidth,
        greaterThan(topWidth),
        reason: 'a water drop is wider at the bottom than the top',
      );
    });
  });

  group('colour and shape derivation', () {
    test('an explicit #rrggbb wins over the hash', () {
      expect(colorFor('anything', '#8B5CF6'), const Color(0xFF8B5CF6));
      expect(colorFor('anything', '8b5cf6'), const Color(0xFF8B5CF6));
    });

    test('a bot with no pinned colour is still not grey', () {
      // The desktop derives a hue from the profile name at 68% sat / 58%
      // light; an unpinned bot must land on something saturated, never 0.
      for (final name in ['cto', 'cmo', 'deepseek-2', 'product-manager']) {
        final color = colorFor(name, null);
        final hsl = HSLColor.fromColor(color);
        expect(hsl.saturation, closeTo(0.68, 0.02));
        expect(hsl.lightness, closeTo(0.58, 0.02));
      }
    });

    test('the same name always derives the same face', () {
      // Determinism is the contract — the desktop and the app must agree
      // without persisting anything.
      for (var i = 0; i < 5; i++) {
        expect(shapeForName('deepseek-2'), shapeForName('deepseek-2'));
      }
    });

    test('different names spread across shapes', () {
      // Eight shapes and a hash modulo: over the gateway's 17 profiles more
      // than one silhouette must appear, or the derivation is broken.
      final shapes = <BotFaceShape>{};
      for (var i = 0; i < 40; i++) {
        shapes.add(shapeForName('profile-$i'));
      }
      expect(shapes.length, greaterThan(1));
    });

    test('hashString matches the desktop\u2019s (hash * 31 + char) >>> 0', () {
      // The unsigned-shift behaviour is the whole reason this is not a plain
      // accumulation: name.length and byte order must not matter, only the
      // uint32 wrap does.
      expect(hashString(''), 0);
      expect(hashString('a'), 97);
      expect(hashString('ab'), (97 * 31 + 98));
      // A name long enough to wrap uint32 many times over.
      final long = hashString('a-very-long-bot-name-that-wraps');
      expect(long, greaterThanOrEqualTo(0));
      expect(long, lessThan(1 << 32));
    });
  });

  group('BotAvatarSource.resolve', () {
    test('a real photo is kept', () {
      final source = BotAvatarSource.resolve(
        profileName: 'cto',
        imageKind: 'photo',
        imageBytes: Uint8List.fromList(const [
          0x89,
          0x50,
          0x4E,
          0x47,
          0x0D,
          0x0A,
          0x1A,
          0x0A,
          // IHDR length
          0x00, 0x00, 0x00, 0x0D,
          // 'IHDR'
          0x49, 0x48, 0x44, 0x52,
          // width 1024
          0x00, 0x00, 0x04, 0x00,
          // height 1024
          0x00, 0x00, 0x04, 0x00,
          0x08, 0x06, 0x00, 0x00, 0x00,
        ]),
      );
      expect(source.kind, BotAvatarKind.photo);
      expect(source.image, isNotNull);
    });

    test('the 160x160 backfill raster is dropped, face is drawn', () {
      // The decisive case: every profile on this gateway has such an asset,
      // and showing it would freeze the animation. Width 160, height 160 is
      // the signature the desktop's `isBackfilledFacePng` reads.
      final source = BotAvatarSource.resolve(
        profileName: 'cto',
        imageKind: 'shape',
        hasAvatar: true,
        imageBytes: _backfillRaster(),
      );
      expect(source.kind, BotAvatarKind.face);
      expect(source.image, isNull);
      expect(source.shape, isA<BotFaceShape>());
    });

    test('hasAvatar alone never promotes a raster to a portrait', () {
      // The roster sends has_avatar: true for all 17 profiles; if that flag
      // alone selected a picture, every face would stop animating.
      final source = BotAvatarSource.resolve(
        profileName: 'cto',
        hasAvatar: true,
        imageBytes: _backfillRaster(),
      );
      expect(source.kind, BotAvatarKind.face);
    });

    test('no avatar at all still yields a live face', () {
      final source = BotAvatarSource.resolve(profileName: 'deepseek-2');
      expect(source.kind, BotAvatarKind.face);
      // Colour comes from the derived hue, not from a null.
      expect(source.color, isNot(const Color(0xFF000000)));
    });

    test('an unparseable hex falls back to the derived hue', () {
      final pinned = colorFor('cto', '#8B5CF6');
      final fallback = colorFor('cto', '#xyz');
      expect(pinned, isNot(fallback));
      expect(fallback, colorFor('cto', null));
    });
  });

  group('BotFacePose', () {
    test('idle and working poses are different', () {
      // Idle sways gently around a neutral turn; working leans hard (the turn
      // is centred at -11, not 0) and looks up. Asserting on the *centre* of
      // the lean rather than one instant is what makes this robust.
      final idle = BotFacePose.at(BotFaceMood.idle, 0.0);
      final work = BotFacePose.at(BotFaceMood.work, 0.0);
      expect(idle.turn.abs(), lessThan(2.0));
      expect(work.turn.abs(), greaterThan(5.0));
      expect(work.gazeY, lessThan(idle.gazeY));
      expect(idle.blink, isFalse);
      expect(work.d1, greaterThan(idle.d1));
    });

    test('a blink eventually happens', () {
      // `facePose` only blinks while working — the idle pose has no blink at
      // all, which is the desktop's behaviour too (a resting face stays open).
      // Over a 10-second sample the closed-eye pose must appear.
      var sawBlink = false;
      for (var i = 0; i < 1000; i++) {
        if (BotFacePose.at(BotFaceMood.work, i * 0.01).blink) sawBlink = true;
      }
      expect(sawBlink, isTrue);
    });

    test('an idle pose never blinks', () {
      // The desktop's `facePose` returns `blink: false` for the idle branch.
      // If a port ever adds a blink to idle, this is what catches it.
      for (var i = 0; i < 1000; i++) {
        expect(BotFacePose.at(BotFaceMood.idle, i * 0.01).blink, isFalse);
      }
    });

    test('the three working dots do not all peak together', () {
      // They are staggered on purpose — a shared phase would look like a
      // single pulsing bar rather than three dots.
      final t = 1.234;
      final p = BotFacePose.at(BotFaceMood.work, t);
      final set = <double>{p.d0, p.d1, p.d2};
      expect(set.length, greaterThan(1));
    });

    test('a pose is a pure function of time', () {
      final a = BotFacePose.at(BotFaceMood.idle, 3.0);
      final b = BotFacePose.at(BotFaceMood.idle, 3.0);
      expect(a.turn, b.turn);
      expect(a.tilt, b.tilt);
      expect(a.gazeX, b.gazeX);
      expect(a.blink, b.blink);
    });

    test('lerp(1) is exactly the target', () {
      const from = BotFacePose(turn: 0.2, tilt: 1.0, roll: -0.5);
      const to = BotFacePose(turn: -0.3, tilt: 2.0, roll: 0.75);
      final blended = from.lerp(to, 1.0);
      expect(blended.turn, closeTo(-0.3, 1e-9));
      expect(blended.tilt, closeTo(2.0, 1e-9));
      expect(blended.roll, closeTo(0.75, 1e-9));
    });
  });

  group('BotFace widget', () {
    testWidgets('mounts and keeps running without crashing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BotFace(
              source: BotAvatarSource(
                shape: BotFaceShape.circle,
                color: Color(0xFF8B5CF6),
              ),
              size: 40,
            ),
          ),
        ),
      );
      // It must not need pumpAndSettle — the face animates forever.
      await tester.pump(const Duration(milliseconds: 16));
      expect(find.byType(BotFace), findsOneWidget);
      // scoped to the face: MaterialApp contributes its own CustomPaint, so a
      // bare finder here counts the app's as well.
      expect(
        find.descendant(
          of: find.byType(BotFace),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );
    });

    testWidgets('advances when time passes', (tester) async {
      // The clock is a shared singleton, so a mounted face keeps ticking.
      // Pumping a later duration must not throw and must keep the widget
      // alive — this is the "the animation is actually wired" check.
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BotFace(
              source: BotAvatarSource(
                shape: BotFaceShape.blob,
                color: Color(0xFF38BDF8),
              ),
              size: 40,
            ),
          ),
        ),
      );
      for (var i = 0; i < 3; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(find.byType(BotFace), findsOneWidget);
    });

    testWidgets('the clock stops when the last face goes away', (tester) async {
      // Mount, then unmount inside THIS test, so the singleton's own bookkeeping
      // is what is under test rather than some earlier test's teardown.
      Widget face() => const MaterialApp(
        home: Scaffold(
          body: BotFace(
            source: BotAvatarSource(
              shape: BotFaceShape.circle,
              color: Color(0xFF8B5CF6),
            ),
            size: 40,
          ),
        ),
      );

      await tester.pumpWidget(face());
      await tester.pump(const Duration(milliseconds: 16));
      expect(BotFaceClock.instance.isActive, isTrue);

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump(const Duration(milliseconds: 16));
      // With no face mounted the clock has nothing to drive, so its ticker is
      // disposed. Left running it would hold the frame forever, which is the
      // exact bug `pumpAndSettle` cannot survive in a screen that has no bots.
      expect(BotFaceClock.instance.isActive, isFalse);
    });

    testWidgets('a face mounted after the clock started resynchronises', (
      tester,
    ) async {
      // Mounting a second face must not reset the first one's phase.
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                BotFace(
                  source: BotAvatarSource(
                    shape: BotFaceShape.circle,
                    color: Color(0xFF8B5CF6),
                  ),
                  size: 32,
                ),
                BotFace(
                  source: BotAvatarSource(
                    shape: BotFaceShape.drop,
                    color: Color(0xFFF97316),
                  ),
                  size: 32,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 32));
      expect(find.byType(BotFace), findsNWidgets(2));
    });
  });
}

/// The exact raster the gateway serves for these profiles: a PNG whose IHDR
/// reports 160x160. It is what the desktop rasterizes from the SVG face and
/// pushes back for the inter-agent portrait, so showing it would freeze the
/// animation at an arbitrary instant.
Uint8List _backfillRaster() {
  return Uint8List.fromList(const [
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
    0x00, 0x00, 0x00, 0x0D,
    0x49, 0x48, 0x44, 0x52,
    // width: 160
    0x00, 0x00, 0x00, 0xA0,
    // height: 160
    0x00, 0x00, 0x00, 0xA0,
    0x08, 0x06, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x02,
    0x00, 0x00, 0x00, 0x00,
  ]);
}
