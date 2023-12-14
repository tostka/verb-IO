# Expand-IsoFile.ps1

# Expand-ISOFileTDO.ps1 

# #*------v Expand-ISOFileTDO.ps1 v------
Function Expand-ISOFileTDO {
    <#
    .SYNOPSIS
    Expand-ISOFileTDO.ps1 - Unpacks an .iso file out to a a new *parallel* 'unpacked' subdir of the ISO's current directory (e.g. if the file is in c:\tmp\file.iso, the unpacked copy will be in c:\tmp\file\unpacked)
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2023-12-12
    FileName    : Expand-ISOFileTDO.ps1
    License     : MIT License
    Copyright   : (c) 2023 Todd Kadrie
    Github      : https://github.com/tostka/verb-IO
    Tags        : Powershell,development,verbs
    REVISION
    * 1:19 PM 12/14/2023 init
    .DESCRIPTION
    Expand-ISOFileTDO.ps1 - Unpacks an .iso file out to a a new *parallel* 'unpacked' subdir of the ISO's current directory (e.g. if the file is in c:\tmp\file.iso, the unpacked copy will be in c:\tmp\file\unpacked)

   
    .PARAMETER Path
    Verb to find the associated standard alias[-verb report]
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    System.string
    .EXAMPLE
    PS> 'Compare' | get-NounAliasTDO ;
    Return the 'standard' MS alias for the 'Compare' verb (returns 'cr')
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    [Alias('expand-ISOFile')]
    #[OutputType([boolean])]
    PARAM (
        [Parameter(Mandatory = $False,Position = 0,ValueFromPipeline = $True, HelpMessage = 'Path to source .iso file to be expanded[-path c:\pathto\file.iso]')]
            [Alias('PsPath')]
            #[ValidateScript({Test-Path $_ -PathType 'Container'})]
            #[System.IO.DirectoryInfo[]]$Path,
            [ValidateScript({Test-Path $_})]
            [system.io.fileinfo[]]$Path,
        [Parameter(Mandatory = $False,Position = 1, HelpMessage = "Destination for unpack (creates new 'unpacked' dir below specified location; defaults to a new folder parallel to source .iso, named for the iso file basename)paths[-path c:\pathto\file.ext]")]
            [Alias('PsPath')]
            #[ValidateScript({Test-Path $_ -PathType 'Container'})]
            [System.IO.DirectoryInfo]$Destination
            #[string[]]$Path,
    ) ;
    BEGIN {
        $verbose = ($VerbosePreference -eq "Continue") ; 

        if($Destination){
            if(-not (test-path -path $destination -PathType Container -ea 0 )){
                write-host "$($destination) does not pre-exist (will be created)" 
            } else { 
                write-host "$($destination) pre-exists"  ; 
            }    
        } 
        # check if using Pipeline input or explicit params:
        if ($rPSCmdlet.MyInvocation.ExpectingInput) {
            $smsg = "Data received from pipeline input: '$($InputObject)'" ;
            if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
            else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
        } else {
            # doesn't actually return an obj in the echo
            #$smsg = "Data received from parameter input: '$($InputObject)'" ;
            #if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
            #else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
        } ;
    } ;
    PROCESS {
        foreach($item in $path) {
            $smsg = $sBnrS="`n#*------v PROCESSING : $($item) v------" ; 
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H2 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        
            TRY{
                #[system.io.fileinfo[]]$Path = "D:\E2016CU23-kb5011155\ExchangeServer2016-x64-CU23.ISO" ; 
                if(test-path $path){
                    write-verbose "`$Path confirms existing" ;
                    write-verbose "mount-diskimage -ImagePath $($path.fullname) -PassThru -ea STOP"
                    $iso = mount-diskimage -ImagePath $path.fullname -PassThru -ea STOP;
                    write-host "Get-DiskImage:`n$(($iso |Get-DiskImage |out-string).trim())" ; 
                    write-host "get-volume:`n$(($iso |Get-DiskImage | get-volume |out-string).trim())" ; 
                    write-verbose "`$iso |Get-DiskImage  -ea STOP| get-volume  -ea STOP | select -expand driveletter" ;
                    $isodrive = $iso |Get-DiskImage  -ea STOP| get-volume  -ea STOP | select -expand driveletter ;
                    $destParent = (split-path (split-path $Path -ea STOP)) ; 
                    $desBaseName = split-path $Path -leaf -ea STOP ; 
                    $pltCI=[ordered]@{
                        path = "$($isodrive):\" ;
                        Recurse = $true ;
                        destination = (join-path -path $destParent -childpath (join-path -path $desBaseName -childpath 'unpacked' -ea STOP) -ea STOP)
                        erroraction = 'STOP' ;
                        whatif = $($whatif) ;
                    } ;
                    $smsg = "copy-item w`n$(($pltCI|out-string).trim())" ; 
                    write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" ;
                    copy-item @pltCI ;
                    Dismount-DiskImage -ImagePath $Path ; 
                } else { 
                    $smsg = "Invalid/Non-existant ISO path!" ;
                    write-warning $smsg ;
                    throw $smsg ;
                } ; 
            } CATCH {
                $ErrTrapd=$Error[0] ;
                $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug
                else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            } ; 
        
            $smsg = "$($sBnrS.replace('-v','-^').replace('v-','^-'))" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H2 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        } ;  # loop-E
    } ;  # PROC-E
    END {} ; # END-E
}
#*------^ get-NounAliasTDO.ps1 ^------
