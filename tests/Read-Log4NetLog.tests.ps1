BeforeDiscovery {
  $manifest = Import-PowerShellDataFile -Path $env:BHPSModuleManifest
  $outputDir = Join-Path -Path $env:BHProjectPath -ChildPath 'Output'
  $outputModDir = Join-Path -Path $outputDir -ChildPath $env:BHProjectName
  $outputModVerDir = Join-Path -Path $outputModDir -ChildPath $manifest.ModuleVersion
  $outputModVerManifest = Join-Path -Path $outputModVerDir -ChildPath "$($env:BHProjectName).psd1"

  # Get module commands
  # Remove all versions of the module from the session. Pester can't handle multiple versions.
  Get-Module $env:BHProjectName | Remove-Module -Force -ErrorAction Ignore
  Import-Module -Name $outputModVerManifest -Verbose:$false -ErrorAction Stop
}

Describe 'Read-Log4NetLog' {
  BeforeAll {
    # Setup dummy data including things across multiple lines
    $folder = "TestDrive:\folder"
    New-Item -Path "TestDrive:\" -Name 'folder' -Type Directory -Force
    $singleFile = "TestDrive:\test.log"
    # Due to "files.trimTrailingWhitespace" vscode setting, I added some '.'s
    # to the multiline examples
    Set-Content $singleFile -Value @'
2023-06-14 14:22:09,411 57332 [DEBUG] - .
NOTE: Hiding sensitive configuration data! Please double and triple
  check to be sure no sensitive data is shown, especially if copying
  output to a gist for review.
2023-06-14 14:22:09,417 57332 [DEBUG] - Configuration: CommandName='upgrade'|CacheLocation='C:\Windows\TEMP\chocolatey'|
ContainsLegacyPackageInstalls='False'|
CommandExecutionTimeoutSeconds='2700'|WebRequestTimeoutSeconds='30'|
Sources='http://127.0.0.1:18081/chocoapi/'|SourceType='normal'|
Debug='False'|Verbose='False'|Trace='False'|Force='False'|Noop='False'|
HelpRequested='False'|UnsuccessfulParsing='False'|RegularOutput='True'|
QuietOutput='False'|PromptForConfirmation='False'|
DisableCompatibilityChecks='False'|AcceptLicense='True'|
AllowUnofficialBuild='False'|Input='zoom'|AllVersions='False'|
SkipPackageInstallProvider='False'|SkipHookScripts='False'|
2023-06-14 14:22:09,418 57332 [DEBUG] - _ Chocolatey:ChocolateyUpgradeCommand - Normal Run Mode _
2023-06-14 14:22:09,422 57332 [INFO ] - Upgrading the following packages:
2023-06-14 14:22:09,423 57332 [INFO ] - Detected environment as cpe.
2023-06-14 14:22:09,424 57332 [INFO ] - zoom
2023-06-14 14:22:09,425 57332 [INFO ] - By upgrading, you accept licenses for the packages.
2023-06-14 14:22:10,107 57332 [INFO ] - zoom v5.14.11.17466 is newer than the most recent.
  You must be smarter than the average bear...
2023-06-14 14:22:10,113 57332 [WARN ] - .
Chocolatey upgraded 0/1 packages.
  See the log for details (C:\ProgramData\chocolatey\logs\chocolatey.log).
2023-06-14 14:22:10,115 57332 [DEBUG] - Sending message 'PostRunMessage' out if there are subscribers...
2023-06-14 14:22:09,410 12345 [DEBUG] - The source 'http://127.0.0.1:18081/chocoapi/' evaluated to a 'normal' source type
2023-06-14 14:22:09,411 54321 [DEBUG] - The source 'http://127.0.0.1:18081/chocoapi/' evaluated to a 'normal' source type
2023-06-14 14:22:10,117 57332 [DEBUG] - Exiting with 100
'@
    # Create 10 files with 2 random sessions
    0..10 | ForEach-Object {
      $randID = Get-Random -Minimum 1000 -Maximum 99999
      $randID2 = $randID - 100
      $day = "{0:d2}" -f $_
      Set-Content "TestDrive:\folder\$($_).log" -Value @"
2023-06-$day 14:22:09,411 $randId [DEBUG] - Ffoo
2023-06-$day 14:22:09,418 $randId [DEBUG] - _ Chocolatey:ChocolateyUpgradeCommand - Normal Run Mode _
2023-06-$day 14:22:09,422 $randId [INFO ] - Upgrading the following packages:
2023-06-$day 14:22:09,423 $randId [INFO ] - zoom
2023-06-$day 14:22:10,115 $randId [DEBUG] - Sending message 'PostRunMessage' out if there are subscribers...
2023-06-$day 14:22:10,117 $randId [DEBUG] - Exiting with 0
2023-06-$day 15:22:10,411 $randId2 [DEBUG] - Ffoo
2023-06-$day 15:22:10,412 $randId2 [DEBUG] - Exiting with 0
2023-06-$day 14:22:10,423 $randId [INFO ] - By upgrading, you accept licenses for the packages.
2023-06-$day 14:22:11,107 $randId [INFO ] - zoom v5.14.11.17466 is newer than the most recent.
  You must be smarter than the average bear...
2023-06-$day 14:22:11,113 $randId [WARN ] - .
Chocolatey upgraded 0/1 packages.
  See the log for details (C:\ProgramData\chocolatey\logs\chocolatey.log).
"@
    }

    $script:parsed = Read-Log4NetLog -Path $singleFile
    $script:multiple = Read-Log4NetLog -Path $folder
    $script:moreLimit = Read-Log4NetLog -Path $folder -FileLimit 10
  }

  Context 'For Single File' {
    It 'Parses the correct number of sessions' {
        ($parsed).Count | Should -Be 3
    }

    It 'Parses the correct number of lines per session' {
      $parsed[0].LogLines.Count | Should -Be 11
    }

    It 'Detects the right session number' {
      $parsed[0].thread | Should -Be 57332
    }
  }

  Context 'For Folder Path' {
    It 'Parses the correct default number of sessions' {
      # There is two session in each file so there should be a total of 1
      # 3 for $randID and 3 for $randID2
      ($multiple).Count | Should -Be 2
    }

    It 'Parses the correct number of sessions for increased limit' {
      # There is one session in each file so there should be a total of 20
      # 10 for $randID and 10 for $randID2
      ($moreLimit).Count | Should -Be 20
    }

    It 'Parses the correct number of lines per session' {
      $multiple[1].logs.Count | Should -Be 9
    }
  }

  It 'Parses a log with lines that have the same exact time' {
    $results = Read-Log4NetLog "$PSScriptRoot\fixtures\ch copy.log"
    $results.Count | Should -Be 4
    $results.Thread | Should -Be @(12720, 6432, 18380, 14068)
  }
}
