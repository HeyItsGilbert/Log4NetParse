class Log4NetLog : System.IComparable {
  hidden [System.Collections.Generic.List[Log4NetLogLine]]$_logs
  [int]$Thread
  # [System.Collections.ArrayList]$LogLines
  [datetime]$StartTime
  [datetime]$EndTime
  [string]$FilePath

  static [hashtable[]] $MemberDefinitions = @(
    @{
      MemberType = 'AliasProperty'
      MemberName = 'logs'
      Value = 'LogLines'
    }
    @{
      MemberType = 'ScriptProperty'
      MemberName = 'LogLines'
      Value = { $this._logs.Sort(); $this._logs } # Getter
      SecondValue = { # Setter
        $this.AddLogLine($args[0])
      }
    }
  )

  static Log4NetLog() {
    $TypeName = [Log4NetLog].Name
    foreach ($Definition in [Log4NetLog]::MemberDefinitions) {
      Update-TypeData -TypeName $TypeName @Definition
    }
  }

  Log4NetLog(
    [int]$Thread,
    [string]$FilePath
  ) {
    $this.Thread = $Thread
    $this._logs = [System.Collections.Generic.List[Log4NetLogLine]]::new()
    $this.FilePath = $FilePath
  }

  # This parses all the logs for entries that are part of the class
  [void] ParseSpecialLogs() {
    $this._logs.Sort()
    $this.StartTime = $this._logs[0].time
    $this.EndTime = $this._logs[-1].time
  }

  [void]AddLogLine(
    [Log4NetLogLine]$line
  ) {
    $this._logs.Add($line)
  }

  [void]AppendLastLogLine(
    [string]$Line
  ) {
    $this._logs[-1].AppendMessage($line)
  }

  # Setup the comparable method.
  [int] CompareTo([object]$Other) {
    # If the other object's null, consider this instance "greater than" it
    if ($null -eq $Other) {
      return 1
    }
    # If the other object isn't a temperature, we can't compare it.
    $OtherLog = $Other -as [Log4NetLog]
    if ($null -eq $OtherLog) {
      throw [System.ArgumentException]::new(
        "Object must be of type 'Temperature'."
      )
    }
    # Compare the temperatures as Kelvin.
    return $this.Thread.CompareTo($OtherLog.Thread)
  }

}
