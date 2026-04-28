# test-RDPFileSignatureTDO.ps1

#region TEST_RDPFILESIGNATURETDO ; #*------v test-RDPFileSignatureTDO v------
function test-RDPFileSignatureTDO {
    <#
    .SYNOPSIS
    test-RDPFileSignatureTDO - Superfically test (check for signature tags in file), Digitally signed status on .rdp TermServ connection files
    .NOTES
    Author: Taylor Gibb
    Website:	https://www.howtogeek.com/tips/how-to-extract-zip-files-using-powershell/
    Tweaked By: Todd Kadrie
    Website:	http://tinstoys.blogspot.com
    Twitter:	http://twitter.com/tostka
    Additional Credits:
    REVISIONS   :
    * 12:59 PM 4/28/2026 init
    .DESCRIPTION
    test-RDPFileSignatureTDO - Superfically test (check for signature tags in file), Digitally signed status on .rdp TermServ connection files

    Only mstsc.exe can currently validate a signed file (by loading and displaying the file without prompts). 
    
    All this function does is check for an rdpsign.exe applied signature & signscope tag in the file. 
    Verbose output will return the matched lines in the .rdp file

    .PARAMETER Path
    .Rdp File paths[-path c:\pathto\file.rdp]
    .INPUTS
    Accepts piped input Path 
    .OUTPUTS
    Returns string path to properly signed rdp files (and $false for unsigned files)
    .EXAMPLE
    PS> $results = test-RDPFileSignatureTDO -path 'C:\Users\aaaaaAAA\Desktop\rdp-faves\AAAAAAAAAAA-AAA-Ex16-Mbx1-1024x768-SID.RDP' ;
    PS> $results ; 

        C:\Users\aaaaaAAA\Desktop\rdp-faves\AAAAAAAAAAA-AAA-Ex16-Mbx1-1024x768-SID.RDP: confirmed '^(signature|signscope) applied 

    Test and report results of test
    .LINK
    https://github.com/tostka/verb-io
    #>
    [CmdletBinding()]
    [Alias('sign-RdpFile','sign-RdpFileTDO')]
    PARAM(
        [Parameter(Mandatory = $False,Position = 0,ValueFromPipeline = $True, HelpMessage = '.Rdp File paths[-path c:\pathto\file.rdp]')]
            [Alias('PsPath')]
            [ValidateScript({Test-Path $_})]
            [ValidateScript({ if([IO.Path]::GetExtension($_) -ne ".rdp") { throw "Path must point to an .rdp file" } $true })]
            [system.io.fileinfo[]]$Path
    ) ; 
    BEGIN {
        ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;

        if ($PSCmdlet.MyInvocation.ExpectingInput) {
            write-verbose "Data received from pipeline input: '$($InputObject)'" ; 
        } else {
            #write-verbose "Data received from parameter input: '$($InputObject)'" ; 
            write-verbose "(non-pipeline - param - input)" ; 
        } ; 
    } ;  # BEGIN-E
    PROCESS {
        $Error.Clear() ; 
        foreach ($item in $Path){
            TRY{
                Write-Verbose "Checking RDP file: $($item.fullname)" ; 
                if($sigs = gc $item.fullname | Where-Object { $_ -match "^signature" -or $_ -match "^signscope" }){
                    write-host "$($item.fullname): confirmed '^(signature|signscope) applied" ; 
                    write-verbose "`nSignatures`n$(($sigs|out-string).trim())" ; 
                    $item.fullname | write-output 
                }else{
                    $smsg = "$($item.fullname): MISSING '^(signature|signscope)!" ; 
                    write-host $smsg ; 
                    $false | write-output  ; 
                }
            } CATCH {$ErrTrapd=$Error[0] ;
                write-host -foregroundcolor gray "TargetCatch:} CATCH [$($ErrTrapd.Exception.GetType().FullName)] {"  ;
                $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
                write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" ;
            } ;
        } ;  # loop-E
    }  # if-E PROC
    END{} ; 
} ; 
#endregion TEST_RDPFILESIGNATURETDO ; #*------^ END test-RDPFileSignatureTDO ^------