﻿#*------v Function test-FileLock v------
function test-FileLock {
    <#
    .SYNOPSIS
    test-FileLock - Check for lock status on a file
    .NOTES
    Version     : 1.0.1
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2020-11-23
    FileName    : test-FileLock.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-IO
    Tags        : Powershell,FileSystem,File,Lock
    AddedCredit : Henri Benoit (StreamReader error on lock)
    AddedWebsite: https://benohead.com/blog/2014/12/08/powershell-check-whether-file-locked/
    REVISIONS
    * 10:32 AM 7/23/2024 ren std verb: check-FileLock -> test-FileLock, alias orig name
    * 11:30 AM 11/23/2020 minor updates, reformated into fuunc
    * 12/8/14 posted version
    .DESCRIPTION
    .PARAMETER  Path
    Path to file[-path 'c:\pathto\file.txt'
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    System.Boolean
    .EXAMPLE
    PS> test-FileLock -path 'c:\pathto\file.txt' 
    Check lock status on specified file
    .EXAMPLE
    PS> if(test-FileLock -path $file){
    PS>     $smsg = "($file) is currently *LOCKED*!`nQueuing DELETION on next reboot." ; 
    PS>     write-warning $smsg ;
    PS>     move-FileOnReboot -path $file ;
    PS> } else { 
    PS>     TRY {remove-item -path $file} 
    PS>     CATCH {
    PS>         $smsg = "Failed processing $($_.Exception.ItemName). `nError Message: $($_.Exception.Message)`nError Details: $($_)" ;
    PS>         write-warning $smsg ;
    PS>     } ; 
    PS> } ; 
    Expanded demo of use with verb-IO:move-FileOnReboot()
    .LINK
    https://github.com/tostka/verb-io
    #>
    [CmdletBinding()]
    [Alias('check-FileLock')]
    PARAM(
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Path to file[-path 'c:\pathto\file.txt']")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({Test-Path $_})]
        $Path
    ) ;
    BEGIN { $Verbose = ($VerbosePreference -eq 'Continue') } ;
    PROCESS {
        $Error.Clear() ; 
        Write-verbose "(Checking lock on file: $path)" ;
        $LockedFile = $false ; 
        $file = get-item (Resolve-Path $path) -Force ;
        if ($file.exists){
            TRY{
              $stream = New-Object system.IO.StreamReader $file ;
              if ($stream) {$stream.Close()} ; 
            } catch {$LockedFile = $true } ; 
        } ;
    } ;  # PROC-E
    END { $LockedFile | write-output } ; 
} ;
#*------^ END Function test-FileLock ^------
