#*------v Function Touch-File v------
Function Touch-File {
    <#
    .SYNOPSIS
    Touch-File.ps1 - Approx *nix 'touch', create empty file if non-prexisting| update timestemp if exists.
    .NOTES
    Author: LittleBoyLost
    Website:	https://superuser.com/users/210235/littleboylost
    REVISIONS   :
    * 3/25/13 - posted version
    .DESCRIPTION
    .PARAMETER  File
    File [-file c:\path-to\file.ext]
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    None. Returns no objects or output.
    .EXAMPLE
    touch-file -file c:\tmp.txt ;
    Create a new file, or update timestamp of exising file
    .LINK
    https://superuser.com/questions/502374/equivalent-of-linux-touch-to-create-an-empty-file-with-powershell#
    #>
    [Alias('touch')]
    Param([Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "File [-file c:\path-to\file.ext]")]$File) ;
    if ($file -eq $null) { throw "No filename supplied" } ;
    if (Test-Path $file) { (Get-ChildItem $file).LastWriteTime = Get-Date } else { echo $null > $file } ;
} ; #*------^ END Function Touch-File ^------