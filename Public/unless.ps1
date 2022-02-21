#*------v Function unless v------
function unless {
    <#
    .SYNOPSIS
    unless() - Parameter validation friendly fail msgs func
    .NOTES
    Author: Karl Prosser
    Website:	https://powershell.org/wp/2013/05/21/validatescript-for-beginners/

    REVISIONS   :
    * 10:35 AM 2/21/2022 CBH example ps> adds 
    8:32 AM 9/2/2015 reformatted, added help
    20130521 - web version
    .DESCRIPTION
    use the Unless (condition) -fail "message" pattern to provide a human-friendly fail response
    
    Sample using the unless function call, with the validation expression, and a pre-specified friendly failure message.
    ```powershell
    [CmdletBinding()]
    param(
      [ValidateScript({unless ($_ -gt 100 ) -fail "needs to be greater than 100"})]
      [int] $a
    ) ;
    ```
    .PARAMETER  expressionResultOrScriptBlock
    (Auto-populated by call)
    .PARAMETER  failmessage
    User-friendly failure message to be returned to user
    .INPUTS
    Accepts piped input for the expressionResultOrScriptBlock param.
    .OUTPUTS
    Throws the specified Fail Message to user, if the Parameter Validation specified in expressionResultOrScriptBlock fails to validate.
    .EXAMPLE
      [CmdletBinding()]
      param(
        [ValidateScript({unless ($_ -gt 100 ) -fail "needs to be greater than 100"})]
        [int] $a
      ) ;
      Using the unless function call, with the validation expression, and a pre-specified friendly failure message.
    .LINK
    https://powershell.org/wp/2013/05/21/validatescript-for-beginners/
    #>

    [cmdletbinding()]
    param ($expressionResultOrScriptBlock , $failmessage) ;
    process {
        $_ = (Get-Variable -Scope 1 -Name _).Value ;
        $result = $expressionResultOrScriptBlock; ;
        if ($expressionResultOrScriptBlock -is [scriptblock]) { $result = & $expressionResultOrScriptBlock } ;
        if ($result) { $true } else { throw "[ $failmessage ]" } ;
    } ;
}#*------^ END Function unless ^------