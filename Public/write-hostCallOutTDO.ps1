
#*------v Function write-hostCallOutTDO v------
function write-hostCallOutTDO {
    <#
    .SYNOPSIS
    write-hostCallOutTDO - wrapper for write-host that implements a formatted 'markdown-style' Callout console output. 
    .NOTES
    Version     : 0.0.5
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2023-01-12
    FileName    : write-hostCallOutTDO.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,Host,Console,Output,Formatting
    AddedCredit : L5257
    AddedWebsite: https://community.spiceworks.com/people/lburlingame
    AddedTwitter: URL
    REVISIONS
    * 11:08 AM 11/11/2024 added MS 'alerts' Callout variant info to CBH, for reference
    * 2:36 PM 10/9/2024 add: write-hostCallOut alias (vs full write-hostCallOutTDO)
    * 10:15 AM 9/17/2024 added -backgroundcolor/-foregroundcolor overrides of the per-type defaults; updated the 'demo', CBH expl to use the new -type Demo ; added a fg/bg override exmpl
    * 3:22 PM 9/16/2024 add: -LabelOverride -type: Joke, Reference, Dead, UnlTrophy, Medal, Demo (demo full set on specified text); added CBH demos for Stupid Prize & Achivement Unlocked, using new -LabelOverride; 
    * 3:49 PM 9/12/2024 corrected Important emoji; added Tcase to the $type user entered (as it's used in some, to drive labeling variants); fixed high ascii in the face ascii emojis (dash wasn't a stock -) ; init

    .DESCRIPTION

    write-hostCallOutTDO - wrapper for write-host that implements a formatted 'markdown-style' Callout console output. 

    Under WinTerm, ISE or VSCode, displays suitable Unicode Icon/Emoji. 
    Under stock Console, displays a plain text alterantive. 

    Supports following types, 
    (first 5 are Github's standard types)

        - Caution
        - Note
        - Tip
        - Important
        - Warning
        - Dead
        - Example
        - Error
        - Fix
        - Info
        - Joke
        - Label
        - Medal
        - OK
        - Reference
        - Success
        - Trophy
        - Unlock
        - Demo
        - Random

    ...emulating Markdown Callouts, a typical implementation, the GitHub flavor, is described here:

    [New Markdown extension: Alerts provide distinctive styling for significant content - GitHub Changelog](https://github.blog/changelog/2023-12-14-new-markdown-extension-alerts-provide-distinctive-styling-for-significant-content/)

    With formal documentation here:

    [Basic writing and formatting syntax - GitHub Docs](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax#alerts)

    And discussed further here:

    [Callouts - Example of markdown callouts](https://davidwells.io/typography/callouts)

    Which, in the above examples are syntaxed in Markdown as:

    ```markdown
    > [!NOTE]  
    > Highlights information that users should take into account, even when skimming.

    > [!TIP]
    > Optional information to help a user be more successful.

    > [!IMPORTANT]  
    > Crucial information necessary for users to succeed.

    > [!WARNING]  
    > Critical content demanding immediate user attention due to potential risks.

    > [!CAUTION]
    > Negative potential consequences of an action.
    ```

    Which in the implementation above render in as output markdown as: (Below doesn't depict the icon and automatic color schemes asserted on browser rendering at Github)

    ```markdown
    
    > Note
    > 
    > Highlights information that users should take into account, even when skimming.
    > 

    > Tip
    > 
    > Optional information to help a user be more successful.
    > 

    > Important
    > 
    > Crucial information necessary for users to succeed.
    > 

    > Warning
    > 
    > Critical content demanding immediate user attention due to potential risks.
    > 

    > Caution
    > 
    > Negative potential consequences of an action.
    ```

Microsoft Documentation ('Learn') calls these 'Alerts', and supports the following:
[Markdown reference for Microsoft Learn - Contributor guide - Alerts | Microsoft Learn](https://learn.microsoft.com/en-us/contribute/content/markdown-reference#alerts-note-tip-important-caution-warning)

    ```markdown
    > [!NOTE]
    > Information the user should notice even if skimming.

    > [!TIP]
    > Optional information to help a user be more successful.

    > [!IMPORTANT]
    > Essential information required for user success.

    > [!CAUTION]
    > Negative potential consequences of an action.

    > [!WARNING]
    > Dangerous certain consequences of an action.
    ```

    Which render in as output markdown as: (Below doesn't depict the icon and automatic color schemes asserted on browser rendering at Microsoft)
    
    ```markdown
    [purple #3B2E58 bg]
    (!) Note
    
    Information the user should notice even if skimming.

    [green #054B16 bg]
    [bulb] Tip

    Optional information to help a user be more successful.

    [blue #004173 bg]
    (i) Important

    Essential information required for user success.

    [red #630001 bg]
    (x) Caution

    Negative potential consequences of an action.

    [lighter green #6A4B16 bg]
    /!\ Warning

    Dangerous certain consequences of an action.
    ```
    
    This implementation aims to emulate the output, while substiting common emoji/unicode character alternatives (in WinTerm or ISE/VSC), or approximating keyboard characters (in native Console, which lacks high-code support).
        

    ## Raw Text Emoji References (for expanding down the road, when looking for raw text emoji equivelents for native console)

    #-=Alt emojis to approximate status in raw text-=-=-=-=-=-=-=
    | Sideways Latin-only emoticons Icon |Emoji |Meaning|
    |---|---|---|
    |:-)|
    |:) |:-]|
    |:] |:->|
    |:> |8-)|
    |8) |:-}|
    |:} |:^) |=] |=) |☺️🙂😊😀😁 |Smiley, happy face[3][4][5][6]|
    |:-D|
    |:D |8-D|
    |8D |=D |=3 |B^D |c: |C: |😃😄😎 |Laughing,[3] big grin,[4][5] grinning with glasses[7]|
    |x-D|
    |xD |X-D|
    |XD |😆😂 |Laughing[8][9][10]|
    |:-))|
    |:))|
    |||Very happy or double chin[7]|
    |:-(|
    |:( |:-c|
    |:c |:-<|
    |:< |:-[|
    |:[ |:-|| |:{ |:@ |:( |;( |☹️🙁😞😟😣😖 |Frown,[3][4][5] sad,[11] pouting|
    |:'-(|
    |:'( |:=( |😢😭 |Crying[11]|
    |:'-)|
    |:') |:"D |🥲🥹😂 |Tears of happiness[11]|
    |>:( |>:[ |😠😡 |Angry[12]|
    |D-': |D:< |D: |D8 |D; |D= |DX |😨😧😦😱😫😩 |Horror, disgust, sadness, great dismay[4][5] (right to left)|
    |:-O|
    |:O |:-o|
    |:o |:-0|
    |:0 |8-0 |>:O |=O|
    |=o |=0 ||😮😯😲 |Surprise,[4] shock|
    |:-3|
    |:3 |=3 |x3|
    |X3 |😺😸🐱 |Cat face, curled mouth, cutesy,[13][14][15] playful, mischievous[16]|
    |>:3 |😼 |Lion smile,[16] evil cat, playfulness|
    |:-*|
    |:*
    |:x |😗😙😚😘😍 |Kiss[3]|
    |;-)|
    |;) |*-)|
    |*) |;-]|
    |;] |;^)|
    |;>|
    ||:-, |;D |;3 |😉😜😘 |Wink,[3][4][5] smirk[17][3]|
    |:-P|
    |:P |X-P|
    |XP |x-p|
    |xp |:-p|
    |:p |:-Þ|
    |:Þ |:-þ|
    |:þ |:-b|
    |:b |d: |=p |>:P |😛😝😜🤑 |Tongue sticking out, cheeky/playful,[3] blowing a raspberry|
    |:-/|
    |:/ |:-. |>:\ |>:/ |:\ |=/ |=\ |:L |=L |:S |🫤🤔😕😟 |Skeptical, annoyed, undecided, uneasy, hesitant[3]|
    |:-
    |:| |😐😑 |Straight face[4] no expression, indecision[11]|
    |:$ |://)|
    |://3 |😳😞😖 |Embarrassed,[5] blushing[7]|
    |:-X|
    |:X |:-#|
    |:# |:-&|
    |:& |🤐😶 |Sealed lips, wearing braces,[3] tongue-tied[11]|
    |O:-)|
    |O:) |0:-3|
    |0:3 |0:-)|
    |0:) |0;^) |😇👼 |Angel,[3][4][17] halo, saint,[11] innocent|
    |>:-)|
    |>:) |}:-)|
    |}:) |3:-)|
    |3:) |>;-)|
    |>;) |>:3|
    |>;3 |😈 |Evil,[4] devilish[11]|
    ||;-) ||-O |B-) |😎😪 |Cool,[11] bored, yawning[17]|
    |:-J |😏😒 |Tongue-in-cheek[18]|
    |#-) ||Partied all night[11]|
    |%-)|
    |%) |😵😵‍💫😕🤕 |Drunk,[11] confused|
    |:-###..|
    |:###.. |🤒😷🤢 |Being sick[11]|
    |<:-| ||Dumb, dunce-like[17]|
    |',:-| |',:-l |🤨 |Scepticism, disbelief, disapproval[19][20]|
    |:E |😬 |Grimacing, nervous, awkward[21]|
    |8-X |8=X |x-3 |x=3 |☠️💀🏴‍☠️ |Skull and crossbones[22]|
    |~:> |🐔🐓 |Chicken[23] |
    #-=-=-=-=-=-=-=-=
    #-=-=-=-=-=-=-=-=
    (^_^) or (^-^) 	smile.
    (`_^) or (^_~) 	wink.
    (>_<) 	in pain.
    (<_>) 	sad.
    (^o^) 	singing.
    \(^o^)/ 	very excited (rasing hands).
    (-_-) or (~_~) or (=_=) 	annoyance, sleeping.
    (-.-)zzZ 	sleeping.
    (?_?) 	eyeing something or someone, rolling one's eyes.
    (<_<) or (>_>) or (c_c) 	skepticism, looking around suspiciously.
    (;_;) or (T_T) 	crying.
    (@_@) 	dazed.
    (o_O) 	confused, surprise, disbelief.
    (O_O) 	shocked.
    (0_<) 	flinch, nervous wink.
    (._.) 	intimidated, sad, ashamed.
    ($_$) 	chaching!
    (x_x) or (+_+) 	dead, knocked out or giving up.
    (n_n) 	pleased.
    (u_u) 	annoyance, sarcasm, sometimes disappointment.
    (9_9) or (+_+) 	rolleyes.
    (e_e) 	up to mischief.
    (o_e) 	twitching eye.
    (*_*) 	starstruck.
    ;o; or ;O; 	crying loudly.
    (I_I) 	"What?", mellow.
    t(^.^t) Giving you the finger
    or t(-.-t)
    or t(o.ot)
    or
    _!_(`_`)_!_
    or ???(?_?)???
    or ,,l,, (o_o),,l,, 	
    #-=-=-=-=-=-=-=-=

   
    .PARAMETER NoNewline <System.Management.Automation.SwitchParameter>
    The string representations of the input objects are concatenated to form the output. No spaces or newlines are inserted between
    the output strings. No newline is added after the last output string.
    .PARAMETER Object
    Objects to display in the host.
    .PARAMETER Separator <System.Object>
    Specifies a separator string to insert between objects displayed by the host.
     .PARAMETER Type
    Callout type to display (Important|Note|Info|Label|Tip|Warning|Caution|Example|Error|Fix|OK|Success|Reference|Random)[-Type 'Note']
    .PARAMETER BackgroundColor
    (Optional) Overrides default background color for given type. The acceptable values for this parameter are:
    (Black | DarkBlue | DarkGreen | DarkCyan | DarkRed | DarkMagenta | DarkYellow | Gray | DarkGray | Blue | Green | Cyan | Red | Magenta | Yellow | White)
    .PARAMETER ForegroundColor <System.ConsoleColor>
    (Optional) Overrides default text color for given type. The acceptable values for this parameter are:
    (Black | DarkBlue | DarkGreen | DarkCyan | DarkRed | DarkMagenta | DarkYellow | Gray | DarkGray | Blue | Green | Cyan | Red | Magenta | Yellow | White)
    .PARAMETER NoWrap
    Switch to disable all auto-wrapping[-NoWrap]
    .PARAMETER WrapChars
    Integer number of characters at which to autowrap -Object (defaults to 60)[-Type '-WrapChars 30
    .PARAMETER Tight
    Switch that suppresses vertical extra lines in the output.
    .EXAMPLE
    PS> write-hostCallOutTDO -Object (new-loremstring -minWords 25 -minSentences 2 -numParagraphs 2) -Type Info -verbose 
    
        > ℹ **Information**
        >
        >	Diam laoreet consectetuer nibh ipsum nonummy ipsum sed nibh
        >	magna amet consectetuer dolore ipsum magna sit nibh sed nibh
        >	laoreet magna adipiscing amet ipsum elit. Laoreet lorem
        >	euismod tincidunt diam ut adipiscing laoreet aliquam nibh
        >	dolore dolor laoreet ut consectetuer ipsum laoreet tincidunt
        >	adipiscing dolore ut euismod sed nonummy consectetuer.
        >	
        >	
        >	Sed nibh sit consectetuer consectetuer laoreet amet
        >	magna ut nonummy ipsum aliquam tincidunt ut tincidunt
        >	nonummy nibh erat nibh euismod elit tincidunt laoreet ipsum
        >	tincidunt. Lorem laoreet diam dolor diam laoreet dolore ut
        >	magna sed laoreet sit nibh diam elit dolor euismod ipsum
        >	amet elit sit amet tincidunt nibh erat.
        >

    Simple Info indented text demo (fed from verb-text\new-Lorem())
    .EXAMPLE
    PS> $smsg = "Useful information that users should know, even when skimming content." ; 
    PS> write-hostCallOutTDO -Object $smsg -Type Note -Nowrap ; 


        > ℹ **Note**
        >
        >	Useful information that users should know, even when skimming content.
        >

    Demo -type:Note with typical sample Callout (-NoWrap, to suppress default 60char wrapping)
    .EXAMPLE
    PS> $smsg = "Helpful advice for doing things better or more easily." ; 
    PS> write-hostCallOutTDO -Object $smsg -Type TIP -Nowrap ; 


        > 💡 **Tip**
        >
        >	Helpful advice for doing things better or more easily.
        >

    Demo -type:Tip with typical sample Callout (-NoWrap, to suppress default 60char wrapping)
    .EXAMPLE
    PS> $smsg = "Key information users need to know to achieve their goal." ; 
    PS> write-hostCallOutTDO -Object $smsg -Type Important -Nowrap ; 


        > 🗯 **Important**
        >
        >	Key information users need to know to achieve their goal.
        >
        
    Demo -type:Important with typical sample Callout (-NoWrap, to suppress default 60char wrapping)
    .EXAMPLE
    PS> $smsg = "Urgent info that needs immediate user attention to avoid problems." ; 
    PS> write-hostCallOutTDO -Object $smsg -Type Warning -Nowrap ; 


        > ⚠ **Warning**
        >
        >	Urgent info that needs immediate user attention to avoid problems.
        >
        
    Demo -type:Warning with typical sample Callout (-NoWrap, to suppress default 60char wrapping)
    .EXAMPLE
    PS> $smsg = "Advises about risks or negative outcomes of certain actions." ; 
    PS> write-hostCallOutTDO -Object $smsg -Type Caution -Nowrap ; 


        > 🛑 **Caution**
        >
        >	Advises about risks or negative outcomes of certain actions.
        >
        
    Demo -type:Caution with typical sample Callout (-NoWrap, to suppress default 60char wrapping)

    .EXAMPLE
    PS> write-verbose "Pull random text via verb-text\new-loremString()" ; 
    PS> $smsg = (new-loremstring -minWords 6 -minSentences 1 ) ; 
    PS> write-verbose "Cycle the variant Types through the text, using the Alias for write-hostCalloutTDO" ; 
    PS> w-hCO -obj $smsg -Type Demo -verbose ;

        > 🛑 **Caution**
        >
        >	Diam lorem diam erat laoreet diam.
        >

        > ℹ **Note**
        >
        >	Diam lorem diam erat laoreet diam.
        >
        [continues, trimmed]

    Demo each of the Callouts, in series, (using my verb-text\new-loremstring() as the object/text source), with verbose output.
    .EXAMPLE
    PS> get-fortune |  ?{$_} | w-hCO -type Random -NoWrap ;


        > ⚠️ **Warning**
        >
        >        (1) Everything depends. (2) Nothing is always. (3) Everything is
        >       sometimes.
        >

    Completely silly Callout, fed by a fortune app, outputing into a Random type Callout
    .EXAMPLE
    PS> write-hostCallOutTDO -Object FAFO -LabelOverride "✨Achievement Unlocked 🔒✨" -type Trophy


        > 🏆 **✨Achievement Unlocked 🔒✨**
        >
        >	FAFO
        >

    Demo -LabelOverride use with existing Trophy Callout, to create an Achievement Unlocked Callout
    .EXAMPLE
    PS> write-hostCallOutTDO -Object "Play stupid games. Win stupid prizes." -LabelOverride "✨Stupid Prize✨: $([char]0x26B0) " -type Dead

        > ☠ **✨Stupid Prize✨: ⚰ **
        >
        >	Play Stupid GAMES. Win Stupid PRIZES.
        >

    Demo -LabelOverride use with existing Dead Callout, to create a Stupid Prize Callout
    .EXAMPLE
    PS> write-hostCallOutTDO -Object "[Your pithy thought here]" -BackgroundColor DarkMagenta -ForegroundColor DarkYellow -type Random -Tight 

        > 👍 **OK**
        >	[Your pithy thought here]


    Demo -BackgroundColor -ForegroundColorDead override, with Type Random Callout and -Tight switch.
    #>
    [CmdletBinding()]
    [Alias('w-hCO','write-hostCallOut','write-hostAlert')]
    PARAM(
        [Parameter(
            HelpMessage="The string representations of the input objects are concatenated to form the output. No spaces or newlines are inserted between
the output strings. No newline is added after the last output string.")]
            [System.Management.Automation.SwitchParameter]$NoNewline,
        [Parameter(Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,
            HelpMessage="Objects to display in the host")]
            [System.Object]$Object,
        [Parameter(
            HelpMessage="String that overrides a given type's default Label string[-LabelOverride 'Achievement Unlocked']")]
            [string]$LabelOverride,
        [Parameter(
            HelpMessage="Specifies a separator string to insert between objects displayed by the host.")]
            [System.Object]$Separator,
        [Parameter(
            HelpMessage="Callout type to display (Caution|Note|Tip|Important|Warning|Dead|Example|Error|Fix|Info|Joke|Label|Medal|OK|Reference|Success|Trophy|Unlock|Demo|Random)[-Type 'Note']")]
            [ValidateSet('Caution','Note','Tip','Important','Warning','Dead','Example','Error','Fix','Info','Joke','Label','Medal','OK','Reference','Success','Trophy','Unlock','Demo','Random')]
            [string]$Type,
         [Parameter(
            HelpMessage="Specifies the background color. There is no default. The acceptable values for this parameter are:
            (Black | DarkBlue | DarkGreen | DarkCyan | DarkRed | DarkMagenta | DarkYellow | Gray | DarkGray | Blue | Green | Cyan | Red | Magenta | Yellow | White)")]
            [System.ConsoleColor]$BackgroundColor,
        [Parameter(
            HelpMessage="Specifies the text color. There is no default. The acceptable values for this parameter are:
            (Black | DarkBlue | DarkGreen | DarkCyan | DarkRed | DarkMagenta | DarkYellow | Gray | DarkGray | Blue | Green | Cyan | Red | Magenta | Yellow | White)")]
            [System.ConsoleColor]$ForegroundColor,
        [Parameter(
            HelpMessage="Switch to disable all auto-wrapping[-NoWrap]")]
            [switch]$NoWrap,
        [Parameter(
            HelpMessage="Integer number of characters at which to autowrap -Object (defaults to 60)[-Type '-WrapChars 30']")]
            [int]$WrapChars=80,
        [Parameter(
            HelpMessage="Switch that suppresses vertical extra lines in the output.[-Tight]")]
            [switch]$Tight
    ) ;
    BEGIN {
        #region CONSTANTS-AND-ENVIRO #*======v CONSTANTS-AND-ENVIRO v======
        ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
        if(($PSBoundParameters.keys).count -ne 0){
            $PSParameters = New-Object -TypeName PSObject -Property $PSBoundParameters ;
            write-verbose "$($CmdletName): `$PSBoundParameters:`n$(($PSBoundParameters|out-string).trim())" ;
        } ;
        $Verbose = ($VerbosePreference -eq 'Continue') ;
        #endregion CONSTANTS-AND-ENVIRO #*======^ END CONSTANTS-AND-ENVIRO ^======

        $pltWH = @{} ;

        if ($PSBoundParameters.ContainsKey('NoNewline')) {
            $pltWH.add('NoNewline',$NoNewline) ;
        } ;
        if ($PSBoundParameters.ContainsKey('Separator')) {
            $pltWH.add('Separator',$Separator) ;
        } ;
        
        <# if $object has multiple lines, split it:
        TRY{
            #$Object = $Object.Split([Environment]::NewLine) ;
            [string[]]$Object = [string[]]$Object.ToString().Split([Environment]::NewLine) ; 
        } CATCH{
            write-verbose "Workaround err: The variable cannot be validated because the value System.String[] is not a valid value for the Object variable." ; 
            [string[]]$Object = ($Object|out-string).trim().Split([Environment]::NewLine) ; 
        } ; 
        #>

        # type is frequently used as the $Label, pre TitleCase it (to ensure consistent casing, regardless of case user uses on -Type spec)
        $txtInfo=(get-culture).TextInfo ;
        $type = $($txtInfo.ToTitleCase($type.toLower())) ; 

        if($Type -eq 'Random'){
            $Types = 'Caution','Note','Tip','Important','Warning','Dead','Example','Error','Fix','Info','Joke','Label','Medal','OK','Reference','Success','Trophy','Unlock' | get-random ; 
            write-verbose "-type:Random -> picked '$($Type)'" ; 
        } elseif($Type -eq 'Demo'){
            $Types = 'Caution','Note','Tip','Important','Warning','Dead','Example','Error','Fix','Info','Joke','Label','Medal','OK','Reference','Success','Trophy','Unlock' ; 
            write-verbose "-type:Demo: cycling full set'" ; 
        } else {
            $Types = $Type ; 
        } ; 

    } ;  # BEG-E
    PROCESS{
        
        $whCallOut = @{
            Object= $null ; 
            BackgroundColor=$null ; 
            ForegroundColor=$null ; 
            NoNewLine = $($NoNewLine) ; 
        } ;
        foreach($CType in $Types){
            switch -regex ($CType){
                'Important' {
                    # Note: PsCodePoint is an array: 0:the unicode string; 1: an alternate 'raw text' string to use for down-rev output (non-WinTerm/ISE)
                    $PsCodePoint='0X1F5EF','{!}' ; # 💬
                    $Label = 'Important'
                    $whCallOut.BackgroundColor = 'Magenta' ;
                    $whCallOut.ForegroundColor = 'Yellow' ;
                }
                'Note|Info|Label|Reference' {
                    switch ($CType){
                        'Note' {
                            $PsCodePoint='0x2139','(i)' ; # ℹ
                            $Label = $CType
                        }
                        'Info' {
                            $PsCodePoint='0x2139','(i)' ; # ℹ
                            $Label = 'Information' ; 
                        }
                        'Label' {
                            $PsCodePoint='0x1f3f7','(i)' ;  # 🏷
                            $Label = 'Note' ; 
                        } ;
                        'Reference' {
                            $PsCodePoint='0x1F4D8','[Ref]' ; # 📘
                            $Label = $CType ; 
                        } ;
                    } ; 
                    $whCallOut.BackgroundColor = 'White' ;
                    $whCallOut.ForegroundColor = 'DarkGreen' ;
                }
                'Tip' {
                    $PsCodePoint='0x1F4A1',';-)' ; # 💡
                    $Label = $CType ; 
                    $whCallOut.BackgroundColor = 'DarkGreen' ;
                    $whCallOut.ForegroundColor = 'yellow' ;
                }
                'Warning|Caution' {
                    switch ($CType){
                        'Warning' {
                            $PsCodePoint='0x26A0','/!\' ; # ⚠
                            $Label = $CType
                        }
                        'Caution' {
                            $PsCodePoint='0x1F6D1','/!\' ; # 🛑️ Caution
                            $Label = $CType ; 
                        }
                    } ; 
                    $whCallOut.BackgroundColor = 'Yellow' ;
                    $whCallOut.ForegroundColor = 'Black' ;
                }
                'Example' {
                    $PsCodePoint='0x1F4F7','[1.2.3.]' ; #  📷
                    $Label = 'Example'
                    $whCallOut.BackgroundColor = 'White' ;
                    $whCallOut.ForegroundColor = 'Blue' ;
                }
                'Error' {
                    $PsCodePoint='0x1F6D1',">:(" ; #  🛑
                    $Label = $CType ; 
                    $whCallOut.BackgroundColor = 'DarkRed' ;
                    $whCallOut.ForegroundColor = 'Yellow' ;
                }
                'Fix' {
                    $PsCodePoint='0x1F6E0','>:\' ; # 🛠 
                    $Label = 'Fix'
                    $whCallOut.BackgroundColor = 'DarkYellow' ;
                    $whCallOut.ForegroundColor = 'Black' ;
                }
                'OK|Success' {
                    switch ($CType){
                        'OK' {
                            $PsCodePoint='0x1F44D',':-)' ; #  👍 
                        }
                        'Success' {
                            $PsCodePoint='0x2705',':-D' ; #  ✅
                        }                    
                    } ; 
                    $Label = $CType ; 
                    $whCallOut.BackgroundColor = 'DarkGreen' ;
                    $whCallOut.ForegroundColor = 'White' ;
                }
                'Dead' {
                    $PsCodePoint='0x2620',"(+_+)" ; #  ☠
                    $Label = $CType ; 
                    $whCallOut.BackgroundColor = 'Black' ;
                    $whCallOut.ForegroundColor = 'White' ;
                }
                'Unlock|Trophy|Medal' {
                    switch ($CType){
                        'Unlock' {
                            $PsCodePoint='0x1F513',"c█" ; # 🔓
                            $Label = 'Unlocked' ; 
                        } 
                        'Trophy' {
                            $PsCodePoint='0x1F3C6','\(^o^)/' ; #  🏆
                            $Label = 'Achievement Unlocked' ; 
                        }
                        'Medal' {
                            $PsCodePoint='0x1F396','\(^o^)/' ; #  🎖️
                            $Label = 'Achievement Unlocked' ; 
                        }
                    }
                    $whCallOut.BackgroundColor = 'DarkYellow' ;
                    $whCallOut.ForegroundColor = 'DarkBlue' ;
                } 
                'Joke' {
                    $PsCodePoint='0x1F921',"(^O^)" ; #  🤡
                    $Label = $CType ; 
                    $whCallOut.BackgroundColor = 'Blue' ;
                    $whCallOut.ForegroundColor = 'Yellow' ;
                }
                default{
                    throw "Unrecognized -Type:$($CType)" ; 
                    break ; 
                }
            } ; 
            foreach($obj in $Object){
                $glyph = if (($env:WT_SESSION) -OR ($psise) -OR ($env:TERM_PROGRAM -eq 'vscode')){ try{[char]$PsCodePoint[0] }catch{ [char]::ConvertFromUtf32($PsCodePoint[0])} }else { $PsCodePoint[1] } ;
                            
                if(-not $NoWrap){
                    write-verbose "-NoWrap: Suppressing auto-linewrapping" ; 
                    if((get-command wrap-text -ea 0) -AND $obj -notcontains "`n"){$obj = ($obj | wrap-text -Characters $WrapChars).trim() } ;    
                } ; 
                if(-not $Tight){
                    $prompt = "`n>`n>`t$(($obj.split("`n") ) -join "`n>`t")`n>`n"
                } else { 
                    #$prompt = "`n>`t$(($obj.split("`n") ) -join "`n>`t")`n>"
                    # drop trailing >
                    $prompt = "`n>`t$(($obj.split("`n") ) -join "`n>`t")`n"
                } ; 

                <#$whCallOut = @{
                    Object= "`n`n> $($glyph) **$($Label)**$($prompt)`n`n" ;
                    BackgroundColor=$BackgroundColor ; 
                    ForegroundColor=$ForegroundColor ; 
                    NoNewLine = $($NoNewLine) ; 
                } ;
                #>
                if(-not $Tight){
                    $whCallOut.Object= "`n`n> $($glyph) **$($Label)**$($prompt)`n`n" ;
                } else { 
                    $whCallOut.Object= "`n> $($glyph) **$($Label)**$($prompt)`n" ;
                } ; 

                # override default values, via parameters:
                if($LabelOverride){
                     $whCallOut.Object= "`n`n> $($glyph) **$($LabelOverride)**$($prompt)`n`n" ;
                } ; 
                if($BackgroundColor){
                     $whCallOut.BackgroundColor= $BackgroundColor ;
                } ; 
                if($ForegroundColor){
                     $whCallOut.ForegroundColor= $ForegroundColor ;
                } ; 
                $smsg = "write-host w`n$(($whCallOut|out-string).trim())" ; 
                $smsg += "`n`$Object`n$(($Object|out-string).trim())" ; 
                write-verbose $smsg ; 
                write-host @whCallOut ;         
        
                <#
                foreach ($obj in $obj){
                    Write-Host -NoNewline $($PadChar * $CurrIndent)  ;
                    write-host @pltWH -object $obj ;
                } ;
                #>
            } ;
        } ;; 
    } ;  # PROC-E
} ; 
#*------^ END Function write-hostCallOutTDO ^------
