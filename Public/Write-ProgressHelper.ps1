#*------v Write-ProgressHelper v------
function Write-ProgressHelper {
    <#
    .SYNOPSIS
    Write-ProgressHelper - Dynamically scaling static Write-Progress function. 
    .NOTES
    Version     : 1.0.0.0
    Author      : Adam Bertram
    Website     :	https://adamtheautomator.com/building-progress-bar-powershell-scripts/
    Twitter     :	
    CreatedDate : 2020-08-10
    FileName    : Write-ProgressHelper
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-IO
    AddedCredit : Todd Kadrie
    AddedWebsite: http://www.toddomation.com
    AddedTwitter: @tostka / http://twitter.com/tostka
    REVISIONS
    * 11:17 AM 8/26/2020 added CBH, added supp for balance of write-progress params, ren'd orig $Message -> underlying $Status param. Example demo'ing more-flexible splat use
    * 18 June 2019 posted vers
    .DESCRIPTION
    Write-ProgressHelper - Dynamically scaling static Write-Progress function. 
    Leverages the parser to count the number of write-progress's in the current script, and uses each execucution to calculate completion percentage. Replaces hard-coded percentages per write-progress. 
    .PARAMETER StepNumber
    Number of current step, (1,2,3...)[-StepNumber 1]
    .PARAMETER Message
    String to be displayed as the write-progress '-Status' [-Message 'StepDescriptiOn']
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    None. 
    .EXAMPLE
    # dyn tally # of write-prog instances in curr $MyInvocation
    $script:steps = ([System.Management.Automation.PsParser]::Tokenize((gc "$PSScriptRoot\$($MyInvocation.MyCommand.Name)"), [ref]$null) | where { $_.Type -eq 'Command' -and $_.Content -eq 'Write-ProgressHelper' }).Count ; 
    # splat to hold the static write-progress params
    $pltWPH=@{
        Activity = "BROAD ACTIVITY" ;
        CurrentOperation = "Querying..." ;
    };
    $iStep = 0 ; # counter to be incremented ea write-progress exec
    Write-ProgressHelper @pltWPH -Status 'DOING SOMETHING' -StepNumber ($iStep++) ;
    ## SOME PROCESS HERE
    Write-ProgressHelper @pltWPH -Status 'DOING SOMETHING2' -StepNumber ($iStep++) ;
    Above displays a two-step Write-Progress bar, dynamically scaling the progress & total around the number of 'write-progress' cmdlets present in the $MyInvocation
    .LINK
    https://adamtheautomator.com/building-progress-bar-powershell-scripts/
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(Mandatory=$True,HelpMessage="Number of current step, (1,2,3...)[-StepNumber 1]")]
        [int]$StepNumber,
        [Parameter(Mandatory=$True,HelpMessage="String to be displayed as the write-progress '-Activity' [-Message 'StepDescriptiOn']")]
        [string]$Activity,
        [Parameter(Mandatory=$True,HelpMessage="String to be displayed as the write-progress '-CurrentOperation' [-Message 'StepDescriptiOn']")]
        [string]$CurrentOperation,
        [Parameter(Mandatory=$True,HelpMessage="String to be displayed as the write-progress '-Status' [-Message 'StepDescriptiOn']")]
        [string]$Status
    ) ;
    BEGIN {
        #${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
        # Get parameters this function was invoked with
        #$PSParameters = New-Object -TypeName PSObject -Property $PSBoundParameters ;
    } ;
    PROCESS {
        Write-Progress -Activity:$($Activity) -Status:$($Status) -CurrentOperation:$($CurrentOperation) -PercentComplete (($StepNumber / $steps) * 100) ; 
    } ; 
    END{} ;
} ; 
#*------^ Write-ProgressHelper ^------