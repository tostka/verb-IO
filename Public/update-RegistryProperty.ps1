#*------v Function update-RegistryProperty v------
function update-RegistryProperty {
    <#
    .SYNOPSIS
    update-RegistryProperty - Update a registry key, dump the pre/post values
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
    update-RegistryProperty - Update a registry key, dump the pre/post values
    .PARAMETER  Path
    Registry path to target key to be updated[-Path 'HKCU:\Control Panel\Desktop']
    .PARAMETER Name
    Registry property to be updated[-Name AutoColorization]
    .PARAMETER Value
    Value to be set on the specified 'Name' property [-Value 0]
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .PARAMETER Whatif
    Parameter to run a Test no-change pass [-Whatif switch]
    .OUTPUT
    System.Object[]
    .EXAMPLE
    update-RegistryProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'AutoColorization' -Value 0
    Update the desktop AutoColorization property to the value 0 
    .EXAMPLE
    update-RegistryProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'AutoColorization' -Value 0 -verbose
    Update the desktop AutoColorization property to the value 0 with verbose detailed pre/post output
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
        [switch] $showDebug,
        [Parameter(HelpMessage = "Whatif Flag  [-whatIf]")]
        [switch] $whatIf
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
        write-verbose -Verbose:$Verbose  "$((get-date).ToString('HH:mm:ss')):PRE:$($pltReg.Path)\`n$($pltReg.Name):$((Get-ItemProperty -path $pltReg.path -name $pltReg.name| select -expand $pltReg.name|out-string).trim())" ;
        write-verbose -Verbose:$Verbose "$((get-date).ToString('HH:mm:ss')):Set-ItemProperty w`n$(($pltReg|out-string).trim())" ;
        Set-ItemProperty @pltReg;
        write-verbose -Verbose:$Verbose  "$((get-date).ToString('HH:mm:ss')):POST:$($pltReg.Path)\`n$($pltReg.Name):$((Get-ItemProperty -path $pltReg.path -name $pltReg.name| select -expand $pltReg.name|out-string).trim())" ;
        $true | write-output ; 
    } CATCH {
        $ErrTrpd = $_ ; 
        Write-Warning "$(get-date -format 'HH:mm:ss'): Failed processing $($ErrTrpd.Exception.ItemName). `nError Message: $($ErrTrpd.Exception.Message)`nError Details: $($ErrTrpd)" ;
        $false | write-output ; 
    } ; 
} ;#*------^ END Function update-RegistryProperty ^------ ;