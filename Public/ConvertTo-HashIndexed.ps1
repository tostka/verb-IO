#*------v Function ConvertTo-HashIndexed v------
Function ConvertTo-HashIndexed {
    <#
    .SYNOPSIS
    ConvertTo-HashIndexed.ps1 - Converts the inbound object/array/table into an indexed-hash on the specified key/property.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2020-
    FileName    : 
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-IO
    Tags        : Powershell
    REVISIONS
    * 12:49 PM 11/17/2020 init using this alot, so port it to a func()
    .DESCRIPTION
    ConvertTo-HashIndexed.ps1 - Converts the inbound object/array/table into an indexed-hash on the specified key/property.
    .PARAMETER  Object
    Object to be converted[-Object `$object]
    .PARAMETER  Key
    Key/property to be indexed upon[-Key 'propertyName]
    .PARAMETER  ShowProgress
    Switch, when ShowProgress in use, as to how many items should process between 'dots' in the crawl[-Every 50]
    .PARAMETER  Every
    ShowProgress dot crawl interval (# of processed objects each dot should represent)[-Every 50]
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    None. Returns no objects or output
    .EXAMPLE
    ray/CSV/etc...
    $Key = 'PrimarySmtpAddress' ; 
    $Object = $AllEXOMbxs ; 
    $Output  = ConvertTo-HashIndexed -Key $key -Object $Object -showprogress ;
    $smsg = "ConvertTo-HashIndexed object type Changes:`n" ; 
    $smsg += "original `$Object.type:$( $Object.GetType().FullName )`n" ; 
    $smsg += "converted `$Output .type:$( $Output.GetType().FullName )`n" ; 
    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    #How to lookup objects in the Object
    $searchvalue = 'email@domain.com' ; 
    $output[$searchvalue] ;
    #Or by property name
    $output.'email@domain.com' ;
    #Demo orig object props are still inteact in converted indexed-hashtable
    $output[$lookupVal] | Get-Member ;
    $output.Values | Get-Member ;
    Convert specified $Object into an indexed hash and demo access, output object types, and converted properties
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true,HelpMessage="Object to be converted[-Object `$object]")]
        [ValidateNotNullorEmpty()]$Object,
        [Parameter(Mandatory=$true,HelpMessage="Key/property to be indexed upon[-Key 'propertyName]")]
        [ValidateNotNullorEmpty()]$Key,
        [Parameter(Mandatory=$false,HelpMessage="Switch to display dot-crawl progress[-ShowProgress 'propertyName]")]
        [switch]$ShowProgress,
        [Parameter(Mandatory=$false,HelpMessage="ShowProgress dot crawl interval (# of processed objects each dot should represent)[-Every 50]")]
        [int]$Every = 100  
    ) ; 
    $verbose = ($VerbosePreference -eq "Continue") ; 
    $ttl = ($Object|measure).count ; 
    $smsg = "(converting $($ttl) items into indexed hash)..." ; 
    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    $sw = [Diagnostics.Stopwatch]::StartNew();
    $Hashtable = @{}
    $Procd = 0 ; 
    if($ShowProgress){write-host -NoNewline "`n[" ; $Procd = 0 } ; 
    Foreach ($Item in $Object){
        $Procd++ ; 
        $Hashtable[$Item.$Key.ToString()] = $Item ; 
        if($ShowProgress -AND ($Procd -eq $Every)){
            write-host -NoNewline '.' ; $Procd = 0 
        } ; 
    } ; 
    if($ShowProgress){write-host "]`n" ; $Procd = 0 } ; 
    $sw.Stop() ;
    $smsg = "($($ttl) items converted in $($sw.Elapsed.ToString()))" ; 
    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    $Hashtable | write-output ; 
} 
#*------^ END Function ConvertTo-HashIndexed ^------