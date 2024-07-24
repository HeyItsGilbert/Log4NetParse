<#
.SYNOPSIS
  Parses a log4net into an object that is easier to search and filter.
.DESCRIPTION
  Reads log4net log(s) and creates a new set of custom objects. It highlights
  details that make it easier to search and filter logs.
.NOTES
  Works for Windows PowerShell and PowerShell Core.
.LINK
  TBD
.EXAMPLE
  Read-Log4NetLog

  This will read a .log file in the current directory.
.PARAMETER Path
  The path to the directory/file you want to parse.
.PARAMETER FileLimit
  How many files should we parse if given a folder path?
.PARAMETER Filter
  The filter passed to Get Child Item. Default to '*.log'
.PARAMETER PatternLayout
  The matching pattern layout.

  https://logging.apache.org/log4net/release/sdk/?topic=html/T_log4net_Layout_PatternLayout.htm
#>
function Read-Log4NetLog {
  [CmdletBinding()]
  [OutputType([Log4NetLog])]
  param (
    [ValidateScript({
        if (-Not ($_ | Test-Path) ) {
          throw "File or folder does not exist"
        }
        return $true
      })]
    [string[]]
    $Path,
    [int]
    $FileLimit = 1,
    [String]
    $Filter = '*',
    [String]
    $PatternLayout = '%date %thread [%-5level] - %message'
  )
  $files = Get-Item -Path $Path
  if ($files.PSIsContainer) {
    $files = Get-ChildItem -Path $Path -Filter $Filter |
      Sort-Object -Property LastWriteTime | Select-Object -Last $FileLimit
  }
  Write-Verbose "Found files: $($files -join ',')"

  $parsed = @{}

  # Get the regex for the Log4Net PatternLayout
  $RegularExpression = Convert-PatternLayout -PatternLayout $PatternLayout
  $files | ForEach-Object -Process {
    $file = $_
    Write-Verbose "Reading over file: $file"
    $raw = [System.IO.File]::ReadAllLines($file.FullName)
    Write-Verbose "Lines read: $($raw.Count)"
    # Iterate over each line
    foreach ($line in $raw) {
      Write-Debug $line
      $m = $RegularExpression.match($line)
      if ($m.Success) {
        [int]$threadMatch = $m.Groups['thread'].Value
        # Replace comma with period to make it a valid datetime
        [datetime]$currentDateTime = $m.Groups['date'].Value -replace ',', '.'
        # Check if thread exists, if not make it.
        if (-not ($parsed.ContainsKey($threadMatch))) {
          Write-Verbose "New thread detected: $threadMatch"
          $null = $parsed.Add(
            $threadMatch,
            [Log4NetLog]::new(
              $threadMatch,
              $file
            )
          )
        }
        Write-Verbose "Adding new log line to thread $threadMatch"
        $parsed.Item($threadMatch).AddLogLine(
          [Log4NetLogLine]::new(
            $currentDateTime,
            $threadMatch,
            $m.Groups['level'].Value,
            $m.Groups['message'].Value
          ))
      } else {
        Write-Verbose "Line did not match regex"
        Write-Debug $line
        # if it doesn't match regex, append to the previous
        if ($threadMatch) {
          Write-Verbose "Appending to existing thread: $threadMatch"
          $parsed.Item($threadMatch).AppendLastLogLine($line)
        } else {
          # This might happen if the log starts on what should have been a
          # multiline entry... Not very likely
          Write-Warning "No currentSession. File: $File; Line: $Line"
        }
      }
    }
  }

  # Doing this at the end since threads can get mixed
  $parsed.Keys | ForEach-Object {
    Write-Verbose "Parsing special logs for: $_"
    # This updates fields like: cli, environment, and configuration
    $parsed.Item($_).ParseSpecialLogs()
  }

  # Return the whole parsed object
  Write-Verbose "Returning results in desceding order. Count: $($parsed.Count)"
  $parsed.Values | Sort-Object -Descending StartTime
}
