class Log4NetLogLine {
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
}
