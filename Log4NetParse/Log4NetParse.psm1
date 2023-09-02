# Dot source public/private functions
$enums = @(Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Enums/*.ps1') -Recurse -ErrorAction Stop)
$classes = @(Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Classes/*.ps1') -Recurse -ErrorAction Stop)
$public  = @(Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Public/*.ps1')  -Recurse -ErrorAction Stop)
$private = @(Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Private/*.ps1') -Recurse -ErrorAction Stop)
foreach ($import in @($enums + $classes + $public + $private)) {
    try {
        . $import.FullName
    } catch {
        throw "Unable to dot source [$($import.FullName)]"
    }
}

# Add our custom formatter that needed classes first
#$format = Join-Path -Path $PSScriptRoot -ChildPath 'Log4NetLogLine.format.ps1xml'
#Update-FormatData -PrependPath $format
#$format = Join-Path -Path $PSScriptRoot -ChildPath 'Log4NetLog.format.ps1xml'
#Update-FormatData -PrependPath $format

Export-ModuleMember -Function $public.Basename
