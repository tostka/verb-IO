# Remove-Alias_func.ps1

#region REMOVE_ALIASTDO ; #*------v Remove-AliasTDO v------
function Remove-AliasTDO {    
    <#
    .SYNOPSIS
    Remove-AliasTDO - Remove a configured alias.
    .NOTES
    Version     : 0.0.2
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2026-04-29
    FileName    : set-RDPFileSignatureTDO.ps1
    License     : MIT License
    Copyright   : (c) 2026 Todd Kadrie
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell,Alias,Maintenance
    AddedCredit : neilpa
    AddedWebsite: https://github.com/neilpa/dotfiles/blob/master/powershell/profile.ps1
    AddedTwitter: URL
    * 10:15 AM 8/6/2026 add explicit -path param to remove-item, was throwing  "A parameter cannot be found that matches parameter name 'alias'."
    * 9:38 AM 8/4/2026 it didn't't support pipeline, empty alias cause it to chase \ root alias: add AdvFunc & pipeline support 
    .DESCRIPTION
    Remove-AliasTDO - Remove a configured alias.
    Microsoft.PowerShell.Utility has verb's for 'Export|Get|Import|New|Set', but no REMOVE
    So build our own. Note: in most cases it's safer to use the native remove-item alias:xxx approach (in example) - doesen't rely on this function to be available.
    To override some existing aliases with alias functions we have to remove them
    adapted from: https://github.com/neilpa/dotfiles/blob/master/powershell/profile.ps1
    .PARAMETER Name
    Specifies the alias Name. You can use any alphanumeric characters in an alias, but the first character cannot be a number.
    .INPUTS
    Accepts piped input Path 
    .OUTPUTS
    None
    .EXAMPLE
    .EXAMPLE
    PS> remove-item -path alias:MyAlias
    Demo native removal using base features of Microsoft.Powershell.Utility mod
    .EXAMPLE
    PS> get-alias XX | %{remove-item -path alias:$_ -verbose }
    Rough in logic of this function using just the using base features of Microsoft.Powershell.Utility mod
    .LINK
    https://github.com/tostka/verb-io
    #>
    [CmdletBinding()]
    [Alias('remove-alias','ral')]
    PARAM(
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,HelpMessage="Specifies the alias Name. You can use any alphanumeric characters in an alias, but the first character cannot be a number.")]
        [System.String]$Name
    ) ; 
    PROCESS{
        foreach($item in $Name){
            Remove-Item -path alias:$item -Force -ErrorAction SilentlyContinue 
        } ; 
    } ; 
} ; 
#endregion REMOVE_ALIASTDO ; #*------^ END Remove-AliasTDO ^------