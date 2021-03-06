#*------v get-colorcombo.ps1 v------
function get-colorcombo {
    <#
    .SYNOPSIS
    get-colorcombo - Return a readable console fg/bg color combo (commonly for use with write-host blocks to id variant datatypes across a series of tests)
    .NOTES
    Author: Todd Kadrie
    Website:	http://www.toddomation.com
    Twitter:	@tostka, http://twitter.com/tostka
    REVISIONS   :
    * 1:46 PM 3/5/2021 set DefaultParameterSetName='Random' to actually make 'no-params' default that way, also added $defaultPSCombo (DarkYellow:DarkMagenta), and added it as the 'last' combo in the combo array 
    * 3:15 PM 12/29/2020 fixed typo in scheme parse (quotes broke the hashing), pulled 4 low-contrast schemes out
    * 1:22 PM 5/10/2019 init version
    .DESCRIPTION
    .PARAMETER  Combo
    Combo Number (0-73)[-Combo 65]
    .PARAMETER Random
    Returns a random Combo [-Random]
    .PARAMETER  Demo
    Dumps a table of all combos for review[-Demo]
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    System.Collections.Hashtable
    .EXAMPLE
    $plt=get-colorcombo 70 ;
    write-host @plt "Combo $($a):$($plt.foregroundcolor):$($plt.backgroundcolor)" ;
    Pull and use get-colorcombo 72 in a write-host ;
    .EXAMPLE
    get-colorcombo -demo ;
    .EXAMPLE
    write-host -foregroundcolor green "Pull & write-host a Random get-colorcombo" ;
    $plt=get-colorcombo -Rand ; write-host  @plt "Combo $($a):$($plt.foregroundcolor):$($plt.backgroundcolor)" ;
    Run a demo
    .EXAMPLE
    $plt=get-colorcombo -Rand ; 
    $Host.UI.RawUI.BackgroundColor = $plt.BackgroundColor ; 
    $Host.UI.RawUI.ForegroundColor = $plt.ForegroundColor ; 
    Set Console/$Host to a Random get-colorcombo
    .EXAMPLE
    $plt=get-colorcombo -combo 69 ; 
    set-consolecolors @plt ; 
    Use verb-IO:set-consolecolors() function to set colorcombo 69.
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding(DefaultParameterSetName='Random')]
    # ParameterSetName='EXCLUSIVENAME'
    Param(
        [Parameter(ParameterSetName='Combo',Position = 0, HelpMessage = "Combo Number (0-73)[-Combo 65]")][int]$Combo,
        [Parameter(ParameterSetName='Random',HelpMessage = "Returns a random Combo [-Random]")][switch]$Random,
        [Parameter(ParameterSetName='Demo',HelpMessage = "Dumps a table of all combos for review[-Demo]")][switch]$Demo
    )
    $Verbose = ($VerbosePreference -eq 'Continue') ; 
    if (-not($Demo) -AND -not($Combo) -AND -not($Random)) {
        write-host "(No -combo or -demo specified: Asserting a 'Random' scheme)" ;
        $Random=$true ; 
    } ;
    # rem'd, low-contrast removals: "DarkYellow;Green", "DarkYellow;Cyan","DarkYellow;Yellow", "DarkYellow;White", 
    $schemes = "Black;DarkYellow", "Black;Gray", "Black;Green", "Black;Cyan", "Black;Red", "Black;Yellow", "Black;White", "DarkGreen;Gray", "DarkGreen;Green", "DarkGreen;Cyan", "DarkGreen;Magenta", "DarkGreen;Yellow", "DarkGreen;White", "White;DarkGray", "DarkRed;Gray", "White;Blue", "White;DarkRed", "DarkRed;Green", "DarkRed;Cyan", "DarkRed;Magenta", "DarkRed;Yellow", "DarkRed;White", "DarkYellow;Black", "White;DarkGreen", "DarkYellow;Blue",  "Gray;Black", "Gray;DarkGreen", "Gray;DarkMagenta", "Gray;Blue", "Gray;White", "DarkGray;Black", "DarkGray;DarkBlue", "DarkGray;Gray", "DarkGray;Blue", "Yellow;DarkGreen", "DarkGray;Green", "DarkGray;Cyan", "DarkGray;Yellow", "DarkGray;White", "Blue;Gray", "Blue;Green", "Blue;Cyan", "Blue;Red", "Blue;Magenta", "Blue;Yellow", "Blue;White", "Green;Black", "Green;DarkBlue", "White;Black", "Green;Blue", "Green;DarkGray", "Yellow;DarkGray", "Yellow;Black", "Cyan;Black", "Yellow;Blue", "Cyan;Blue", "Cyan;Red", "Red;Black", "Red;DarkGreen", "Red;Blue", "Red;Yellow", "Red;White", "Magenta;Black", "Magenta;DarkGreen", "Magenta;Blue", "Magenta;DarkMagenta", "Magenta;Blue", "Magenta;Yellow", "Magenta;White" ;
    $defaultPSCombo = @{BackgroundColor = 'DarkMagenta' ; ForegroundColor = 'DarkYellow'} ;
    $colorcombo = @{ } ;
    $i = 0 ;
    # stock the colorschemes indexed-hashtable (supports fast lookups)
    foreach ($scheme in $schemes) {
        $colorcombo[$i] = @{BackgroundColor = $scheme.split(";")[0] ; ForegroundColor = $scheme.split(";")[1] ; } ;
        $i++ ;
    } ;
    $colorcombo[$i] = $defaultPSCombo ; 
    write-verbose "(colorcombo[$($i)] reflects PSDefault scheme)" ; 
    if ($Demo) {
        write-host "(-Demo specified: Dumping a table of range from Combo 0 to $($colorcombo.count-1))" ;
        $a = 00 ;
        Do {
            $plt = $colorcombo[$a].clone() ;
            write-host "Combo $($a):$($plt.foregroundcolor):$($plt.backgroundcolor)" @plt ;
            $a++ ;
        }  While ($a -lt $colorcombo.count) ;
    }
    elseif ($Random) {
        $colorcombo[(get-random -minimum 0 -maximum $colorcombo.count)] | write-output ;
    }
    else {
        write-verbose "-Combo:$($combo) specified:`n$(($colorcombo[$Combo]|out-string).trim())" ; 
        $colorcombo[$Combo] | write-output ;
    } ;
}
#*------^ get-colorcombo.ps1 ^------