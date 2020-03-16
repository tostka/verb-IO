function Get-Shortcut {
    <#
    .SYNOPSIS
    Get-Shortcut() - Reads the attributes of a shortcut
    .NOTES
    Author: Kevin Marquette
    Website:	https://github.com/KevinMarquette/PesterInAction/blob/master/4%20Module/Demo/functions/Get-Shortcut.ps1
    REVISIONS   :
    * 9:05 AM 8/29/2017 updated pshelp, put into OTB format
    *  Nov 8, 2015 posted version
    .DESCRIPTION
    Get-Shortcut() - Reads the attributes of a shortcut
    PARAMETER Path
    Path to a target .lnk file
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    Returns an objects summarizing each processed .lnk file, to the pipeline
    .EXAMPLE
    Get-Shortcut -Path .\shortcut.lnk ;
    Pull attribs of .lnk file
    .EXAMPLE
    ls *.lnk | Get-Shortcut ;
    Demos pipeline support for bulk processing
    .EXAMPLE
    gci "$($env:appdata)\Microsoft\Internet Explorer\Quick Launch\*.lnk" -recur | get-shortcut |?{$_.TargetPath -like 'C:\sc\batch\BatScripts\*'} | fl fullname,targetpath ;
    Search all .lnk files in QuickLaunch tree, for TargetPath in specific dir, and return the FullName of the .lnk file
    .LINK
    https://github.com/kmarquette/PesterInAction/blob/master/4%20Module/Demo/functions/Get-Shortcut.ps1
    #>
    [cmdletbinding()]
    param([Parameter( Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]$Path) ;
    begin {
        $WScriptShell = New-Object -ComObject WScript.Shell
    } ;
    process {
        foreach ($node in $Path) {
            if (Test-Path $node) {
                $Shortcut = $WScriptShell.CreateShortcut((Resolve-Path $node)) ;
                Write-Output $Shortcut ;
            } ;
        } ;
    } ;
}
