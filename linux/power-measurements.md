# Power Consumption Measurements

Tags: #power #i915 #psr

Idle power draw comparisons under controlled conditions.

## Method

- Script: `~/devel/howto/measure-power.sh`
- 12 samples × 5s = 60s per run
- Conditions: battery only, screen static (terminal open), nothing active
- Log: `~/power-measurements.log`

## Results

| Date | PSR Setting | Avg Watts | Notes |
|------|-------------|-----------|-------|
| 2026-03-22 18:34 | PSR default (PSR2) | 11.85 W | baseline before fix, readings slightly declining (battery settling after unplug) |

## Context

Measurements taken to compare i915 PSR modes after hibernate resume kernel panic on Intel Arc 140V (Meteor Lake-P).

See [[problems]] for full issue details.
