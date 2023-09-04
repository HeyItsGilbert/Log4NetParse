# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [0.3.0] Formatting

Adding formatters for both classes (`Log4NetLog` and `Log4NetLogLine`) so that
it's easier to parse the objects. There is coloring using $PSStyle which means
you need PS7 or to install the [PSStyle module](https://www.powershellgallery.com/packages/PSStyle).

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
