
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
    * 3:49 PM 9/12/2024 corrected Important emoji; added Tcase to the $type user entered (as it's used in some, to drive labeling variants); fixed high ascii in the face ascii emojis (dash wasn't a stock -) ; init

    .DESCRIPTION

    write-hostCallOutTDO - wrapper for write-host that implements a formatted 'markdown-style' Callout console output. 

    Under WinTerm or ISE, displays suitable Unicode Icon/Emoji. 
    Under stock Console, displays a plain text alterantive. 

    Supports following types, 

    Important
    Note
    Info
    Label
    Tip
    Warning
    Caution
    Demo
    Error
    Fix
    OK
    Success

    emulating Markdown Callouts, a typical implementation, the GitHub flavor, is described here:

    [New Markdown extension: Alerts provide distinctive styling for significant content - GitHub Changelog](https://github.blog/changelog/2023-12-14-new-markdown-extension-alerts-provide-distinctive-styling-for-significant-content/)

    With formal documentation here:

    [Basic writing and formatting syntax - GitHub Docs](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax#alerts)

    And discussed further here:

    [Callouts - Example of markdown callouts](https://davidwells.io/typography/callouts)

    Which, in the above examples are rendered in Markdown as:

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

    Which in the implementation above render in raw markdown as:

    ```markdown
    [Callouts - Example of markdown callouts](https://davidwells.io/typography/callouts)

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

    This implementation aims to emulate the output, while substiting common emoji/unicode character alternatives (in WinTerm or ISE), or approximating keyboard characters (in native Console, which lacks high-code support).

    ## -Types supported:

    - Note
    - Fix
    - Tip
    - Pic
    - Error
    - Warn
    - OK
    - Info

    ## For Reference (expanding down the road, when looking for raw text emoji equivelents for native console)

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
    
    .PARAMETER NoNewline <System.Management.Automation.SwitchParameter>
    The string representations of the input objects are concatenated to form the output. No spaces or newlines are inserted between
    the output strings. No newline is added after the last output string.
    .PARAMETER Object
    Objects to display in the host.
    .PARAMETER Separator <System.Object>
    Specifies a separator string to insert between objects displayed by the host.
     .PARAMETER Type
    Callout type to display (Important|Note|Info|Label|Tip|Warning|Caution|Demo|Error|Fix|OK|Success|Random)[-Type 'Note']
    .PARAMETER NoWrap
    Switch to disable all auto-wrapping[-NoWrap]
    .PARAMETER WrapChars
    Integer number of characters at which to autowrap -Object (defaults to 60)[-Type '-WrapChars 30
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
    PS> $smsg = (new-loremstring -minWords 25 -minSentences 2 -numParagraphs 2) ; 
    PS> write-verbose "Cycle the variant Types through the text, using the Alias for write-hostCalloutTDO" ; 
    PS> 'Important','Note','Info','Label','Tip','Warning','Caution','Demo','Error','Fix','OK','Success'|%{w-hCO -obj $smsg -Type $_ -verbose} ;
    Demo each of the Callouts, in series.
    .EXAMPLE
    PS> fortune.ps1 |  ?{$_} | w-hCO -type Random -NoWrap ;
    Completely silly Callout, fed by a fortune app, outputing into a Random type Callout
    #>
    [CmdletBinding()]
    [Alias('w-hCO','write-hostAlert')]
    PARAM(
        [Parameter(
            HelpMessage="The string representations of the input objects are concatenated to form the output. No spaces or newlines are inserted between
the output strings. No newline is added after the last output string.")]
            [System.Management.Automation.SwitchParameter]$NoNewline,
        [Parameter(Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,
            HelpMessage="Objects to display in the host")]
            [System.Object]$Object,
        [Parameter(
            HelpMessage="Specifies a separator string to insert between objects displayed by the host.")]
            [System.Object]$Separator,
        [Parameter(
            HelpMessage="Callout type to display (Important|Note|Info|Label|Tip|Warning|Caution|Demo|Error|Fix|OK|Success|Random)[-Type 'Note']")]
            [ValidateSet('Important','Note','Info','Label','Tip','Warning','Caution','Demo','Error','Fix','OK','Success','Random')]
            [string]$Type,
        [Parameter(
            HelpMessage="Switch to disable all auto-wrapping[-NoWrap]")]
            [switch]$NoWrap,
        [Parameter(
            HelpMessage="Integer number of characters at which to autowrap -Object (defaults to 60)[-Type '-WrapChars 30']")]
            [int]$WrapChars=80
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
            $Type = 'Important','Note','Info','Label','Tip','Warning','Caution','Demo','Error','Fix','OK','Success' | get-random ; 
            write-verbose "-type:Random -> picked '$($Type)'" ; 
        } ; 
        switch -regex ($Type){
            'Important'{
                # Note: PsCodePoint is an array: 0:the unicode string; 1: an alternate 'raw text' string to use for down-rev output (non-WinTerm/ISE)
                $PsCodePoint='0X1F5EF','{!}' ; # 💬
                $Label = 'Important'
                $BackgroundColor='Magenta' ;
                $ForegroundColor='Yellow' ;
            }
            'Note|Info|Label'{
                switch ($type){
                    'Note' {
                        $PsCodePoint='0x2139','(i)' ; # ℹ
                        $Label = $Type
                    }
                    'Info' {
                        $PsCodePoint='0x2139','(i)' ; # ℹ
                        $Label = 'Information' ; 
                    }
                    'Label' {
                        $PsCodePoint='0x1f3f7','(i)' ;  # 🏷
                        $Label = 'Note' ; 
                    } ;
                } ; 
                $BackgroundColor='White' ;
                $ForegroundColor='DarkGreen' ;
            }
            'Tip'{
                $PsCodePoint='0x1F4A1',';-)' ; # 💡
                $Label = $Type ; 
                $BackgroundColor='Gray' ;
                $ForegroundColor='Black' ;
            }
            'Warning|Caution'{
                
                switch ($type){
                    'Warning' {
                        $PsCodePoint='0x26A0','/!\' ; # ⚠
                        $Label = $Type
                    }
                    'Caution' {
                        $PsCodePoint='0x1F6D1','/!\' ; # 🛑️ Caution
                        $Label = $Type ; 
                    }
                } ; 
                $BackgroundColor='Yellow' ;
                $ForegroundColor='Black' ;
            }
            'Demo'{
                $PsCodePoint='0x1F4F7','[1.2.3.]' ; #  📷
                $Label = 'Illustration'
                $BackgroundColor='White' ;
                $ForegroundColor='Blue' ;
            }
            'Error'{
                $PsCodePoint='0x1F6D1',">:(" ; #  🛑
                $Label = $type ; 
                $BackgroundColor='DarkRed' ;
                $ForegroundColor='Yellow' ;
            }
            'Fix'{
                $PsCodePoint='0x1F6E0','>:\' ; # 🛠 
                $Label = 'Fix'
                $BackgroundColor='DarkYellow' ;
                $ForegroundColor='Black' ;
            }
            'OK|Success'{
                switch ($type){
                    'OK' {
                        $PsCodePoint='0x1F44D',':-)' ; #  👍 
                    }
                    'Success' {
                        $PsCodePoint='0x2705',':-D' ; #  ✅
                    }
                } ; 
                $Label = $Type ; 
                $BackgroundColor='DarkGreen' ;
                $ForegroundColor='White' ;
            }
            default{
                throw "Unrecognized -Type:$($type)" ; 
                break ; 
            }
        } ; 
    } ;  # BEG-E
    PROCESS{
        foreach($obj in $Object){
            $glyph = if ($env:WT_SESSION -OR $psise){try{[char]$PsCodePoint[0]}catch{[char]::ConvertFromUtf32($PsCodePoint[0])}}else { $PsCodePoint[1]} ;

            
            if(-not $NoWrap){
                write-verbose "-NoWrap: Suppressing auto-linewrapping" ; 
                if((get-command wrap-text -ea 0) -AND $obj -notcontains "`n"){$obj = ($obj | wrap-text -Characters $WrapChars).trim() } ;    
            } ; 
            $prompt = "`n>`n>`t$(($obj.split("`n") ) -join "`n>`t")`n>`n"

            #$glyph = if ($env:WT_SESSION -OR $psise){ $PsCodePoint='0x1F4AC';try{[char]$PsCodePoint}catch{[char]::ConvertFromUtf32($PsCodePoint)}}else { '{!}'} ;
        
            $whCallOut = @{
                Object= "`n`n> $($glyph) **$($Label)**$($prompt)`n`n" ;
                BackgroundColor=$BackgroundColor ; 
                ForegroundColor=$ForegroundColor ; 
                NoNewLine = $($NoNewLine) ; 
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
    } ;  # PROC-E
} ; 
#*------^ END Function write-hostCallOutTDO ^------
