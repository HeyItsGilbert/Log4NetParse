# Log4NetParse

A module to parse log4net logs and give back easy to filter objects.

![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/Log4NetParse)
![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/Log4NetParse)
![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/HeyItsGilbert/Log4NetParse/.github/workflows/CI.yaml?branch=main)
![PowerShell Gallery](https://img.shields.io/powershellgallery/p/Log4NetParse)

## Overview

This was written to parse logs for tools that write out logs with Log4Net.

Learn more at [log4net](https://logging.apache.org/log4net/)

Note: My use of Log4Net is limited and most the regex for different pattern
names are a complete guess by me. If you are familiar with these, please file
an issue or make a PR.

## Documentation

Docs automatically updated at
[heyitsgilbert.github.io/Log4NetParse](https://heyitsgilbert.github.io/Log4NetParse/)

## Installation

```powershell
Install-Module Log4NetParse
```

## Examples

```powershell
Import-Module Log4NetParse

# Find a regex for your pattern (i.e., useful for use in other tools)
Convert-PatternLayout -PatternLayout '%timestamp [%thread] %level %logger %ndc - %message%newline'

# Parse a log and get set of objects
Read-Log4NetLog -Path 'current.log'
```

The `Read-Log4NetLog` cmdlet will return an object for each thread it finds in a
file. This can be helpful when trying to find the log lines for a particular
execution. This makes it easier to filter on things like start/end time, and
log level.
