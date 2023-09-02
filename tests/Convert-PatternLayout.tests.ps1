BeforeDiscovery {
  $manifest           = Import-PowerShellDataFile -Path $env:BHPSModuleManifest
  $outputDir          = Join-Path -Path $ENV:BHProjectPath -ChildPath 'Output'
  $outputModDir       = Join-Path -Path $outputDir -ChildPath $env:BHProjectName
  $outputModVerDir    = Join-Path -Path $outputModDir -ChildPath $manifest.ModuleVersion
  $outputModVerManifest = Join-Path -Path $outputModVerDir -ChildPath "$($env:BHProjectName).psd1"
  # Get module commands
  # Remove all versions of the module from the session. Pester can't handle multiple versions.
  Get-Module $env:BHProjectName | Remove-Module -Force -ErrorAction Ignore
  Import-Module -Name $outputModVerManifest -Verbose:$false -ErrorAction Stop
}

Describe 'Convert-PatternLayout' {
  It 'Converts Default Pattern' {
    (Convert-PatternLayout).ToString() | Should -Be ([regex]'^(?<timestamp>\d+) \[(?<thread>\d+)\] (?<level>\w+) (?<logger>\w+) (?<ndc>\w+) - (?<message>.*)(?<newline>\n)$').ToString()
  }

  # For Testing you need to convert ToString.
  # Comparing two regex objects created at the same time in the same manner fails.

  Context "Format Modifiers" {
    It "Detects Left Pad" {
      (Convert-PatternLayout -PatternLayout '%20logger').ToString() | Should -Be ([regex]'^(?<logger>(?=.{20,}\b)\s*\w+)$').ToString()
    }
    It "Detects Right Pad" {
      (Convert-PatternLayout -PatternLayout '%-20logger').ToString() | Should -Be ([regex]'^(?<logger>(?=.{20,}\b)\w+\s*)$').ToString()
    }
    It "Detects Truncate" {
      (Convert-PatternLayout -PatternLayout '%.30logger').ToString() | Should -Be ([regex]'^(?<logger>(?=.{0,30}\b)\w+)$').ToString()
    }
    It "Detects Left Pad with Max" {
      (Convert-PatternLayout -PatternLayout '%20.30logger').ToString() | Should -Be ([regex]'^(?<logger>(?=.{20,30}\b)\s*\w+)$').ToString()
    }
    It "Detects Right Pad with Max" {
      (Convert-PatternLayout -PatternLayout '%-20.30logger').ToString() | Should -Be ([regex]'^(?<logger>(?=.{20,30}\b)\w+\s*)$').ToString()
    }
  }
}
