# block-fileTDO.ps1

    #region BLOCK_FILETDO ; #*------v block-fileTDO v------
    Function block-fileTDO {
        <#
        .SYNOPSIS
        block-fileTDO - Mock up a conterpart for Microsoft.PowerShell.Utility\unblock-file(), that sets a 'Block'; adding a ZoneIdentifier alternate data stream to designated file
        .NOTES
        Version     : 0.0.1
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 2025-09-09
        FileName    : block-fileTDO
        License     : MIT License
        Copyright   : (c) 2025 Todd Kadrie
        Github      : https://github.com/tostka/verb-io
        Tags        : Powershell,FileSystem,Security,Block
        AddedCredit : REFERENCE
        AddedWebsite: URL
        AddedTwitter: URL
        REVISIONS
        * 11:13 AM 9/11/2025 init, creating for testing of test-fileblockstatusTDO() & unblock-file in dynamic iflv code
        .DESCRIPTION
        block-fileTDO - Mock up a conterpart for Microsoft.PowerShell.Utility\unblock-file(), that sets a 'Block'; adding a ZoneIdentifier alternate data stream to designated file
        .PARAMETER Path
        Specifies the files to block. Wildcard characters are supported.[-path c:\pathto\file.ext]
        .PARAMETER LiteralPath
        Specifies the files to block. Unlike Path , the value of the LiteralPath parameter is used exactly as it is typed. No characters are interpreted as wildcards. If the path includes escape characters, enclose it in single quotation marks (`'`). Single quotation marks tell PowerShell not to interpret anycharacters as escape sequences. [-LiteralPath c:\pathto\file.ext]
        .PARAMETER Force
        Force (Confirm-override switch, overrides ShouldProcess testing, executes somewhat like legacy -whatif:`$false)[-force]        
        .INPUTS
        System.String
        .OUTPUTS
        System.String - Full path of files that are marked as 'Blocked'.
        .EXAMPLE
        PS> Get-ChildItem -Path "C:\Downloads" | block-fileTDO
        .EXAMPLE
        PS> gci d:\cab\* -include @('*.ps1','*.psm1')  | block-fileTDO | Unblock-File -verbose ;    
        .LINK
        https://learn.microsoft.com/en-us/windows/win32/shell/zone-identifiers
        .LINK
        https://github.com/tostka/verb-IO        
        #>
        [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'HIGH')] 
        [Alias('Block-File')]
        PARAM(
            [Parameter(Mandatory = $False,Position = 0,ValueFromPipeline = $True, HelpMessage = "Specifies the files to block. Wildcard characters are supported.[-path c:\pathto\file.ext]")]
                #[Alias('PsPath')]
                #[ValidateScript({Test-Path $_ -PathType 'Container'})]
                #[ValidateScript({Test-Path $_})]
                [string[]]$Path,
            [Parameter(HelpMessage="Specifies the files to block. Unlike Path , the value of the LiteralPath parameter is used exactly as it is typed. No characters are interpreted as wildcards. If the path includes escape characters, enclose it in single quotation marks (`'`). Single quotation marks tell PowerShell not to interpret anycharacters as escape sequences. [-LiteralPath c:\pathto\file.ext]")]
                [String[]]$LiteralPath,
            [Parameter(HelpMessage="Force (Confirm-override switch, overrides ShouldProcess testing, executes somewhat like legacy -whatif:`$false)[-force]")]
                [switch]$Force
            #[Parameter(HelpMessage="Shows what would happen if the cmdlet runs. The cmdlet is not run.[-whatIf]")]
            #    [switch] $whatIf
            # when using SupportsShouldProcess, $whatif & $Confirm are automatic, manual def of either throws: get-help : A parameter with the name 'WhatIf' was defined multiple times for the command.
        )
        BEGIN {
            if(-not $Path -AND -not $LiteralPath){
                $smsg = "NEITHER -Path or -LiteralPath specified: Please specify one or the other." ; 
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} 
                else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                throw $smsg ; 
                break ; 
            } ; 
            if($Path -AND $LiteralPath){
                $smsg = "BOTH -Path & -LiteralPath specified: Please specify one or the other." ; 
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} 
                else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                throw $smsg ; 
                break ; 
            } ; 
            $ZoneIdentifierStream = 'Zone.Identifier'
            $BlockedZoneId = 3
            #$data = "[ZoneTransfer]`nZoneId=3" ; 
            $data = "[ZoneTransfer]`nZoneId=$($BlockedZoneId)" ; 
        }
        PROCESS {
            if($Path){ $thisitem = $Path}
            elseif($LiteralPath){$thisitem = $LiteralPath}
            else{
                $smsg = "NEITHER -Path or -LiteralPath specified: Please specify one or the other." ; 
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} 
                else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                throw $smsg ; 
                break ; 
            } 
            foreach($titem in $thisitem){
                TRY {
                    $pltGCI = @{ErrorAction = 'SilentlyContinue'}
                    $pltDo = @{Stream = "Zone.Identifier" ;Value = $data ;ErrorAction = 'Stop'}
                    # If it's a directory, enumerate files
                    if ($item.PSIsContainer) {                        
                        $pltGCI.add('Recurse',$true) ; 
                        $pltGCI.add('File',$true ) ;
                        if ($LiteralPath) {
                            $pltGCI.add('LiteralPath',$titem.FullName ) ; 
                                                       
                        }else{
                            $pltGCI.add('Path',$titem.FullName ) ;                            
                        } ; 
                        $smsg = "Get-ChildItem w`n$(($pltGCI|out-string).trim())" ; 
                        if($VerbosePreference -eq "Continue"){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
                        else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
                        $files = Get-ChildItem @pltGCI ; 
                    } else {
                        $files = @($titem)
                    }
                    foreach ($file in $files) {
                        if ($LiteralPath) {
                            $pltDo.add('LiteralPath',$titem )                        
                        }else{
                            $pltDo.add('Path',$titem )
                        } ;
                        $smsg = "set-Content w`n$(($pltDo|out-string).trim())" ; 
                        if($VerbosePreference -eq "Continue"){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
                        else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
                        if ($Force -or $PSCmdlet.ShouldProcess($titem, 'set-Content: Should Process?')) {
                            TRY{
                                set-Content @pltDo ;   
                            } CATCH {
                                $ErrTrapd=$Error[0] ;
                                $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
                                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            } ;
                        } elseif($whatifpreference.IsPresent){
                            #$smsg = "This code execs on -whatif (run no-impact perms/deps tests etc here)" ;
                            #if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE} else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                        } else {;
                            $smsg = "(DECLINED ShouldProcess PROMPT! (NON -whatif))" ;
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Prompt }
                            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                        } ;                   
                    }
                } CATCH {
                    $ErrTrapd=$Error[0] ;
                    $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                }
            } ;  # loop-E
        }
        END {
            # No cleanup needed
        }
    }
    #endregion BLOCK_FILETDO ; #*------^ END block-fileTDO ^------
