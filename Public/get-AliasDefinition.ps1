#*------v get-AliasDefinition.ps1 v------
Function get-AliasDefinition {
    <#
    .SYNOPSIS
    get-AliasDefinition.ps1 - Returns alias with matching specified definition (Tired of typing |? where definition -eq 'xxx' ; can it up in a function). Has alias 'gald' (variant of the get-alias: gal alias).
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2022-04-29
    FileName    : get-AliasDefinition.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka/verb-IO
    Tags        : PowershellConsole
    REVISIONS
    * 8:31 AM 4/29/2022init vers
    .DESCRIPTION
    get-AliasDefinition.ps1 - Returns alias with matching specified definition (Tired of typing get-alias |? where definition -eq 'xxx' ; can it up in a function). Has alias 'gald' (variant of the get-alias: gal alias).
    Base params on: new-alias -Name -Value
    .PARAMETER Value <System.String>
    Specifies the name of the cmdlet or command that the alias runs. The Value parameter is the alias's Definition property.
    .OUTPUT
    System.Management.Automation.CommandInfo
    .EXAMPLE
    get-AliasDefinition -value 'select-string'
    Find the Alias for the 'select-string' cmdlet.
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [Alias('gald')]
    [CmdletBinding()]
    Param (
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,HelpMessage="Specifies the name of the cmdlet or command that the alias runs. The Value parameter is the alias's Definition property. [-value 'select-string']")]
        [ValidateNotNullOrEmpty()]
        [Alias('Definition')]
        [string]$Value
    )
    $smsg += "Locate existing alias for Value (Definition):$($value)" ;
    write-verbose $smsg  ;
    # use oldest supported where syntax, for largest backward compat.
    get-alias | ?{$_.Definition -eq $value} | write-output ;
} ; 
#*------^ get-AliasDefinition.ps1 ^------