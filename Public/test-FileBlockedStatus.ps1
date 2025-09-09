# Test-FileBlockedStatus

#region TEST_FILEBLOCKEDSTATUS ; #*------v Test-FileBlockedStatus v------
Function Test-FileBlockedStatus {
    <#
    .SYNOPSIS
    Test-FileBlockedStatus - Tests files for 'Blocked' status by checking the ZoneIdentifier alternate data stream.
    .NOTES
    Version     : 0.0.1
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2025-09-09
    FileName    : Test-FileBlockedStatus
    License     : MIT License
    Copyright   : (c) 2025 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,FileSystem,Security,Block
    AddedCredit : REFERENCE
    AddedWebsite: URL
    AddedTwitter: URL
    REVISIONS
    * 4:19 PM 9/9/2025 init
    .DESCRIPTION
    Test-FileBlockedStatus - Tests files for 'Blocked' status by checking the ZoneIdentifier alternate data stream.
    This function inspects files to determine if they are marked as 'Blocked' by Windows.
    It checks for the presence of the ZoneIdentifier ADS and returns the full path of matching files.
    .PARAMETER Path
    The path to the file or directory to inspect. Accepts input from the pipeline.
    .INPUTS
    System.String
    .OUTPUTS
    System.String - Full path of files that are marked as 'Blocked'.
    .EXAMPLE
    PS> Get-ChildItem -Path "C:\Downloads" | Test-FileBlockedStatus
    .LINK
    https://learn.microsoft.com/en-us/windows/win32/shell/zone-identifiers
    .LINK
    https://github.com/tostka/verb-IO        
    #>
    [CmdletBinding()]
    PARAM (
[Parameter( Mandatory = $true, ValueFromPipeline = $true, HelpMessage = "Specify the path to the file or directory to inspect." )]         [ValidateNotNullOrEmpty()]
        [string]$Path
    ) 
    BEGIN {
        $ZoneIdentifierStream = 'Zone.Identifier'
        $BlockedZoneId = 3
    }
    PROCESS {
        TRY {
            $item = Get-Item -LiteralPath $Path -ErrorAction Stop
            # If it's a directory, enumerate files
            if ($item.PSIsContainer) {
                $files = Get-ChildItem -Path $item.FullName -File -Recurse -ErrorAction SilentlyContinue
            } else {
                $files = @($item)
            }
            foreach ($file in $files) {
                TRY {
                    $adsPath = "$($file.FullName):$ZoneIdentifierStream"
                    if (Test-Path -LiteralPath $adsPath) {
                        $zoneData = Get-Content -Path $adsPath -ErrorAction Stop | Out-String
                        if ($zoneData -match "ZoneId=$BlockedZoneId") {
                            Write-Output $file.FullName
                        }
                    }
                } CATCH {
                    Write-Warning "Failed to read ADS for '$($file.FullName)': $_"
                }
            }
        } CATCH {
            Write-Warning "Failed to process path '$Path': $_"
        }
    }
    END {
        # No cleanup needed
    }
}
#endregion TEST_FILEBLOCKEDSTATUS ; #*------^ END Test-FileBlockedStatus ^------