#*------v Function Set-RegistryValue v------
function Set-RegistryValue {
    <#
    .SYNOPSIS
    Set-RegistryValue - Update a registry key, dump the pre/post values (pre-tests for key & property, creates when needed)
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2020-05-01
    FileName    : Set-RegistryValue.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell,Registry,Maintenance
    REVISIONS
    * 12:45 PM 2/21/2023 ren'd update-RegistryProperty -> Set-RegistryValue (aliased w set-RegistryProperty); found, comparing to verb-io\update-RegistryProperty, that it's grown new params and support for creation of new pre non-existant properties; splicing over to verb-io, with new alias: update-Registryproperty (rename the verb-io ver, set(add/update) makes more sense than update-); updated the test and logic a bit. 
    * 10:13 AM 5/1/2020 init vers
    .DESCRIPTION
    Set-RegistryValue - Update a registry key, dump the pre/post values
      -PropertyType
  Specifies the type of property that this cmdlet adds. The acceptable values for this parameter are:
      String: Specifies a null-terminated string. Equivalent to REG_SZ.
      ExpandString: Specifies a null-terminated string that contains unexpanded references to environment variables that are expanded when the value is retrieved. Equivalent to REG_EXPAND_SZ.
      Binary: Specifies binary data in any form. Equivalent to REG_BINARY.
      DWord: Specifies a 32-bit binary number. Equivalent to REG_DWORD.
      MultiString: Specifies an array of null-terminated strings terminated by two null characters. Equivalent to REG_MULTI_SZ.
      Qword: Specifies a 64-bit binary number. Equivalent to REG_QWORD.
      Unknown: Indicates an unsupported registry data type, such as REG_RESOURCE_LIST.
    .PARAMETER  Path
    Registry path to target key to be updated[-Path 'HKCU:\Control Panel\Desktop']
    .PARAMETER Name
    Registry property to be updated[-Name AutoColorization]
    .PARAMETER Value
    Value to be set on the specified 'Name' property [-Value 0]
    .PARAMETER PropertyType
    For Name property that doesn't pre-exist, registry PropertyType to be used to create new property (String|ExpandString|Binary|DWord|MultiString|Qword|Unknown), defaults DWORD [-PropertyType DWORD]"
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .PARAMETER Whatif
    Parameter to run a Test no-change pass [-Whatif switch]
    .OUTPUT
    System.Object[]
    .EXAMPLE
    Set-RegistryValue -Path 'HKCU:\Control Panel\Desktop' -Name 'AutoColorization' -Value 0
    Update the desktop AutoColorization property to the value 0
    .EXAMPLE
    Set-RegistryValue -Path 'HKCU:\Control Panel\Desktop' -Name 'AutoColorization' -Value 0 -verbose
    Update the desktop AutoColorization property to the value 0 with verbose detailed pre/post output
    .EXAMPLE
    Set-RegistryValue -Path 'HKCU:\Control Panel\Desktop' -Name 'AutoColorization' -Value 0 -PropertyType DWORD -verbose
    Update the desktop AutoColorization property to the value 0 with verbose detailed pre/post output, if property needs to be created, specifies DWORD propertytype.
    .LINK
    https://github.com/tostka
    #>
    [CmdletBinding()]
    [Alias('update-RegistryProperty','set-RegistryProperty')]
    PARAM(
        [Parameter(Mandatory = $True, HelpMessage = "Registry property to be updated[-Name AutoColorization]")]
        [ValidateNotNullOrEmpty()][string]$Name,
        [Parameter(Mandatory = $True, HelpMessage = "Registry path to target key to be updated[-Path 'HKCU:\Control Panel\Desktop']")]
        [ValidateNotNullOrEmpty()][string]$Path,
        [Parameter(Mandatory = $True, HelpMessage = "Value to be set on the specified 'Name' property [-Value 0]")]
        [ValidateNotNullOrEmpty()][string]$Value,
        [Parameter(HelpMessage = "For Name property that doesn't pre-exist, registry PropertyType to be used to create new property (String|ExpandString|Binary|DWord|MultiString|Qword|Unknown), defaults DWORD [-PropertyType DWORD]")]
        [ValidatePattern("(String|ExpandString|Binary|DWord|MultiString|Qword|Unknown)")]
        [string]$PropertyType = 'DWORD',
        [Parameter(HelpMessage = "Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage = "Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    ) ;
    $error.clear() ;
    TRY {
        $pltReg = @{
            Path   = $Path ;
            Name   = $Name ;
            Value  = $Value ;
            Force  = $true ; 
            ErrorAction = 'Stop' ; 
            whatif = $($whatif) ;
        } ;
        $RegistryValue = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue ; 
        if ($RegistryValue -ne $null) {
            write-verbose -Verbose:$Verbose              write-verbose -Verbose:$Verbose "$((get-date).ToString('HH:mm:ss')):Set-ItemProperty w`n$(($pltReg|out-string).trim())" ;
            Set-ItemProperty @pltReg;
        } else { 
            if (-not(Test-Path -Path $Path)) {
                $pltNew = @{
                    Path   = $Path ;
                    ItemType = 'Directory' ;
                    Force  = $true ;
                    ErrorAction = 'Stop' ; 
                    whatif = $($whatif) ;
                    
                } ;
                write-verbose -Verbose:$Verbose "$((get-date).ToString('HH:mm:ss')):create Missing Key:New-Item w`n$(($pltNew|out-string).trim())" ;
                New-Item @pltNew | Out-Null ; 
            }
            New-ItemProperty @pltReg -PropertyType $PropertyType -Force | Out-Null
        } ;
        # return the updated value ; 
        Get-ItemProperty -path $path -name $name| select -expand $name | write-output ; 
    } CATCH {
        $ErrTrpd = $_ ;
        Write-Warning -Message "Failed to create or update registry value '$($Name)' in '$($Path)'. Error message: $($ErrTrpd.Exception.Message)" ; 
        $false | write-output ;
    } ;
} ; #*------^ END Function Set-RegistryValue ^------ ;
