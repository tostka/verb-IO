# Read-InputBoxChoice.ps1

#*------v Function Read-InputBoxChoice v------
function Read-InputBoxChoice {
    <#
    .SYNOPSIS
    Read-InputBoxChoice - Prompt offering multiple selection options to users (uses `$host.ui). 
    .NOTES
    Version     : 0.0.1
    Author      : Iris K
    Website     : https://techadviz.com/author/iriskim000/
    Twitter     : 
    CreatedDate : 2024-05-11
    FileName    : Read-InputBoxChoice.ps1
    License     : (none asserted)
    Copyright   : (none asserted)
    Github      : https://github.com/tostka/verb-Network
    Tags        : Powershell,Input,Prompt
    AddedCredit : Todd Kadrie
    AddedWebsite: http://www.toddomation.com
    AddedTwitter: @tostka / http://twitter.com/tostka
    REVISIONS   :
    * 4:45 PM 5/10/2024 rounded 3 line demo out into complete function; 
    * 1/29/22 Iris K posted demo
    .DESCRIPTION
    Read-InputBoxChoice - Prompt offering multiple selection options to users (uses `$host.ui)

    Rounded out from bare bones demo by Iris K.

    .PARAMETER WindowTitle
    Title of the prompt window[-WindowTitle 'Title']
    .PARAMETER Message
    Prompt text shown above textbox and below title box[-Message 'Strings']
    .PARAMETER DefaultText
    Optional semple text to be pre-populated into the input box[-DefaultText 'Apple']
    .PARAMETER ChoiceLabels
    Label strings to be used on each choice (specify string array, one per desired label)[-ChoiceLabels 'Spring','Summer','Fall','Winter']
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    System.Object
    .EXAMPLE
    PS> $picked = Read-InputBoxChoice -WindowTitle 'Travel Planning' -Message 'Choose By Season : ' -ChoiceLabels 'Spring','Summer','Fall','Winter' ; 
    PS> write-host "Chose: $($picked)" ; 
    .LINK
    https://blog.danskingdom.com/powershell-multi-line-input-box-dialog-open-file-dialog-folder-browser-dialog-input-box-and-message-box/  
    https://github.com/tostka/verb-IO
    #>
    # [Alias('gclr')]
    [CmdletBinding()]
    Param(
        [Parameter(HelpMessage = "Title of the prompt window[-WindowTitle 'Title']")]
            [string]$WindowTitle,
        [Parameter(HelpMessage = "Prompt text shown above textbox and below title box[-Message 'Strings']")]
            [string]$Message,
        [Parameter(HelpMessage = "Label strings to be used on each choice (specify string array, one per desired label)[-ChoiceLabels 'Spring','Summer','Fall','Winter']")]
            [string[]]$ChoiceLabels
    )
    $res = $host.ui.PromptForChoice($WindowTitle, $Message, $ChoiceLabels, 0)
    return $ChoiceLabels[$res]
} ;
#*------^ END Function Read-InputBoxChoice ^------
