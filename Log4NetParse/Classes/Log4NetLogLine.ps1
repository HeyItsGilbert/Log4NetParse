class Log4NetLogLine : System.IComparable {
  [datetime]$time
  [int]$thread
  [LogLevel]$level
  [string]$message

  # Constructor that build everything
  Log4NetLogLine(
    [datetime]$time,
    [int]$thread,
    [LogLevel]$level,
    [string]$message

  ) {
    $this.time = $time
    $this.thread = $thread
    $this.level = $level
    $this.message = $message
  }

  [void]AppendMessage([string]$message) {
    $this.message += "`n$message"
  }

  [string]ToString() {
    return @(
      $this.time
      $this.thread
      "[" + $this.level + "]"
      $this.message
    ) -join ' '
  }

  [int] CompareTo([object]$Other) {
    # If the other object's null, consider this instance "greater than" it
    if ($null -eq $Other) {
      return 1
    }
    # If the other object isn't a temperature, we can't compare it.
    $OtherLog = $Other -as [Log4NetLogLine]
    if ($null -eq $OtherLog) {
      throw [System.ArgumentException]::new(
        "Object must be of type 'Log4NetLogLine'."
      )
    }
    # Compare the temperatures as Kelvin.
    return $($this.ToString() -eq $OtherLog.ToString())
  }
}
