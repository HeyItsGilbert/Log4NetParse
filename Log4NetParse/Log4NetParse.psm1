# This module is combined. Any code in this file as added to the very end.


# Add our custom formatters
@(
  'Log4NetLogLine.format.ps1xml',
  'Log4NetLog.format.ps1xml'
) | ForEach-Object {
  Update-FormatData -PrependPath (Join-Path -Path $PSScriptRoot -ChildPath $_)
}
