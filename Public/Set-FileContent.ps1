function Set-FileContent {
    <#
    .SYNOPSIS
    Set-FileContent - Write output string to specified File
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : https://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 8:28 PM 11/17/2019
    FileName    :
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka
    AddedCredit :
    AddedWebsite:
    AddedTwitter:
    REVISIONS
    * 10:44 AM 12/11/2019 updated example
    * 8:28 PM 11/17/2019 INIT
    .DESCRIPTION
    Set-FileContent - Write output string to specified File
    .PARAMETER  Text
    Text to be written to specified file
    .PARAMETER  Path
    Path to target output file
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .PARAMETER Whatif
    Parameter to run a Test no-change pass [-Whatif switch]
    .EXAMPLE
    $bRet = Set-FileContent -Text $updatedContent -Path $outfile -showdebug:$($showdebug) -whatif:$($whatif) ;
    if (!$bRet) {throw "FAILURE" } ;
    .LINK
    #>

    PARAM(
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "Text to be written to specified file [-Path path-to\file.ext]")]
        [ValidateNotNullOrEmpty()]$Text,
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "Path to script[-Path path-to\script.ps1]")]
        [ValidateNotNullOrEmpty()]$Path,
        [Parameter(HelpMessage = "Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage = "Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    ) ;

    $Exit = 0 ;
    $pltSetContent=[ordered]@{
        Path = $Path ;
        whatif = $($whatif) ;
        ErrorAction="Stop" ;
    } ;
    Do {
        Try {
            $text | set-Content @pltSetContent ;
            $true | write-output
            $Exit = $Retries ;
        }
        Catch {
            $ErrorTrapped = $Error[0] ;
            Write-Verbose "Failed to exec cmd because: $($ErrorTrapped)" ;
            $pltSetContent.add('force',$true) ;
            Start-Sleep -Seconds $RetrySleep ;
            # reconnect-exo/reconnect-ex2010
            $Exit ++ ;
            Write-Verbose "Adding -force. Try #: $Exit" ;
            If ($Exit -eq $Retries) {
                Write-Warning "Unable to exec cmd!" ;
                $false | write-output ;
            } ;
        }  ;
    } Until ($Exit -eq $Retries) ;
}
