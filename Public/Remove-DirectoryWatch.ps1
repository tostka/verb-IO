#*------v Function Remove-DirectoryWatch v------
Function Remove-DirectoryWatch {
    <#
    .SYNOPSIS
    Remove-DirectoryWatch - Monitoring Folders for File Changes
    .NOTES
    Version     : 0.1.0
    Author      : Dr. Tobias Weltner
    Website     : https://powershell.one/tricks/filesystem/filesystemwatcher
    Twitter     : 
    CreatedDate : 11/3/19 20191103
    FileName    : Remove-DirectoryWatch.ps1
    License     : Attribution-NoDerivatives 4.0 International https://creativecommons.org/licenses/by-nd/4.0/
    Copyright   : (none asserted)
    Github      : https://github.com/tostka/NupkgDownloader
    Tags        : Powershell,NuPackage,Chocolatey,Package
    AddedCredit : Todd Kadrie
    AddedWebsite: http://www.toddomation.com
    AddedTwitter: @tostka / http://twitter.com/tostka
    REVISIONS
    * 12:05 PM 1/12/2024 forked rossobianero copy under NuPkgDownloader: Aliased funcs to reflect inconsist names in other bundled functions; 
        expand CBH; 
    * 6/9/23 rossobianero posted version
    .DESCRIPTION
    Remove-DirectoryWatch - Downloads a NUPKG and dependencies from Azure DevOps artifacts using NUGET

    Bundled with NuPkgDownloader by rossobianero

    Source post intro:
    [Monitoring Folders for File Changes - powershell.one](https://powershell.one/tricks/filesystem/filesystemwatcher)

    # Monitoring Folders for File Changes

    With a **FileSystemWatcher**, you can monitor folders for file changes and respond immediately when changes are detected. This way, you can create “drop” folders and respond to log file changes.

    The **FileSystemWatcher** object can monitor files or folders and notify **PowerShell** when changes occur. It can monitor a single folder or include all subfolders, and there is a variety of filters.
    
    
    .PARAMETER Path
    Folder to be watched for changes[-path c:\path-to\]
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    None. Returns no objects or output 
    .EXAMPLE
    PS> $watcherObject = Add-DirectoryWatch -Path $($tempDirectory.FullName) ;
    PS> write-host 'Change!' ; 
    PS> Remove-DirectoryWatch -WatcherObject $watcherObject ; 
    Add WatcherObject on specified path, and store the object in the $WatcherObject variable; wait for a change; and then use the matching Remove-DirectoryWatch to remove the watcher.
    .LINK
    https://github.com/tostka/NupkgDownloader
    .LINK
    https://github.com/rossobianero/NupkgDownloader
    #>
    [CmdletBinding()]
    [Alias('Unwatch-Directory')]
    Param([Parameter(Mandatory=$true)][object]$WatcherObject)


    $watcher = $WatcherObject.Watcher;
    $handlers = $WatcherObject.Handlers;

    # stop monitoring
    $watcher.EnableRaisingEvents = $false
    
    # remove the event handlers
    $handlers | ForEach-Object {
        Unregister-Event -SourceIdentifier $_.Name
    }
    
    # event handlers are technically implemented as a special kind
    # of background job, so remove the jobs now:
    $handlers | Remove-Job
    
    # properly dispose the FileSystemWatcher:
    $watcher.Dispose()
    
    Write-Progress -Activity "Download" -PercentComplete 100
}
#*------^ END Function Remove-DirectoryWatch ^------