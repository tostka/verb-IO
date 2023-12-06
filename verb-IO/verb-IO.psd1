﻿#
# Module manifest for module 'verb-IO'
#
# Generated by: Todd Kadrie
#
# Generated on: 3/16/2020
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'verb-IO.psm1'

# Version number of this module.
ModuleVersion = '11.0.4'

# Supported PSEditions
# CompatiblePSEditions = @()

# ID used to uniquely identify this module
GUID = '12cb1eb4-ac9c-405e-8711-e80c914a9b32'

# Author of this module
Author = 'Todd Kadrie'

# Company or vendor of this module
CompanyName = 'toddomation.com'

# Copyright statement for this module
Copyright = '(c) 2020 Todd Kadrie. All rights reserved.'

# Description of the functionality provided by this module
Description = 'Powershell Input/Output generic functions module'

# Minimum version of the Windows PowerShell engine required by this module
# PowerShellVersion = ''

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = @('Add-ContentFixEncoding','Add-PSTitleBar','Authenticate-File','backup-FileTDO','check-FileLock','clear-HostIndent','Close-IfAlreadyRunning','ColorMatch','Compare-ObjectsSideBySide','Compare-ObjectsSideBySide3','Compare-ObjectsSideBySide4','Compress-ArchiveFile','convert-BinaryToDecimalStorageUnits','convert-ColorHexCodeToWindowsMediaColorsName','convert-DehydratedBytesToGB','convert-DehydratedBytesToMB','Convert-FileEncoding','ConvertFrom-CanonicalOU','ConvertFrom-CanonicalUser','ConvertFrom-CmdList','ConvertFrom-DN','ConvertFrom-IniFile','convertFrom-MarkdownTable','ConvertFrom-SourceTable','Null','True','False','_debug-Column','_mask','_slice','_typeName','_errorRecord','ConvertFrom-UncPath','convert-HelpToMarkdown','_encodePartOfHtml','_getCode','_getRemark','Convert-NumbertoWords','_convert-3DigitNumberToWords','ConvertTo-HashIndexed','convertTo-MarkdownTable','convertTo-Object','ConvertTo-SRT','ConvertTo-UncPath','convert-VideoToMp3','copy-Profile','Count-Object','Create-ScheduledTaskLegacy','dump-Shortcuts','Echo-Finish','Echo-ScriptEnd','Echo-Start','Expand-ArchiveFile','extract-Icon','Find-LockedFileProcess','Format-Json','get-AliasDefinition','Get-AverageItems','get-colorcombo','get-ColorNames','Get-CombinationTDO','Combination','Combination','ToString','Choose','Successor','Element','LargestV','ApplyTo2','ApplyTo','get-ConsoleText','Get-CountItems','Get-FileEncoding','Get-FileEncodingExtended','get-filesignature','Get-FileType','get-FolderEmpty','Get-FolderSize','Convert-FileSize','Get-FolderSize2','Get-FsoShortName','Get-FsoShortPath','Get-FsoTypeObj','get-HostIndent','get-LoremName','Get-PermutationTDO','Permutation','Permutation','Successor','Factorial','ApplyTo','ToString','Get-ProductItems','get-RegistryValue','Get-ScheduledTaskLegacy','Get-Shortcut','Get-SumItems','get-TaskReport','Get-Time','Get-TimeStamp','get-TimeStampNow','get-Uptime','Invoke-Flasher','Invoke-Pause','Invoke-Pause2','invoke-SoundCue','mount-UnavailableMappedDrives','move-FileOnReboot','New-RandomFilename','new-Shortcut','out-Clipboard','Out-Excel','Out-Excel-Events','parse-PSTitleBar','play-beep','pop-HostIndent','Pop-LocationFirst','prompt-Continue','push-HostIndent','Read-Host2','rebuild-PSTitleBar','Remove-AuthenticodeSignature','Remove-InvalidFileNameChars','Remove-InvalidVariableNameChars','remove-ItemRetry','Remove-JsonComments','Remove-PSTitleBar','Remove-ScheduledTaskLegacy','remove-UnneededFileVariants','repair-FileEncoding','replace-PSTitleBarText','reset-ConsoleColors','reset-HostIndent','restore-FileTDO','Run-ScheduledTaskLegacy','Save-ConsoleOutputToClipBoard','search-Excel','select-first','Select-last','Select-StringAll','set-ConsoleColors','Set-ContentFixEncoding','set-FileAssociation','set-HostIndent','set-ItemReadOnlyTDO','set-PSTitleBar','Set-RegistryValue','Set-Shortcut','Shorten-Path','Show-MsgBox','Sign-File','stop-driveburn','test-FileSysAutomaticVariables','test-IsLink','test-IsUncPath','test-LineEndings','test-MediaFile','test-MissingMediaSummary','Test-PendingReboot','Test-RegistryKey','Test-RegistryValue','Test-RegistryValueNotNull','test-PSTitleBar','Test-RegistryKey','Test-RegistryValue','Test-RegistryValueNotNull','Touch-File','trim-FileList','unless','write-HostIndent','Write-ProgressHelper')

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = '*'

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = '*'

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
FileList = @('Quick-Start-Installation-and-Example.md','test-MediaFile.jpg','CHANGELOG.md','LICENSE.txt','README.md')

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        # Tags = @()

        # A URL to the license for this module.
        # LicenseUri = ''

        # A URL to the main website for this project.
        # ProjectUri = ''

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        # ReleaseNotes = ''

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}



# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUd5aElzev2SHvDttBBWAInWKe
# t9ygggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdDAe
# Fw0xNDEyMjkxNzA3MzNaFw0zOTEyMzEyMzU5NTlaMBUxEzARBgNVBAMTClRvZGRT
# ZWxmSUkwgZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJAoGBALqRVt7uNweTkZZ+16QG
# a+NnFYNRPPa8Bnm071ohGe27jNWKPVUbDfd0OY2sqCBQCEFVb5pqcIECRRnlhN5H
# +EEJmm2x9AU0uS7IHxHeUo8fkW4vm49adkat5gAoOZOwbuNntBOAJy9LCyNs4F1I
# KKphP3TyDwe8XqsEVwB2m9FPAgMBAAGjdjB0MBMGA1UdJQQMMAoGCCsGAQUFBwMD
# MF0GA1UdAQRWMFSAEL95r+Rh65kgqZl+tgchMuKhLjAsMSowKAYDVQQDEyFQb3dl
# clNoZWxsIExvY2FsIENlcnRpZmljYXRlIFJvb3SCEGwiXbeZNci7Rxiz/r43gVsw
# CQYFKw4DAh0FAAOBgQB6ECSnXHUs7/bCr6Z556K6IDJNWsccjcV89fHA/zKMX0w0
# 6NefCtxas/QHUA9mS87HRHLzKjFqweA3BnQ5lr5mPDlho8U90Nvtpj58G9I5SPUg
# CspNr5jEHOL5EdJFBIv3zI2jQ8TPbFGC0Cz72+4oYzSxWpftNX41MmEsZkMaADGC
# AWAwggFcAgEBMEAwLDEqMCgGA1UEAxMhUG93ZXJTaGVsbCBMb2NhbCBDZXJ0aWZp
# Y2F0ZSBSb290AhBaydK0VS5IhU1Hy6E1KUTpMAkGBSsOAwIaBQCgeDAYBgorBgEE
# AYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwG
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSyVgFC
# wvtnFthncSFAbLtp1Ff5QDANBgkqhkiG9w0BAQEFAASBgB0/+Et4Hm+iF4aJNxa/
# WiVkrWfTl4S/H77pvKsp9k39xtkOfVAvEzcsXcc43aU8nNFCV1lynNHqNdSe4Uwb
# VeH82Hgxi8BeB2IzAsQA/0PFlPKhGJ7NWuoWU8aKt6ux7lokt4iBt9CZ54jx2pRI
# zWXHn+1CAwro0tYdE/lfPstX
# SIG # End signature block
