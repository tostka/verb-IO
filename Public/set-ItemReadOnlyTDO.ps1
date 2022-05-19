#*------v Function set-ItemReadOnlyTDO v------
function set-ItemReadOnlyTDO {
    <#
    .SYNOPSIS
    set-ItemReadOnlyTDO.ps1 - Set an item Readonly
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	https://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2:23 PM 12/29/2019
    FileName    :
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    REVISIONS
    * 3:43 PM 5/19/2022 init
    .DESCRIPTION
    set-ItemReadOnlyTDO.ps1 - Set an item Readonly
    .PARAMETER  Path
    Path to backup file to be restored
    .PARAMETER Clear
    Switch to 'clear' IsReadOnly item property (e.g. set writable)[-Clear]
    .PARAMETER Whatif
    Parameter to run a Test no-change pass [-Whatif switch]
    .INPUT
    Accepts pipeline input
    .OUTPUT
    System.Object
    .EXAMPLE
    PS> $bRet = set-ItemReadOnlyTDO -path "C:\sc\verb-dev\verb-dev\verb-dev.psm1_20191229-0904AM"  -whatif:$($whatif)
    PS> if (-not $bRet.IsReadOnly -and -not $whatif) {throw "FAILURE" } ;
    Set specified path IsReadOnly
    .EXAMPLE
    PS> $bRet = set-ItemReadOnlyTDO -path "C:\sc\verb-dev\verb-dev\verb-dev.psm1_20191229-0904AM"  -Clear -whatif:$($whatif)
    PS> if ($bRet.IsReadOnly -and -not $whatif) {throw "FAILURE" } ;
    Clear specified path IsReadOnly setting (set to $false)
    .LINK
    https://github.com/tostka/verb-io
    #>
    [CmdletBinding()]
    #[Alias('')]
    PARAM(
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "Path to item[-Path path-to\file.ext]")]
        [ValidateScript( { Test-Path $_ })]
        [Alias('Source')]
        [string[]]$Path,
        [Parameter(HelpMessage = "Switch to 'clear' IsReadOnly item property (e.g. set writable)[-Clear]")]
        [switch] $Clear,
        [Parameter(HelpMessage = "Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    ) ;
    BEGIN{
        ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
        #$PSParameters = New-Object -TypeName PSObject -Property $PSBoundParameters ;
        write-verbose "`$PSBoundParameters:`n$(($PSBoundParameters|out-string).trim())" ;
        $Verbose = ($VerbosePreference -eq 'Continue') ;
        $smsg = $sBnr="#*======v $(${CmdletName}):$(-not $Clear) v======" ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
        else{ write-verbose $smsg } ;
        if ($PSCmdlet.MyInvocation.ExpectingInput) {
            write-verbose "Data received from pipeline input: '$($InputObject)'" ;
        } else {
            #write-verbose "Data received from parameter input: '$($InputObject)'" ;
            write-verbose "(non-pipeline - param - input)" ;
        } ;
        $Procd = 0 ;
    } # BEG-E
    PROCESS{
        foreach($item in $path) {
            $Procd++ ;
            $bSetReadOnly = $bIsReadOnly = $false ; 
            Try {
                if ($item.GetType().FullName -ne 'System.IO.FileInfo') {
                    $item = get-childitem -path $item ;
                } ;
                $sBnrS = "`n#*------v ($($Procd)):$($item.fullname) v------" ;
                $smsg = "$($sBnrS)" ;
                if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }  #Error|Warn|Debug
                else{ write-verbose $smsg } ; } ;

                if((get-itemproperty -Path $Item.fullname).IsReadOnly){
                    $bIsReadOnly = $true ;
                } else {
                    $bIsReadOnly = $false
                } ; 
                write-verbose "$($Item.fullname):IsReadonly:$($bIsReadOnly)" ; 
                $pltSIp = [ordered]@{
                    path = $item.fullname ;
                    Name ='IsReadOnly' ;
                    Value = $null;
                    ErrorAction = 'STOP' ;
                    PassThru = $true ; 
                    whatif = $($whatif) ;
                } ;
                if( -not $Clear -AND -not $bIsReadOnly){
                    $smsg = "IsReadOnly:$($bIsReadOnly):Setting IsReadOnly:$true" ; ; 
                    $bSetReadOnly= $true ; 
                    $pltSIp.Value = $true ;
                } elseif( -not $Clear -AND $bIsReadOnly){
                    $smsg = "$($Item.fullname) is *already* Readonly" ; 
                    $pltSIp.Value = $null ;
                } elseif( $Clear -AND -not $bIsReadOnly){
                    $smsg = "$($Item.fullname) is *already* -NOT Readonly" ; 
                    $pltSIp.Value = $null
                } elseif( $Clear -AND $bIsReadOnly){
                    $bSetReadOnly= $false ; 
                    $pltSIp.Value = $false ;
                } else { 
                    $smsg = "unrecognized parameter combo!" ; 
                    write-warning $smsg 
                    break ; 
                } ; 
            } Catch {
                $ErrorTrapped = $Error[0] ;
                Write-Warning "Failed to exec cmd because: $($ErrorTrapped)" ;
                Start-Sleep -Seconds $RetrySleep ;
                # reconnect-exo/reconnect-ex2010
                $Exit ++ ;
                Write-Warning "Try #: $Exit" ;
                If ($Exit -eq $Retries) { Write-Warning "Unable to exec cmd!" } ;
            }  ;
            
            if($pltSIp.Value -eq $null ){
                # no action
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }  #Error|Warn|Debug
                else{ write-host -foregroundcolor green $smsg } ;
            } else {
                # if value $true|$false: update the value
                $smsg = "IsREADONLY:Set-ItemProperty w`n$(($pltSIp|out-string).trim())" ;
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }  #Error|Warn|Debug
                else{ write-host -foregroundcolor green $smsg } ;
                $Exit = 0 ;
                Do {
                    $error.clear() ;
                    Try {
                        $oReturn = Set-ItemProperty @pltSIp ; 
                        $oReturn | write-output ; 
                        $Exit = $Retries ;
                    } Catch {
                        $ErrorTrapped = $Error[0] ;
                        Write-Verbose "Failed to exec cmd because: $($ErrorTrapped)" ;
                        Start-Sleep -Seconds $RetrySleep ;
                        # reconnect-exo/reconnect-ex2010
                        $Exit ++ ;
                        Write-Verbose "Try #: $Exit" ;
                        If ($Exit -eq $Retries) { Write-Warning "Unable to exec cmd!" } ;
                    }  ;
                } Until ($Exit -eq $Retries) ;
            } ; 
            $smsg = "$($sBnrS.replace('-v','-^').replace('v-','^-'))" ;
            if($verbose){ if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
            else{ write-verbose $smsg } ; } ;
        }   # loop-E
    } ;  # E PROC
    END{
         $smsg = $sBnr.replace('=v','=^').replace('v=','^=') ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
        else{ write-verbose $smsg } ;
    }
} ;
#*------^ END Function set-ItemReadOnlyTDO ^------