# This module is combined. Any code in this file as added to the very end.


# Add our custom formatters
@(
  'Log4NetLogLine.format.ps1xml',
  'Log4NetLog.format.ps1xml'
) | ForEach-Object {
  Update-FormatData -PrependPath (Join-Path -Path $PSScriptRoot -ChildPath $_)
}

# Define the types to export with type accelerators.
$ExportableTypes = @(
  [LogLevel]
  [Log4NetLog]
  [Log4NetLogLine]
)
# Get the internal TypeAccelerators class to use its static methods.
$TypeAcceleratorsClass = [psobject].Assembly.GetType(
  'System.Management.Automation.TypeAccelerators'
)
# Ensure none of the types would clobber an existing type accelerator.
# If a type accelerator with the same name exists, throw an exception.
$ExistingTypeAccelerators = $TypeAcceleratorsClass::Get
foreach ($Type in $ExportableTypes) {
  if ($Type.FullName -in $ExistingTypeAccelerators.Keys) {
    $Message = @(
      "Unable to register type accelerator '$($Type.FullName)'"
      'Accelerator already exists.'
    ) -join ' - '

    throw [System.Management.Automation.ErrorRecord]::new(
      [System.InvalidOperationException]::new($Message),
      'TypeAcceleratorAlreadyExists',
      [System.Management.Automation.ErrorCategory]::InvalidOperation,
      $Type.FullName
    )
  }
}
# Add type accelerators for every exportable type.
foreach ($Type in $ExportableTypes) {
  [void]$TypeAcceleratorsClass::Add($Type.FullName, $Type)
}
# Remove type accelerators when the module is removed.
$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
  foreach ($Type in $ExportableTypes) {
    [void]$TypeAcceleratorsClass::Remove($Type.FullName)
  }
}.GetNewClosure()
