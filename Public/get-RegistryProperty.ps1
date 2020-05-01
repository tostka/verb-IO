#*------v Function get-RegistryProperty v------
function get-RegistryProperty {
    <#
    .SYNOPSIS
    get-RegistryProperty - Retrieve and return a registry key
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2020-05-01
    FileName    : 
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell,Registry,Maintenance
    REVISIONS
    * 10:13 AM 5/1/2020 init vers
    .DESCRIPTION
    get-RegistryProperty - Retrieve and return a registry key
    .PARAMETER  Path
    Registry path to target key to be updated[-Path 'HKCU:\Control Panel\Desktop']
    .PARAMETER Name
    Registry property to be updated[-Name AutoColorization]
    .PARAMETER Value
    Value to be set on the specified 'Name' property [-Value 0]
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .OUTPUT
    System.Object[]
    .EXAMPLE
    $RegValue = get-RegistryProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'AutoColorization' -Value 0 ; 
    Return the desktop AutoColorization property value (silent)
    .EXAMPLE
    $RegValue = get-RegistryProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'AutoColorization' -Value 0 -verbose ; 
    Return the desktop AutoColorization property value with verbose output
    .LINK
    https://github.com/tostka
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True,HelpMessage = "Registry property to be updated[-Name AutoColorization]")]
        [ValidateNotNullOrEmpty()][string]$Name,
        [Parameter(Mandatory = $True,HelpMessage = "Registry path to target key to be updated[-Path 'HKCU:\Control Panel\Desktop']")]
        [ValidateNotNullOrEmpty()][string]$Path,
        [Parameter(Mandatory = $True,HelpMessage = "Value to be set on the specified 'Name' property [-Value 0]")]
        [ValidateNotNullOrEmpty()][string]$Value,
        [Parameter(HelpMessage = "Debugging Flag [-showDebug]")]
        [switch] $showDebug
    ) ;
    ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
    $PSParameters = New-Object -TypeName PSObject -Property $PSBoundParameters ;
    $Verbose = ($VerbosePreference -eq 'Continue') ; 
    $error.clear() ;
    TRY {
        $pltReg=[ordered]@{
            Path = $Path ;
            Name = $Name ;
            Value = $Value ;
            whatif=$($whatif) ;
        } ;
        $RegValue = Get-ItemProperty -path $pltReg.path -name $pltReg.name| select -expand $pltReg.name ; 
        write-verbose -Verbose:$Verbose  "$((get-date).ToString('HH:mm:ss')):Value queried:$($pltReg.Path)\`n$($pltReg.Name):`n$(($RegValue|out-string).trim())" ;
        $RegValue | write-output ; 
    } CATCH {
        $ErrTrpd = $_ ; 
        Write-Warning "$(get-date -format 'HH:mm:ss'): Failed processing $($ErrTrpd.Exception.ItemName). `nError Message: $($ErrTrpd.Exception.Message)`nError Details: $($ErrTrpd)" ;
        $false | write-output ; 
    } ; 
} ;#*------^ END Function get-RegistryProperty ^------ ; 
