# Read-InputConsoleChoiceTDO.ps1

#region TDO ; #*------v Read-InputConsoleChoiceTDO v------
#if(-not (gcm Read-InputConsoleChoiceTDO -ea 0)){
    function Read-InputConsoleChoiceTDO {
        <#
        .SYNOPSIS
        Read-InputConsoleChoiceTDO - Prompts the user with console-based Option listand returns the item they specify, or null if they cancelled the prompt.
        .NOTES
        Version     : 0.0.2
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 2026-06-17
        FileName    : Read-InputConsoleChoiceTDO.ps1
        License     : (none asserted)
        Copyright   : (none asserted)
        Github      : https://github.com/tostka/verb-IO
        Tags        : Powershell,Input,Prompt,Console
        AddedCredit : igge_iggelito
        AddedWebsite: https://www.reddit.com/r/PowerShell/comments/10gn8rc/section_of_script_which_allows_user_to_input_an/
        AddedTwitter: URL
        AddedCredit : Redog
        AddedWebsite: https://www.reddit.com/r/PowerShell/comments/10gn8rc/section_of_script_which_allows_user_to_input_an/
        AddedTwitter: URL
        REVISIONS   :
        * 10:34 AM 6/18/2026 added demo of alt to out-gridview -passthru ; fixed typo in defaultitem handling
        * 2:33 PM 6/17/2026 ADDED pipeline support ; CBH ; ren a-choose -> Read-InputConsoleChoiceTDO
        * 10/16/23 - redog posted vers
        .DESCRIPTION
        Read-InputConsoleChoiceTDO - Prompts the user with console-based Option listand returns the item they specify, or null if they cancelled the prompt.
        Adapted/expanded from sample code from
        https://www.reddit.com/r/PowerShell/comments/10gn8rc/section_of_script_which_allows_user_to_input_an/
        in comments by Redog & igge_iggelito.

        .PARAMETER options
        List of Options to be listed and selection returned[-options @('A','B','C')]
        .PARAMETER defaultItem
        INT default selection from -options[-DefaultItem 1]
        .PARAMETER ReturnInteger
        Optional switch to return the user-entered integer rather than the resolved entry from the Options list[-ReturnInteger]
        .INPUTS
        Accepts piped input.
        .OUTPUTS
        System.String
        .EXAMPLE
        PS> $AList = @("Red","Green","Blue")
        PS> $Answer = Read-InputConsoleChoiceTDO -options $AList

            ==SELECT:
            0: Red
            1: Green
            2: Blue
        PS> $Answer
                Green

        Demo console option prompt, demonstrating answer if 2nd item was chosen, under default behavior (which returns resolved Options entry)
        .EXAMPLE
        PS> $AList = @("Red","Green","Blue")
        PS> $Answer = Read-InputConsoleChoiceTDO -options $AList -ReturnInteger
        PS> $Answer
                3

        Demo console option prompt, demonstrating answer if 2nd item was chosen, with -returninteger specified (which returns user-entered integer)
        .EXAMPLE
        PS> $LocalGitRepoPaths = @(
        PS> 'C:\sc\powershell\EXOScripts',
        PS> 'C:\sc\powershell\ExScripts',
        PS> 'C:\sc\powershell\MergerScripts',
        PS> 'C:\sc\powershell\PSProfileUID',
        PS> 'C:\sc\powershell\PSScripts',
        PS> 'C:\sc\powershell\TenMigrScripts',
        PS> ) ;
        PS> $LocalDestination = $LocalGitRepoPaths | Read-InputConsoleChoiceTDO -WindowTitle 'Select Destination LocalDestination path'

                ==Select Destination LocalDestination path:
                  [0]	C:\sc\powershell\EXOScripts
                  [1]	C:\sc\powershell\ExScripts
                  [2]	C:\sc\powershell\MergerScripts
                  [3]	C:\sc\powershell\PSProfileUID
                  [4]	C:\sc\powershell\PSScripts
                  [5]	C:\sc\powershell\TenMigrScripts  
                ==Select Destination LocalDestination path: [Default: C:\sc\powershell\EXOScripts ] 3

        PS> $LocalDestination

                C:\sc\powershell\PSProfileUID

        Demo 
        .EXAMPLE
        PS> if($psise.IsPreviewRelease -eq $true){
        PS>     [String]$LocalDestination = $LocalGitRepoPaths | 
        PS>         Read-InputConsoleChoiceTDO -Message 'Select Destination LocalDestination path' #-ChoiceLabels $LocalGitRepoPaths ;                         
        PS> }else{
        PS>     [String]$LocalDestination = $LocalGitRepoPaths |  
        PS>         Out-GridView -Passthru -Title 'Select Destination LocalDestination path' ; 
        PS> } ; 
        Demo use as an alt to out-gridview -passthru, where not supported in ISE 2016 Preview.
        .LINK
        https://github.com/tostka/verb-IO
        #>
        #[Alias('Read-InputBoxMultiLine')]
        [CmdletBinding()]
        Param(
            [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,HelpMessage="List of Options to be listed and selection returned[-options @('A','B','C')]")]
                [array]$options,
            [Parameter(Position=1,HelpMessage="Message to be displayed[-Mesage 'Please select a destination path]")]
                [Alias('Title','WindowTitle')]
                [string]$message,
            [Parameter(Position=2,HelpMessage="INT default selection from -options[-DefaultItem 1]")]
                [int]$defaultItem=0,
            [Parameter(HelpMessage="Optional switch to return the user-entered integer rather than the resolved entry from the Options list[-ReturnInteger]")]
                [switch]$ReturnInteger
        ) ;
        BEGIN{
            if($message){
                write-host -foregroundcolor yellow "==$($message):" ;
            } else{
                write-host -foregroundcolor yellow "==SELECT:" ;
            }
            # to support pipeline, aggregate the Options in process block
            # if we're using pipeline, and aggregating, we need to aggreg outside of the process{} block
            if($PSCmdlet.MyInvocation.ExpectingInput){
                $items = @()
            } ;
        }
        PROCESS{
            if($PSCmdlet.MyInvocation.ExpectingInput){
                $items += $options
            }else{
                $items = $options ;
            } ;
        } ;  # PROC-E
        END{
            # igge_iggelito adapted take (cleaner/simpler, continues to prompt until you pick a legit option on the list)
            while ($menuReturn -lt 1) {
                $i = 0
                foreach ($menuItem in $items) {
                    Write-Host ("  [{0}]`t" -F $i) -ForegroundColor Cyan -NoNewline
                    Write-Host ("{0}" -F $menuitem) -ForegroundColor Gray
                    $i++
                }
                $defaultSelect  = $items[$defaultItem]
                $menuSelect     = $(Write-Host "==$($message):" -ForegroundColor Yellow -NoNewline) + $(Write-Host " [Default:"$defaultSelect" ] " -ForegroundColor White -NoNewline; Read-Host)
                $menuReturn     = $items[$menuSelect]
                if($ReturnInteger){
                    $menuSelect | write-output
                }else{
                    $menuReturn | write-output
                } ;
            }
        }
    } ;
#}
#endregion Read-InputConsoleChoiceTDO ; #*------^ END Read-InputConsoleChoiceTDO ^------