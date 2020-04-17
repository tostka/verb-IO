#*------v Function Get-FolderSize() v------
function Get-FolderSize {
    <#
    .SYNOPSIS
    Gets the size of a folder.
    .NOTES
    Name: Get-FolderSize
    Author: Rich Kusak
    Versions:
    9:19 AM 9/2/2015 updated help
    Created: 2012-04-05
    2:53 PM 11/7/2014 tsk tweaked, to add SizeRaw, and pull spaces from property names
    Version: 1.0.0 2012-04-11 23:33
    .DESCRIPTION
    The Get-FolderSize function gets the size of a folder, any subfolders, and displays the number of files in each.
    .PARAMETER Folder
    Specifies the folder path.
    .PARAMETER SizeIn
    Specifies how the folder size is displayed. The Dynamic argument will display sizes in the most appropriate unit.
    Other supported arguments are B(Bytes), KB(KiloBytes), MB(MegaBytes), GB(GigaBytes), TB(TeraBytes), PB(PetaBytes).
    Default value: Dynamic
    .PARAMETER Recurse
    Gets the items in the specified locations and in all child items of the locations.
    This parameter is set to true by default.
    .PARAMETER Precision
    Specifies the folder size precision. By default the folder size is rounded to the nearest hundredth (2 decimal places).
    Changing this value slides the decimal place for more or less rounding precision. Valid arguments are 0-15.
    .PARAMETER Force
    Allows the function to get items that cannot otherwise not be accessed by the user, such as hidden or system files.
    .EXAMPLE
    Get-FolderSize
    Gets the folder size of the current location and any subfolders.
    .EXAMPLE
    Get-FolderSize -SizeIn MB
    Gets the folder size of the current location, any subfolders, and displays the size in megabytes.

    .EXAMPLE
    Get-FolderSize -SizeIn GB -Precision 5
    Gets the folder size of the current location, any subfolders, displays the size in gigabytes, and rounds the size to 5 decimal places.
    .EXAMPLE
    $env:USERPROFILE | Get-FolderSize -Recurse:$false
    Gets the folder size of the user profile location and disables recursion.
    .INPUTS
    System.String
    .OUTPUTS
    PSObject
    .LINK
    http://blogs.technet.com/b/heyscriptingguy/archive/2012/04/05/the-2012-scripting-games-advanced-event-4-determine-folder-space.aspx
    #>

    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateScript( {
                if (Test-Path -LiteralPath $_ -PathType Container) { $true } else {
                    throw "The argument '$_' is not a real path to a folder."
                }
            })]
        [Alias('FullName')]
        [string]$Folder = '.',

        [Parameter()]
        [ValidateSet('Dynamic', 'B', 'KB', 'MB', 'GB', 'TB', 'PB')]
        [string]$SizeIn = 'Dynamic',

        [Parameter()]
        [switch]$Recurse = $true,

        [Parameter()]
        [int]$Precision = 2,

        [Parameter()]
        [switch]$Force
    )

    begin {

        function Convert-FileSize {
            param (
                [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
                [double]$FileSize,

                [Parameter()]
                [ValidateSet('Dynamic', 'B', 'KB', 'MB', 'GB', 'TB', 'PB')]
                [string]$SizeIn,

                [Parameter()]
                [ValidateRange(0, 15)]
                [int]$Precision = 2
            )

            if ($SizeIn -eq 'Dynamic') {

                switch ($FileSize) {
                    $null { "0 Bytes" }
                    { ($_ -ge 1KB) -and ($_ -lt 1MB) } { "{0} KiloBytes" -f ([math]::Round($_ / 1KB, $Precision)) ; break }
                    { ($_ -ge 1MB) -and ($_ -lt 1GB) } { "{0} MegaBytes" -f ([math]::Round($_ / 1MB, $Precision)) ; break }
                    { ($_ -ge 1GB) -and ($_ -lt 1TB) } { "{0} GigaBytes" -f ([math]::Round($_ / 1GB, $Precision)) ; break }
                    { ($_ -ge 1TB) -and ($_ -lt 1PB) } { "{0} TeraBytes" -f ([math]::Round($_ / 1TB, $Precision)) ; break	}

                    { $_ -ge 1PB } { "{0} PetaBytes" -f ([math]::Round($_ / 1PB, $Precision)) ; break }
                    default { "{0} Bytes" -f $_ }
                } # switch
            }
            else {
                if ($SizeIn -eq 'B') {
                    $FileSize
                }
                else {
                    [math]::Round($FileSize / "1$SizeIn", $Precision)
                } ;
            }
        } # function Convert-FileSize

        $properties = 'Folder', 'SizeOfFolder', 'NumberOfFiles', 'SizeRaw'

    } # begin

    process {

        [PSObject[]]$directories = Get-Item -Path $Folder
        if ( (Get-ChildItem -Path $Folder -Directory).Length -gt 0 ) {

            $directories += Get-ChildItem -Path $Folder -Directory -Recurse:$Recurse -Force:$Force
        }

        foreach ($directory in $directories) {
            $files = Get-ChildItem -Path $directory.FullName -File -Force:$Force
            $size = $files | Measure-Object -Sum Length | Select-Object -ExpandProperty Sum

            New-Object -TypeName PSObject -Property @{
                'Folder'        = $directory.FullName
                'SizeOfFolder'  = Convert-FileSize -FileSize $size -SizeIn $SizeIn -Precision $Precision
                'NumberOfFiles' = $files.Count
                'SizeRaw'       = $size
            } | Select-Object -Property $properties
        } # foreach
    } # process

} #*------^ END Function Get-FolderSize() ^------