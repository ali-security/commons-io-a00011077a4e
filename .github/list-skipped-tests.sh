#!/usr/bin/env bash
# Lists every test Surefire skipped, with its reason. Surefire's console output
# only gives per-class skip counts, and JUnit assumptions without a message
# report the bare "Assumption failed: assumption is not true", so for each
# skipped test this also prints the assume*() line in its source that guarded it.
echo "Skipped tests (target/surefire-reports):"
awk '/<testcase/{tc=$0} /<skipped/{print tc; print}' target/surefire-reports/TEST-*.xml
for t in $(awk -F'"' '/<testcase/{n=$2; c=$4} /<skipped/{print c "#" n}' target/surefire-reports/TEST-*.xml); do
  f="src/test/java/$(echo "${t%%#*}" | tr . /).java"
  if [ -f "$f" ]; then
    echo "== ${t} guarding assumption (if any) in ${f}:"
    awk -v m="void ${t#*#}(" 'index($0, m) {p = 1; next} p && /^ *@(Test|ParameterizedTest|RepeatedTest)/ {exit} p && /assume(True|False)\(/ {print FNR ": " $0; exit}' "$f"
  fi
done
