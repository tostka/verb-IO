# Mount-MyPSDrives.ps1

#*------v Function Mount-MyPSDrives v------
Function Mount-MyPSDrives {

    <#
    .SYNOPSIS
    Mount-MyPSDrives - Creates temporary powershell drives that are associated with a location in an item data store. Supports six preconfigured PSDrive configs (mountable areas in user's profile)
    Creates temporary and persistent drives that are associated with a location in an item data store.
    .NOTES
    Version     : 0.0.
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2025-12-05
    FileName    : Mount-MyPSDrives.ps1
    License     : MIT License
    Copyright   : (c) 2025 Todd Kadrie
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell,Filesystem,Drives,PsDrives,Mount
    AddedCredit :
    AddedWebsite:
    AddedTwitter:
    REVISIONS
    * 12:00 PM 12/5/2025 ren'd New-MyPSDrives -> Mount-MyPSDrives, aliased original ; added to vio, parameterized the newDrives spec, moved profile code into CBH demos;
      there's a need for it; XCIDR reportedly goes after SID use of new-psdrive, but UID - esp avoiding the reg mounts - likely may not.
      Keeping this from autoexecing in the profile, and using ondemand would probably work best.
      added code to check for elevation and warn pre-prompt where in use in work domains, and elevated, or mounting registry-related psdrives (both of which are targeted by CXDR).
		* 1:15 PM 6/18/2020 updated CBH
		* 6:49 PM 11/10/2019 #2334: fixed typo double assignement
		* 10:00 AM 10/1/2019 Mount-MyPSDrives:fundemental rewrote, loop the params and run single create block, added splatting, moved myDocs intot he main loop.
		# 9:04 AM 5/12/2017 add AllUsersMods (C:\Program Files\WindowsPowerShell\Modules) "If you want a module to be available to all user accounts on the computer, install the module in the Program Files location."
		# 7:43 AM 5/22/2017 Mount-MyPSDrives, rem'd 2 lines:  old dupes from a messy paste job, broke brace matching in forloop.
		10:11 AM 5/12/2017 Mount-MyPSDrives: added AllUserMods, and made the loop $i dynamic on drivenames.
		1:50 PM 11/5/2015 - fixed break caused because PSCX sticks itself into the 2nd position oin the PSModulePath - this is supposed to point to $($env:programfiles)\WindowsPowerShell\Modules! So we rewrite a switch, and hard-code the paths
    .DESCRIPTION
    Mount-MyPSDrives - Creates temporary powershell drives that are associated with a location in an item data store. Supports six preconfigured PSDrive configs (mountable areas in user's profile)

    Ran without issues in my profile from 2015 to 2023, until CXDR decided to start targting the new-PSDrive mount commands, and breaking profile load.
    Tore out completely as a workaround. As of 12/2025, resurrected &  moving into vio\Mount-MyPSDrives. There are handy reasons these drives may want to be loaded ondemand - for searching profile text files using powershell's select-string and other filtering options, etc.

    Hilariously, powershell by default auto-mounts cert:, Env:, HKCU: & HKU:, CXDR doesn't seem to mind those. Just the additional items and contexts.

    .EXAMPLE
		PS> Mount-MyPSDrives -driveNames @('myDocs','myMods', 'sysMods', 'AllUserMods','HKCR','HKU') -whatif -showdebug
		Run whatifpass at creating default PSDrives: myDocs, myMods, sysMods, AllUserMods profile dirs as psdrives, and HKCR & HKU reg keys as psdrives.
		The mods correspond to the users' & system modules folders, and all-users modules, and myDocs points to user's profile Documents folder. HKCR & HKU create two missing registry defaults (HKEY_CLASSES_ROOT|HKEY_USERS)
		.EXAMPLE
		PS> write-verbose "mount the MyDocs,MyMods,SysMods & AllUserMods PSDrives"
    PS> Mount-MyPSDrives -driveNames @('myDocs','myMods', 'sysMods', 'AllUserMods')
    PS> write-verbose "echo them back: list all non-single-letter name filesystem drives: (new standard is do all"
    PS> write-host -foregroundcolor green "$((get-psdrive -PSProvider filesystem -scope global | where-object { $_.Name.length -gt 1 } | Select-Object Name, Root | format-table -auto |out-string).trim())" ;
    PS> write-verbose "echo them back: list all registry drives"
    PS> write-host -foregroundcolor green "$((get-psdrive -PSProvider Registry -scope global | where-object { $_.Name.length -gt 1 } | Select-Object Name, Root | format-table -auto |out-string).trim())" ;
    .LINK
    https://github.com/tostka/verb-io/
    #>
    [Alias('New-MyPSDrives')]
		PARAM(
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,HelpMessage="Array of preconfigured drive type identifiers (myMods|sysMods|AllUserMods|myDocs|HKCR|HKU)[-driveNames @('myDocs','myMods', 'sysMods', 'AllUserMods')]")]
            [ValidateSet('myMods','sysMods','AllUserMods','myDocs','HKCR','HKU')]
            [string[]]$driveNames,
        [Parameter(HelpMessage="Whatif switch [-whatIf]")]
            [switch] $whatIf = $false
    ) ;
    BEGIN{
        #$driveNames = "myMods", "sysMods", "AllUserMods"; # psmodules
        #$driveNames += "HKCR", "HKU" ; # missing registry psdrvs
        #$driveNames += "myDocs" ; # user docs
        write-host "Mounting My PS Drives ($($drivenames -join ', '))..."
        if($env:userdomain -eq $tormeta.legacydomain){
            # check elevation: CXDR targets SID profile psdrive use, pop prompt before running
            if(-not(get-variable -Name whoamiAll -ea 0)){$whoamiAll = (whoami /all)} ;
            $isElevated = [bool](($whoamiAll |?{$_ -match 'BUILTIN\\Administrators'}) -AND ($whoamiAll |?{$_ -match 'S-1-16-12288'}))  ;
            $smsg = $null ;
            if($isElevated){
                $smsg = "Work Dom Elevated Account preparing to execute New-PSDrive cmds that could be subject to active blocks!" ;
            } ;
            # also targets registry hive psdrive mounts, likewise prompt
            if($drivenames -match 'HKCR|HKU'){
                $smsg += "Work Dom Account preparing to execute registry-hive related New-PSDrive cmds that could be subject to active blocks!"
            } ;
            if($smsg){
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                $bRet=Read-Host "Enter YYY to continue. Anything else will exit"  ;
                if ($bRet.ToUpper() -eq "YYY") {
                    $smsg = "(Moving on)" ;
                    write-host -foregroundcolor green $smsg  ;
                } else {
                    $smsg = "(*skip* use)" ;
                    write-host -foregroundcolor yellow $smsg  ;
                    break ; #exit 1
                } ;
            } ;
        } ;
    }
    PROCESS{
        $pltDrv = @{name = $null ; PSProvider = $null ; Root = $null ; scope = "Global" ; whatif = $($whatif) ; Verbose = ($VerbosePreference -eq 'Continue')} ;
        $pltDir = @{path = $null ; type = "directory" ; whatif = $($whatif); } ;

        foreach ($driveName in $driveNames) {
            #if (-not(get-psdrive | ? { $_.name -like $driveNames[$i] })) {
            if (-not(get-psdrive -name $drivename -ea 0)) {
              switch ($driveName) {
                "myMods" {
                      write-host New-PSDrive: "$($driveName)" ;
                      # stock: C:\Users\aaaaaaaa\Documents\WindowsPowerShell\Modules
                      # reloc'd: C:\Users\aaaaaaaa\OneDrive - Aaa Aaaa Aaaaaaa\Documents\WindowsPowerShell\Modules
                      # psC: C:\Users\aaa\Documents\PowerShell\Modules
                      # PsW only: "(?:[\w]\:)\\Users\\\w*((\\.*)*)\\Documents\\WindowsPowerShell\\Modules"
                      if (-not($pltDrv.root = [string]($env:PSModulePath.split(";") | Where-Object { $_ -match "(?:[\w]\:)\\Users\\\w*((\\.*)*)\\Documents\\(WindowsPowerShell|PowerShell)\\Modules" }))) {
                          write-host -foregroundcolor RED "$((get-date).ToString('HH:mm:ss')):UNABLE TO LOCATE myMods DIR IN `PSModulePath:`n$(($env:PSModulePath.split(";")|out-string).trim())`nABORTING" ;
                        BREAK ;
                      } ;
                      $pltDir.path = $pltDrv.root ;
                      $pltDir.type = "directory" ;
                      $pltDrv.name = $($driveName) ;
                      $pltDrv.PSProvider = "filesystem" ;
                  }
                  "sysMods" {
                      write-host New-PSDrive: "$($driveName)" ;
                      # C:\Windows\system32\WindowsPowerShell\v1.0\Modules
                      # psC: C:\WINDOWS\system32\WindowsPowerShell\v1.0\Modules
                      # PsW only: "(?:[\w]\:)\\Windows\\system32\\WindowsPowerShell\\v1.0\\Modules"
                      if (-not($pltDrv.root = [string]($env:PSModulePath.split(";") | Where-Object { $_ -match "(?:[\w]\:)\\(WINDOWS|Windows)\\system32\\WindowsPowerShell\\v1.0\\Modules" }))) {
                            write-host -foregroundcolor RED "$((get-date).ToString('HH:mm:ss')):UNABLE TO LOCATE myMods DIR IN `PSModulePath:`n$(($env:PSModulePath.split(";")|out-string).trim())`nABORTING" ;
                        BREAK ;
                      } ;
                      $pltDir.path = $pltDrv.root ;
                      $pltDir.type = "directory" ;
                      $pltDrv.name = $($driveName) ;
                      $pltDrv.PSProvider = "filesystem" ;
                  }
                  "AllUserMods" {
                      write-host New-PSDrive: "$($driveName)" ;
                      # C:\Program Files\WindowsPowerShell\Modules
                      # psC: C:\Program Files\PowerShell\Modules
                      # psC: c:\program files\powershell\6\Modules - don't match
                      # PsW only: "(?:[\w]\:)\\Program Files\\WindowsPowerShell\\Modules"
                      # PsC this returns both, default to the first!
                      # no, pull the \6\ root matching out completely.
                      # psC match both - but we can only use one: "(?:[\w]\:)\\(P|p)rogram (F|f)iles\\((Windows)*)(P|p)ower(S|s)hell((\\\d)*)\\Modules"
                      if (-not($pltDrv.root = [string]($env:PSModulePath.split(";") | Where-Object { $_ -match "(?:[\w]\:)\\Program Files\\((Windows)*)PowerShell\\Modules" }))) {
                        write-host -foregroundcolor RED "$((get-date).ToString('HH:mm:ss')):UNABLE TO LOCATE myMods DIR IN `PSModulePath:`n$(($env:PSModulePath.split(";")|out-string).trim())`nABORTING" ;
                        BREAK ;
                      } ;
                      $pltDir.path = $pltDrv.root ;
                      $pltDir.type = "directory" ;
                      $pltDrv.name = $($driveName) ;
                      $pltDrv.PSProvider = "filesystem" ;
                  }
                  "myDocs" {
                      write-host New-PSDrive: "$($driveName)" ;
                      #New-PSDrive -Name "myDocs" -PSProvider FileSystem -Root $([environment]::getfolderpath("mydocuments")) -Description "Maps My Documents folder." | Out-Null ;
                      $pltDrv.Root = [string]([environment]::getfolderpath("mydocuments")) ;
                      $pltDir.path = $pltDrv.Root ;
                      $pltDir.type = "directory" ;
                      $pltDrv.name = $($driveName) ;
                      $pltDrv.PSProvider = "filesystem" ;
                  }
                  "HKCR" {
                      write-host New-PSDrive: "$($driveName)" ;
                      #New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | out-null ;
                      $pltDrv.Name = "HKCR" ;
                      $pltDrv.root = "HKEY_CLASSES_ROOT" ;
                      $pltDrv.PSProvider = "Registry" ;
                  } ;
                  "HKU" {
                      write-host New-PSDrive: "$($driveName)" ;
                      #New-PSDrive -Name HKU -PSProvider Registry -Root HKEY_USERS | out-null ;
                      $pltDrv.Name = "HKU" ;
                      $pltDrv.root = "HKEY_USERS" ;
                      $pltDrv.PSProvider = "Registry" ;
                  } ;

                } ;
                if (($pltDrv.PSProvider -eq 'filesystem') -AND -not( test-path $pltDir.path ) ) {
                    write-verbose "$((get-date).ToString('HH:mm:ss')):Creating Missing Dir:New-Item w`n$(($pltDir|out-string).trim())"  ;
                    New-Item @pltDir;
                }
                write-verbose "$((get-date).ToString('HH:mm:ss')):New-PsDrive w`n$(($pltDrv|out-string).trim())" ;  ;
                New-PSDrive @pltDrv | Out-Null ; ;
            }
            else {
                write-host "$($driveName) exists";
            }# if-E
        } #end For ;
		} ;  # PROC-E

} #*------^ END Function Mount-MyPSDrives ^------ ;
