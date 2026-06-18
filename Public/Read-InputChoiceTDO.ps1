# Read-InputChoiceTDO.ps1

#region READ_INPUTCHOICETDO ; #*------v Read-InputChoiceTDO v------
#if(-not (gcm Read-InputChoiceTDO -ea 0)){
    function Read-InputChoiceTDO {
        <#
        .SYNOPSIS
        Read-InputChoiceTDO - Prompts the user with console-based option list and returns the item they specify. Directly emulates Powershell's native prompts.
        .NOTES
        Version     : 0.0.2
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 2026-06-17
        FileName    : Read-InputChoiceTDO.ps1
        License     : (none asserted)
        Copyright   : (none asserted)
        Github      : https://github.com/tostka/verb-IO
        Tags        : Powershell,Input,Prompt,Console
        AddedCredit : Adam Bertram
        AddedWebsite: https://4sysops.com/archives/author/adam-bertram/
        AddedTwitter: URL        
        REVISIONS   :
        * 5:29 PM 6/17/2026 init vers
        .DESCRIPTION
        Read-InputChoiceTDO - Prompts the user with console-based option list and returns the item they specify. Directly emulates Powershell's native prompts.
        
        Inspired by Adam Bertram's blog post: 
        
        [Read-Host and the ChoiceDescription class – Prompt for user input in PowerShell – 4sysops - 4sysops.com/](https://4sysops.com/archives/read-host-and-the-choicedescription-class-prompt-for-user-input-in-powershell/)

        Dynamically a custom selection menu using the .NET System.Management.Automation.Host.ChoiceDescription object.        

        The default returned value is the 'Tag', with any ampersand's replaced. 
        If an entry isn't a semi-colon-delimited list, an integer value is used as the Tag, and the specified string is used as both the HelpMessage and the return value

        .PARAMETER Options
        Array of Options: Each should be a semi-colon-delimited 'tag;HelpMessage' string: The Tag can have an Ampersand(&) accelerator key[-options @('&Red;Favorite color: Red','&Blue;Favorite color: Blue','&Yellow;Favorite color: Yellow')]
        .PARAMETER Title
        Title string to be displayed
        .PARAMETER message
        Message to be displayed[-Mesage 'Please select a destination path]
        .PARAMETER defaultItem
        INT default selection from -options[-DefaultItem 1]
        .PARAMETER ReturnInteger
        Optional switch to return the user-entered integer rather than the resolved entry from the Options list[-ReturnInteger]
        .INPUTS
        Does not accept piped input
        .OUTPUTS
        System.String
        .EXAMPLE
        PS> $Options = @('&Red;Favorite color: Red','&Blue;Favorite color: Blue','&Yellow;Favorite color: Yellow')
        PS> $Answer = Read-InputChoiceTDO -options $Options -title 'Faviorite color' -Message 'Pick your favorite color' -DefaultItem 1 

            Faviorite color
            Pick your favorite color
            [R] Red  [B] Blue  [Y] Yellow  [?] Help (default is "Y"): r

        PS> $Answer
                Red

        Demo console option prompt, demonstrating answer if 1st item was chosen, under default behavior (which returns resolved Options entry)        
        .EXAMPLE
        PS> $Options = @('Red','Blue','Yellow') ; 
        PS> $Answer = Read-InputChoiceTDO -options $Options -title 'Faviorite color' -Message 'Pick your favorite color' -DefaultItem 2

            Faviorite color
            Pick your favorite color
            [0] 0:Red  [1] 1:Blue  [2] 2:Yellow  [?] Help (default is "2"): 1

        PS> $Answer

                Blue

        Demo menu using simple string options, without tags, which autoconverts to integer number selections. 
        .LINK
        https://github.com/tostka/verb-IO
        #>
        [Alias('Read-InputChoice')]
        [CmdletBinding()]
        Param(
            [Parameter(Position=0,Mandatory=$True,HelpMessage="Array of Options: Each should be a semi-colon-delimited 'tag;HelpMessage' string: The Tag can have an Ampersand(&) accelerator key[-options @('&Red;Favorite color: Red','&Blue;Favorite color: Blue','&Yellow;Favorite color: Yellow')]")]
                [array]$Options,
            [Parameter(Position=1,HelpMessage="Title string to be displayed[-Title 'Favorite color']")]
                [Alias('WindowTitle')]
                [string]$Title,
            [Parameter(Position=1,HelpMessage="Message to be displayed[-Mesage 'Please pick your favorite color']")]            
                [string]$message,
            [Parameter(Position=2,HelpMessage="INT default selection from -options[-DefaultItem 1]")]
                [int]$defaultItem,
            [Parameter(HelpMessage="Optional switch to return the chosedn item ordinal integer rather than the resolved entry from the Options list[-ReturnInteger]")]
                [switch]$ReturnInteger
        ) ;
        BEGIN{
            $i = 0
            $mnuOpts = @() ; 
            $mnuValues = @() ; 
            foreach($Opt in $options){
                if($Opt.contains(';')){
                    $mnuTag,$mnuHelpMsg = $Opt.split(';')
                    $mnuValues += @($MnuTag -replace '&','')
                }else{
                    $mnuTag = "&$($i):$($Opt)" ; 
                    $mnuHelpMsg = $Opt
                    $mnuValues += @($mnuHelpMsg)
                } ;                 
                $mnuOpts += New-Object System.Management.Automation.Host.ChoiceDescription $mnuTag, $mnuHelpMsg ; 
                $i++ ; 
            } ; 
            $mnuOptions = [System.Management.Automation.Host.ChoiceDescription[]]($mnuOpts)
        }
        PROCESS{
            $menuSelect = $host.ui.PromptForChoice($title, $message, $mnuOptions, $defaultItem)
        } ;  # PROC-E
        END{
            
            if($ReturnInteger){
                $menuSelect | write-output
            }else{
                $mnuValues[$menuSelect] | write-output
            } ;
        }  # END-E
    } ;
#}
#endregion READ_INPUTCHOICETDO ; #*------^ END Read-InputChoiceTDO ^------
