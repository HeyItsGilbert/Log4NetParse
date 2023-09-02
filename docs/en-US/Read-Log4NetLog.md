---
external help file: Log4NetParse-help.xml
Module Name: Log4NetParse
online version:
schema: 2.0.0
---

# Read-Log4NetLog

## SYNOPSIS
Parses a log4net into an object that is easier to search and filter.

## SYNTAX

```
Read-Log4NetLog [[-Path] <String[]>] [[-FileLimit] <Int32>] [[-Filter] <String>] [[-PatternLayout] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Reads log4net log(s) and creates a new set of custom objects.
It highlights
details that make it easier to search and filter logs.

## EXAMPLES

### EXAMPLE 1
```
Read-Log4NetLog
```

This will read a .log file in the current directory.

## PARAMETERS

### -Path
The path to the directory/file you want to parse.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FileLimit
How many files should we parse if given a folder path?

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 1
Accept pipeline input: False
Accept wildcard characters: False
```

### -Filter
The filter passed to Get Child Item.
Default to '*.log'

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: *
Accept pipeline input: False
Accept wildcard characters: False
```

### -PatternLayout
The matching pattern layout.

https://logging.apache.org/log4net/release/sdk/?topic=html/T_log4net_Layout_PatternLayout.htm

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: %timestamp %thread [%level] - %message%newline
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Collections.ArrayList
## NOTES
Works for Windows PowerShell and PowerShell Core.

## RELATED LINKS

[TBD]()

