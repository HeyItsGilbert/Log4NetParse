class Log4NetLog {
  [int]$Thread
  [System.Collections.Generic.List[Log4NetLogLine]]$LogLines
  [datetime]$StartTime
  [datetime]$EndTime
  [string]$FilePath

  static [hashtable[]] $MemberDefinitions = @(
    @{
      MemberType = 'AliasProperty'
      MemberName = 'logs'
      Value = 'LogLines'
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
    [datetime]$StartTime,
    [string]$FilePath
  ) {
    $this.Thread = $Thread
    $this.StartTime = $StartTime
    $this.LogLines = [System.Collections.Generic.List[Log4NetLogLine]]::new()
    $this.FilePath = $FilePath
  }

}
