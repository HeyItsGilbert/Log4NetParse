# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [1.1.2] Add Fatal Level

### Fixes

- Adds missing Fatal level.

## [1.1.1] Switch from SortedList to List

### Fixes

- Now uses a List type for logs which allows us to use the Log4NetLogLine
  comparer method. Previously if two logs had the same exact time then it would
  have a collision in the SortedList.

## [1.1.0] Support Out of Order Log Entries

### Added

- Implement IComparable for Log4NetLog class.
- Move logs into a hidden `_logs` property which is a SortedList.
- `LogLines` and `logs` property now both a script property which returns the
  `_logs` SortedList values. This will ensure that LogLines are always in order
  regardless of which file they came from.
- `Read-Log4NetLog` now tracks parsed threads in a hash table, and returns the
  values by the StartTime in descending order.
- Added type accelerators to fix PlatyPS logging.

### Fixes

- Support having log threads be out of order. This can happen when multiple
  processes run.

## [1.0.0] logs to LogLines

This version renames `logs` on the object to `LogLines`. For backwards
compatibility `logs` is an alias to LogLines.

## [0.4.0] System.Collections.Generic.List[]

Replace ArrayList to improve performance and be stricter about the expected
object.

## [0.3.0] Formatting

Adding formatters for both classes (`Log4NetLog` and `Log4NetLogLine`) so that
it's easier to parse the objects. There is coloring using $PSStyle which means
you need PS7 or to install the
[PSStyle module](https://www.powershellgallery.com/packages/PSStyle).

## [0.2.0] Compiled

To support this module's classes being used in others (i.e., ChocoLogParse) this
needs to be a compiled module. That's the only change.

## [0.1.0] Unreleased

This is the initial build. Around the PatternLayout I'm doing a lot of guessing
around what the patterns look like live. Please give me feedback on that.

Primary goals:

- Create a function to parse the log file.
- Create a function to convert a PatternLayout into a Regex
- Create tests for both functions.
