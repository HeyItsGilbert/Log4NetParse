class Log4NetLog {
  [int]$Thread
  [System.Collections.ArrayList]$logs
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
    $this.logs = [System.Collections.ArrayList]::new()
    $this.filePath = $filePath
  }
}
