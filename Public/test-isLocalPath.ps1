# test-isLocalPath.ps1

#*------v Function test-isLocalPath v------
function test-isLocalPath {
    <#
    .SYNOPSIS
    test-isLocalPath.ps1 - Checks specified path is in Windows Local Path format (d:\dir\file.ext)
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2022-04-21
    FileName    : test-isLocalPath.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,Filesystem
    REVISIONS
    * 9:32 AM 10/2/2026 init
    .DESCRIPTION
    test-isLocalPath.ps1 - Checks specified path is in Windows Local Path format (d:\dir\file.ext)
    Simple inversion of verb-io\test-isUncPath, same [system.uri] testing mechanism, just tests that isUnc -eq `$false v `$true
    Chose to implement as a standalone function, rather than yet another param on test-isUncpath(), because it's a more fundemental test than the UNC-variant test that \\tsclient\ path testing reflects
    .PARAMETER  Path
    Full Path to be tested [-Path '\\host\c$\dir\file.txt']
    .EXAMPLE
    PS> test-isLocalPath -Path "L:\somepath\file.txt" ;  ; 
    Tests a path for UNC
    .EXAMPLE
    PS> test-isLocalPath 'c:\tmp\tmp.txt' -Verbose
    Tests a local path    
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [OutputType('bool')]
    #[Alias('test-IsTscPath')]
    [CmdletBinding()]
    PARAM(
        [Parameter(Mandatory,Position=0,ValueFromPipeline=$true,Helpmessage = "Full Path to be tested [-Path 'c:\dir\file.txt']")]
            [ValidateNotNullOrEmpty()]
            [string]$Path        
    ) ;
    BEGIN {
        #$rMyInvocation = $MyInvocation ; # populated only for scripts, function, and script blocks.
        #If ($MyInvocation.Line -eq 'test-IsTscPath') {
        <#if($rMyInvocation.InvocationName -like '*test-IsTscPath'){
            write-verbose 'Alias:test-IsTscPath was used (setting -isTscPath:`$true).' ;
            $isTSCPath = $true ; 
        } ;
        #>
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
                $false | write-output ;
            } else { 
                write-verbose "$Path is Local Path..." ;
                $true | write-output ;
            } ; 
        } ; 
    } ;  
} ; 
#*------^ END Function test-isLocalPath ^------
