# test-IsUncPath.ps1

#*------v Function test-IsUncPath v------
function test-IsUncPath {
    <#
    .SYNOPSIS
    test-IsUncPath.ps1 - Checks specified path is in UNC format
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2022-04-21
    FileName    : test-IsUncPath.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,Filesystem
    REVISIONS
    * 9:39 AM 10/2/2026 added -isTSCPath param, to test host value & alias:test-IsTscPath (which forces -isTscPath:$true)
    * 10:28 AM 4/21/2022 init
    .DESCRIPTION
    test-IsUncPath.ps1 - Checks specified path is in UNC format
    use -isTscPath to test for functional Termserv/RDP paths (\\tsclient\c\path)
    Includes alias: test-IsTscPath, which forces -isTSCPath:`$true
    .PARAMETER  Path
    Full Path to be tested [-Path '\\host\c$\dir\file.txt']
    .EXAMPLE
    PS> test-IsUncPath -Path "L:\somepath\file.txt" ;  ; 
    Tests a path for UNC
    .EXAMPLE
    PS> test-isuncpath \\$env:computername\c$\tmp\tmp.txt -Verbose
    Tests a unc path
    .EXAMPLE
    PS> test-isuncpath \\tsclient\c\tmp\tmp.txt -isTscPath -Verbose
    Uses -isTscPath to test a tsclient path
    .EXAMPLE
    PS> test-IsTscPath \\tsclient\c\tmp\tmp.txt -Verbose
    Uses alias 'test-IsTscPath' to test a tsclient path
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [OutputType('bool')]
    [Alias('test-IsTscPath')]
    [CmdletBinding()]
    PARAM(
        [Parameter(Mandatory,Position=0,ValueFromPipeline=$true,Helpmessage = "Full Path to be tested [-Path '\\host\c$\dir\file.txt']")]
            [ValidateNotNullOrEmpty()]
            [string]$Path,
        [Parameter(Helpmessage = "Switch to test for Tsclient path (\\tsclient\D\ - tests system.uri Host field)")]            
            [switch]$isTSCPath
    ) ;
    BEGIN {
        $rMyInvocation = $MyInvocation ; # populated only for scripts, function, and script blocks.
        #If ($MyInvocation.Line -eq 'test-IsTscPath') {
        if($rMyInvocation.InvocationName -like '*test-IsTscPath'){
            write-verbose 'Alias:test-IsTscPath was used (setting -isTscPath:`$true).' ;
            $isTSCPath = $true ; 
        } ;
        if ($PSCmdlet.MyInvocation.ExpectingInput) {
            write-verbose "Data received from pipeline input: '$($InputObject)'" ; 
        } else {
            #write-verbose "Data received from parameter input: '$($InputObject)'" ; 
            write-verbose "(non-pipeline - param - input)" ; 
        } ; 
    } ;  
    PROCESS {
        $Error.Clear() ; 
        foreach($item in $path) {
            TRY{
                $PathInfo=[System.Uri]$item ; 
            } CATCH {
                $ErrTrapd=$Error[0] ;
                write-host -foregroundcolor gray "TargetCatch:} CATCH [$($ErrTrapd.Exception.GetType().FullName)] {"  ;
                $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
                write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" ;
                return ; 
            } ;        
            if($PathInfo.IsUnc){ 
                write-verbose "$Path is UNC Path..." ;
                if($isTSCPath){
                    if($PathInfo.Host -eq 'tsclient'){
                        write-verbose "Path.Host -eq 'tsclient'" ; 
                        if($PathInfo.PathAndQuery -match '/[A-Za-z]/'){
                            write-verbose "Path.PathAndQuery -match '/[A-Za-z]/' (non-dollar-sign drive specification)" ; 
                            $true | write-output ;
                        } else { 
                            write-verbose "Path.PathAndQuery -match '/[A-Za-z]/' (non-dollar-sign drive specification)" ; 
                            $false | write-output ;
                        }
                    }else{
                        $false | write-output ;
                    }
                }else{
                    $true | write-output ;
                } ; 
            } else { 
                write-verbose "$Path is Local Path..." ;
                $false | write-output ;
            } ; 
        } ; 
    } ;  
} ; 
#*------^ END Function test-IsUncPath ^------
