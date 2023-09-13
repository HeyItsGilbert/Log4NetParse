class Log4NetLog {
  [int]$Thread
  [System.Collections.Generic.List[Log4NetLogLine]]$logs
  [datetime]$startTime
  [datetime]$endTime
  [string]$filePath

  Log4NetLog(
    [int]$Thread,
    [datetime]$startTime,
    [string]$filePath
  ) {
    $this.Thread = $Thread
    $this.startTime = $startTime
    $this.logs = [System.Collections.Generic.List[Log4NetLogLine]]::new()
    $this.filePath = $filePath
  }
}
