# Test-FileBlockedStatus

    #region TEST_FILEBLOCKEDSTATUSTDO ; #*------v Test-FileBlockedStatusTDO v------
    Function Test-FileBlockedStatusTDO {
        <#
        .SYNOPSIS
        Test-FileBlockedStatusTDO - Tests files for 'Blocked' status by checking the ZoneIdentifier alternate data stream.
        .NOTES
        Version     : 0.0.1
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 2025-09-09
        FileName    : Test-FileBlockedStatusTDO
        License     : MIT License
        Copyright   : (c) 2025 Todd Kadrie
        Github      : https://github.com/tostka/verb-io
        Tags        : Powershell,FileSystem,Security,Block
        AddedCredit : REFERENCE
        AddedWebsite: URL
        AddedTwitter: URL
        REVISIONS
        * 6:02 PM 9/11/2025 flipped pipeline output to fileinfo object, vs string fullname (unblock won't pipeline process the string, doers the object) ; 
            ren'd Test-FileBlockedStatus -> Test-FileBlockedStatusTDO, aliased orig name
        * 4:56 PM 9/9/2025 Test-FileBlockedStatusTDO():revised: error workaround: $adsPath = "$($file.FullName):$ZoneIdentifierStream"; test-Path -LiteralPath $adsPath ;  init
        .DESCRIPTION
        Test-FileBlockedStatusTDO - Tests files for 'Blocked' status by checking the ZoneIdentifier alternate data stream.
        This function inspects files to determine if they are marked as 'Blocked' by Windows.
        It checks for the presence of the ZoneIdentifier ADS and returns the full path of matching files.
        GUI alt is Explorer file > Properties: displays:
        'This file came from another computer and might be blocked to help protect this computer [ ] Unblock'
        .PARAMETER Path
        The path to the file or directory to inspect. Accepts input from the pipeline.
        .INPUTS
        System.String
        .OUTPUTS
        System.String - Full path of files that are marked as 'Blocked'.
        .EXAMPLE
        PS> Get-ChildItem -Path "C:\Downloads" | Test-FileBlockedStatusTDO
        .EXAMPLE
        PS> gci d:\cab\* -include @('*.ps1','*.psm1')  | Test-FileBlockedStatusTDO | Unblock-File -verbose ;    
        .LINK
        https://learn.microsoft.com/en-us/windows/win32/shell/zone-identifiers
        .LINK
        https://github.com/tostka/verb-IO        
        #>
        [CmdletBinding()]
        [Alias('Test-FileBlockedStatus')]
        PARAM (
            [Parameter( Mandatory = $true, ValueFromPipeline = $true, HelpMessage = "Specify the path to the file or directory to inspect." )]         
                [ValidateNotNullOrEmpty()]
                [string]$Path
        ) 
        BEGIN {
            $ZoneIdentifierStream = 'Zone.Identifier'
            $BlockedZoneId = 3
            $rgxZoneID = [regex]::Escape("ZoneId=$($BlockedZoneId)")
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
                        #if(Get-Item $file.FullName -Stream "Zone.Identifier" -ErrorAction SilentlyContinue){
                        if(Get-Item $file.FullName -Stream $ZoneIdentifierStream -ErrorAction SilentlyContinue){
                            $smsg = "$($file.fullname) has  Stream $($ZoneIdentifierStream)" ; 
                            #if(Get-Content $file.FullName -Stream "Zone.Identifier" |?{$_ -match 'ZoneId=3'}){
                            if(Get-Content $file.FullName -Stream "Zone.Identifier" |?{$_ -match $rgxZoneID}){                            
                                $smsg = "$($smsg) and matches $($rgxZoneID.tostring()):  isBLOCKED" ;
                                if($VerbosePreference -eq "Continue"){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
                                else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
                                #$file.FullName | write-output ; # unblock-file won't take the fullname string properly via pipeline (throws Unblock-File : The input object cannot be bound to any parameters for the command either because the command does not take pipeline input or the input and its properties do not match any of the parameters that take pipeline input.)
                                # drop the fileinfo object into the pipe
                                $file | write-output ; 
                            } else { 
                                $smsg = "$($smsg) and NOTmatches $($rgxZoneID.tostring())': isUNBLOCKED" ; 
                                if($VerbosePreference -eq "Continue"){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
                                else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;       
                            } ; 
                        } else { 
                            $smsg = "$($file.fullname) has NO Stream $($ZoneIdentifierStream): isUNBLOCKED" ; 
                            if($VerbosePreference -eq "Continue"){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
                            else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;       
                        } ;  
                    
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
    #endregion TEST_FILEBLOCKEDSTATUSTDO ; #*------^ END Test-FileBlockedStatusTDO ^------
    