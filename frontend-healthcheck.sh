#!/bin/sh
# Unhealthy until the first build finishes, and again whenever the most
# recent `ng serve` build cycle failed to compile.
LOG=/tmp/ng-serve.log

[ -f "$LOG" ] || exit 1

recent=$(tail -n 200 "$LOG")
ok_line=$(printf '%s\n' "$recent" | grep -n "Application bundle generation complete" | tail -1 | cut -d: -f1)
err_line=$(printf '%s\n' "$recent" | grep -n "Application bundle generation failed" | tail -1 | cut -d: -f1)

ok_line=${ok_line:-0}
err_line=${err_line:-0}

[ "$ok_line" -gt "$err_line" ]
