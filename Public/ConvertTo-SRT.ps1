#*------v ConvertTo-SRT.ps1 v------
function ConvertTo-SRT {
    <#
    .SYNOPSIS
    ConvertTo-SRT.ps1 - Fast conversion of Microsoft Stream VTT subtitle file to SRT format.
    .NOTES
    Version     : 1.0.0
    Author      : joegasper
    Website     :	https://gist.github.com/joegasper/3fafa5750261d96d5e6edf112414ae18
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-12-15
    FileName    :
    License     : (not specified)
    Copyright   : (not specified)
    Github      : https://github.com/tostka/verb-IO
    Tags        : Powershell,ActiveDirectory,DistinguishedName,CanonicalName,Conversion
    AddedCredit : Todd Kadrie
    AddedWebsite:	http://www.toddomation.com
    AddedTwitter:	@tostka / http://twitter.com/tostka
    Inspiration from: https://gist.github.com/brianonn/455bce106bd86c9587d223acfbbe9751/
Takes a 3.5 minute process for 17K row VTT to 3.5 seconds

https://github.com/joegasper
https://gist.github.com/joegasper/e862f71b5a2658fae21fd36f7231b33c
    REVISIONS
    * 1:35 PM 4/25/2022 psv2 explcit param property =$true; regexpattern w single quotes.
    * 4:30 PM 12/15/2020 TSK: expanded CBH,
    .DESCRIPTION
    Uses select-string instead of get-content to improve speed 2 magnitudes.
    .PARAMETER Path
    Specifies the path to the VTT text file (mandatory).
    .PARAMETER OutFile
    Specifies the path to the output SRT text file (defaults to input file with .srt).
    .EXAMPLE
    ConvertTo-SRT -Path .\caption.vtt
    .EXAMPLE
    ConvertTo-SRT -Path .\caption.vtt -OutFile .\SRT\caption.srt
    .EXAMPLE
    Get-Item caption*.vtt | ConvertTo-SRT
    .EXAMPLE
    ConvertTo-SRT -Path ('.\caption.vtt','.\caption.vtt','.\caption3.vtt')
    .EXAMPLE
    ('.\caption.vtt','.\caption2.vtt','.\caption3.vtt') | ConvertTo-SRT
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Path to VTT file.")]
        [Alias("PSPath")]
        [ValidateNotNullOrEmpty()]
        [Object[]]$Path,

        [Parameter(Mandatory = $false,
            Position = 1,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Path to output SRT file.")]
        [string]$OutFile
    )

    process {
        foreach ($File in $Path) {
            $Lines = @()
            if ( $File.FullName ) {
                $VTTFile = $File.FullName
            }
            else {
                $VTTFile = $File
            }

            if ( -not($PSBoundParameters.ContainsKey('OutFile')) ) {
                $OutFile = $VTTFile -replace '(\.vtt$|\.txt$)', '.srt'
                if ( $OutFile.split('.')[-1] -ne 'srt' ) {
                    $OutFile = $OutFile + '.srt'
                }
            }

            New-Item -Path $OutFile -ItemType File -Force | Out-Null
            $Subtitles = Select-String -Path $VTTFile -Pattern '(^|\s)(\d\d):(\d\d):(\d\d)\.(\d{1,3})' -Context 0, 2

            for ($i = 0; $i -lt $Subtitles.count; $i++) {
                $Lines += $i + 1
                $Lines += $Subtitles[$i].line -replace '\.', ','
                $Lines += $Subtitles[$i].Context.DisplayPostContext
                $Lines += ''
            }

            $Lines | Out-File -FilePath $OutFile -Append -Force
        }
    }
}

#*------^ ConvertTo-SRT.ps1 ^------
