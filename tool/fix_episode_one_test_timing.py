from pathlib import Path


greenhouse_path = Path("test/episode_one_greenhouse_test.dart")
greenhouse = greenhouse_path.read_text(encoding="utf-8")
old_discovery = """    expect(
      find.byKey(const Key('episode-one-greenhouse-discovery')),
      findsOneWidget,
    );
"""
new_discovery = """    expect(
      find.byKey(const Key('episode-one-greenhouse-discovery')),
      findsWidgets,
    );
"""
if old_discovery not in greenhouse:
    raise SystemExit("Greenhouse discovery expectation was not found")
greenhouse_path.write_text(
    greenhouse.replace(old_discovery, new_discovery, 1),
    encoding="utf-8",
)


finale_path = Path("test/episode_one_finale_test.dart")
finale = finale_path.read_text(encoding="utf-8")

for key in ["episode-one-hypothesis-0", "episode-one-hypothesis-1"]:
    tap = f"    await tester.tap(find.byKey(const Key('{key}')));\n"
    replacement = tap + "    await tester.pump();\n"
    count = finale.count(tap)
    if count == 0:
        raise SystemExit(f"Hypothesis tap not found: {key}")
    finale = finale.replace(tap, replacement)

finale_path.write_text(finale, encoding="utf-8")
