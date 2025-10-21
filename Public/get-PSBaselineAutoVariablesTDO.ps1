# get-PSBaselineAutoVariablesTDOTDO.ps1

    #region GET_PSBASELINEAUTOVARIABLESTDO ; #*------v get-PSBaselineAutoVariablesTDO v------
    Function get-PSBaselineAutoVariablesTDO {
        <#
        .SYNOPSIS
        get-PSBaselineAutoVariablesTDO - Captures all default Powershell Autovariables, via launching a new powershell/pwsh -noprofile session, and capturing & returning all configured variables (which by definition are solely autovariables)
        .NOTES
        Version     : 0.0.
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 20250711-0423PM
        FileName    : get-PSBaselineAutoVariablesTDO.ps1
        License     : MIT License
        Copyright   : (c) 2025 Todd Kadrie
        Github      : https://github.com/tostka/verb-io
        Tags        : Powershell,Autovariables,Variables
        AddedCredit : 
        AddedWebsite: 
        AddedTwitter: 
        REVISIONS
        * 12:05 PM 9/19/2025 init
        .DESCRIPTION
        get-PSBaselineAutoVariablesTDO - Captures all default Powershell Autovariables, via launching a new powershell.exe/pwsh -noprofile session, and capturing & returning all configured variables (which by definition are solely autovariables)
        Checks the proper matching version - WindowsPowershell v PowershellCore - for the executed environment
        By default excludes single-char name variables (`?,`^, `$): use -includeSingleCharVaris switch to return the full population.

        Handy for select-string profiling constant dependanciese in scripts/code files, and excluding autovariables from the list of returned variables (that may need to be locally defined as constants)

        .PARAMETER includeSingleCharVaris
        Switch to include single-character-name variables (`?,`^, `$) in returns (excluded by default) [-includeSingleCharVaris]
        .INPUTS
        None, no piped input.
        .OUTPUTS
        System.Object summary of Exchange server descriptors, and service statuses.
        .EXAMPLE
        PS> $PSAutoVariables = get-PSBaselineAutoVariablesTDO ; 
        .LINK
        https://github.org/tostka/verb-io/
        #>
        [CmdletBinding()]
        [alias('get-PSBaselineAutoVariables')]
        PARAM(
            [Parameter(HelpMessage="Switch to include single-character-name variables (`?,`^, `$) in returns (excluded by default) [-includeSingleCharVaris]")]
                [switch]$includeSingleCharVaris
        ) ;
        $SessionType = $null ; 
        if($PSVersionTable.PSVersion){
            write-verbose "Detect: version via `$PSVersionTable.PSVersion" ; 
            $vers = ('{0}.{1}' -f $PSVersionTable.PSVersion.major, $PSVersionTable.PSVersion.minor) ; 
        }elseif($host.Version){
            write-verbose "Detect: version via `$host.Version" ; 
            $vers = (('{0}.{1}' -f $host.Version.major, $host.Version.minor))
        } else{
            $smsg = "Unable to resolve PS Version!" ; 
            write-warning $smsg ; 
            throw $smsg ; 
            break ; 
        } ; 

        switch -regex ($vers){
            '^[345].*'{
                $SessionType = 'powershell.exe' ; 
                $baselineVars = powershell.exe -NoProfile -Command {
                    Get-Variable | Select-Object -ExpandProperty Name
                }
            } 
            '^[67].*' {
                if(gcm -name pwsh.exe | ?{$_.commandtype -eq 'Application' -AND $_.Name -match '^pwsh\.exe$'}){
                    $SessionType = 'pwsh.exe' ; 
                    $baselineVars = pwsh.exe -NoProfile -Command {
                        Get-Variable | Select-Object -ExpandProperty Name
                    }
                }elseif(gcm -name 'pwsh' | ?{$_.commandtype -eq 'Application' -AND $_.Name -match '^pwsh$'}){
                    $SessionType = 'pwsh' ; 
                    $baselineVars = pwsh -NoProfile -Command {
                        Get-Variable | Select-Object -ExpandProperty Name
                    }
                }
            }
        } ;
        If( $baselineVars) {  
            if($includeSingleCharVaris){
                write-verbose "(including single-char name variables)"
                Return $baselineVars | Sort-Object ; 
            }else{
                write-verbose "(excluding single-char name variables - default)"
                Return ($baselineVars |?{$_.length -gt 1} | Sort-Object) ; 
            } ; 
        } Else {
            write-warning "Unable to retrieve any configured default/Autovariables from a new $($SessionType) session" ; 
        } ; 
    } ; 
    #endregion GET_PSBASELINEAUTOVARIABLESTDO ; #*------^ END get-PSBaselineAutoVariablesTDO ^------