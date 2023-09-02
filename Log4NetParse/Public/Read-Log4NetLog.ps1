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
  [OutputType([System.Collections.ArrayList])]
  param (
    [Parameter(ValueFromPipeline)]
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
    $files = Get-ChildItem -Path $Path -Filter $Filter | Sort-Object -Property LastWriteTime | Select-Object -Last $FileLimit
  }

  [System.Collections.ArrayList]$parsed = @()

  # Get the regex for the Log4Net PatternLayout
  $RegularExpression = Convert-PatternLayout -PatternLayout $PatternLayout
  $files | ForEach-Object -Process {
    $file = $_
    $raw = [System.IO.File]::ReadAllLines($file.FullName)

    # Iterate over each line
    foreach ($line in $raw) {
      # Write-Debug $line
      $m = $RegularExpression.match($line)
      if ($m.Success) {
        # If it matches the regex, tag it
        if ( $m.Groups['thread'].Value -ne $currentSession.thread) {
          if ($currentSession) {
            $currentSession.endTime = $currentSession.logs[-1].time
            $parsed.Add($currentSession) > $null
          }

          # This is a different session
          $currentSession = [Log4NetLog]::new(
            $m.Groups['thread'].Value,
            ($m.Groups['date'].Value -replace ',', '.'),
            $file
          )
        }

        $currentSession.logs.Add(
          [Log4NetLogLine]::new(
            [Datetime]($m.Groups['date'].Value -replace ',', '.'),
            $m.Groups['thread'].Value,
            $m.Groups['level'].Value,
            $m.Groups['message'].Value
          )) > $null
      } else {
        # if it doesn't match regex, append to the previous
        if ($currentSession) {
          $currentSession.logs[-1].AppendMessage($line)
        } else {
          # This might happen if the log starts on what should have been a
          # multiline entry... Not very likely
          Write-Warning "No currentSession. File: $File; Line: $Line"
        }
      }
    }
  }
  # Write out the last log line!
  if (-Not $parsed.Contains($currentSession)) {
    $parsed.Add($currentSession) > $null
  }

  # Return the whole parsed object
  $parsed
}
