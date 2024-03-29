﻿# Get-KnownFolderTDO.ps1

# Get-KnownFolderTDO.ps1 

# #*------v Get-KnownFolderTDO.ps1 v------
Function Get-KnownFolderTDO {
    <#
    .SYNOPSIS
    Get-KnownFolderTDO.ps1 - Resolves Special Folders (including those not supported by [Environment]::GetFolderPath), from the underlying ShGetKnownFolderPath  function.
    .NOTES
    Version     : 1.0.0
    Author      : (unknown)
    Website     : 
    Twitter     : 
    CreatedDate : 2023-12-12
    FileName    : Get-KnownFolderTDO.ps1
    License     : (none asserted)
    Copyright   : (none asserted)
    Github      : https://github.com/tostka/verb-IO
    Tags        : Powershell,development,filesystem,SpecialFolders
    AddedCredit : Todd Kadrie
    AddedWebsite: http://www.toddomation.com
    AddedTwitter: @tostka / http://twitter.com/tostka
    REVISION
    * 12:29 PM 1/5/2024 init
    * 4/26/93 rmbolger posted reddit copy (undocumented inet source)
    .DESCRIPTION
    Get-KnownFolderTDO.ps1 - Resolves Special Folders (including those not properly supported by [Environment]::GetFolderPath), from the underlying ShGetKnownFolderPath  function.

    From rmbolger's reddit post:
    [Using [Environment]::GetFolderPath to find Downloads folder : r/PowerShell](https://www.reddit.com/r/PowerShell/comments/12zh5uh/using_environmentgetfolderpath_to_find_downloads/)


        [rmbolger](https://www.reddit.com/user/rmbolger/)
        u/rmbolger
        Jul 18, 2018
        388
        Post Karma
        2,175

        • [8 mo. ago](https://www.reddit.com/r/PowerShell/comments/12zh5uh/comment/jhst9rq/)

        The registry key mentioned by ...

        > purplemonkeymad
        > •
        > 8 mo. ago
        > 
        > Downloads folder appears to be special, but you should be able to get it from the registry:
        > 
        > Get-ItemPropertyValue "hkcu:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" "{374DE290-123F-4565-9164-39C4925E467B}"
        > 
        ... is not intended to be used for this purpose and may not be correct for all users depending on how folder redirection is setup. If your use-case is limited and you don't care about the code being future proof, it may work in a pinch though.

        If you browse that registry location with regedit, you will see a value called `!Do not use this registry key` with the data `Use the SHGetFolderPath or SHGetKnownFolderPath function instead`. For more background on the key and its history, see these posts.

        [Why is there the message '!Do not use this registry key' in the registry?](https://devblogs.microsoft.com/oldnewthing/20110322-00/?p=11163)

        [The long and sad story of the Shell Folders key](https://devblogs.microsoft.com/oldnewthing/20031103-00/?p=41973)

        The `[Environment]::GetFolderPath` method you tried to use _should be_ the right way to do this. But it requires a valid value from the [Environment.SpecialFolder Enum](https://learn.microsoft.com/en-us/dotnet/api/system.environment.specialfolder) which doesn't contain a value relating to the Downloads folder.

        The best workaround I've found is to P/Invoke the underlying `ShGetKnownFolderPath` function. Here's a wrapper function I found.

        [trimmed posted copy of source for this function]

        ## KnownFolderIDs that work with [Environment]::getFolderPath('KnownFolderID')

        ([Environment+SpecialFolder]::GetNames([Environment+SpecialFolder]) | SORT ) -join ', ' ; 
        Output:
        AdminTools, ApplicationData, CDBurning, CommonAdminTools, 
        CommonApplicationData, CommonDesktopDirectory, CommonDocuments, CommonMusic, 
        CommonOemLinks, CommonPictures, CommonProgramFiles, CommonProgramFilesX86, 
        CommonPrograms, CommonStartMenu, CommonStartup, CommonTemplates, CommonVideos, 
        Cookies, Desktop, DesktopDirectory, Favorites, Fonts, History, InternetCache, 
        LocalApplicationData, LocalizedResources, MyComputer, MyDocuments, MyMusic, 
        MyPictures, MyVideos, NetworkShortcuts, Personal, PrinterShortcuts, 
        ProgramFiles, ProgramFilesX86, Programs, Recent, Resources, SendTo, StartMenu, 
        Startup, System, SystemX86, Templates, UserProfile, Windows 

        ## Listing of CLSIDs for Known folders:

        ### Windows: known folders

        (Posted at: [Windows: known folders](https://renenyffenegger.ch/notes/Windows/dirs/_known-folders))

        Name                     | CLSID/GUID                             | Equiv Environment variable
        ------------------------ | -------------------------------------- | -----------------------------------------------------------------------------------
        3D Objects               | {31C0DD25-9439-4F12-BF41-7FF4EDA38722} | %USERPROFILE%\3D Objects
        Account Pictures         | {008CA0B1-55B4-4C56-B8A8-4DE4B299D3BE} | %APPDATA%\Microsoft\Windows\AccountPictures
        Administrative Tools     | {724EF170-A42D-4FEF-9F26-B60E846FBA4F} | %APPDATA%\Microsoft\Windows\Start Menu\Programs\Administrative Tools
        Administrative Tools     | {D0384E7D-BAC3-4797-8F14-CBA229B392B5} | %ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Administrative Tools
        AppDataDesktop           | {B2C5E279-7ADD-439F-B28C-C41FE1BBF672} | %LOCALAPPDATA%\Desktop
        AppDataDocuments         | {7BE16610-1F7F-44AC-BFF0-83E15F2FFCA1} | %LOCALAPPDATA%\Documents
        AppDataFavorites         | {7CFBEFBC-DE1F-45AA-B843-A542AC536CC9} | %LOCALAPPDATA%\Favorites
        AppDataProgramData       | {559D40A3-A036-40FA-AF61-84CB430A4D34} | %LOCALAPPDATA%\ProgramData
        Application Shortcuts    | {A3918781-E5F2-4890-B3D9-A7E54332328C} | %LOCALAPPDATA%\Microsoft\Windows\Application Shortcuts
        Applications             | {1E87508D-89C2-42F0-8A7E-645A0F50CA58} | Virtual folder
        Camera Roll              | {767E6811-49CB-4273-87C2-20F355E1085B} | %USERPROFILE%\OneDrive\Pictures\Camera Roll
        Camera Roll              | {AB5FB87B-7CE2-4F83-915D-550846C9537B} | %USERPROFILE%\Pictures\Camera Roll
        Common Files             | {6365D5A7-0F0D-45E5-87F6-0DA56B6A4F7D} | %ProgramFiles%\Common Files
        Common Files             | {DE974D24-D9C6-4D3E-BF91-F4455120B917} | %ProgramFiles%\Common Files
        Common Files             | {F7F1ED05-9F6D-47A2-AAAE-29D317C6F066} | %ProgramFiles%\Common Files
        Computer                 | {0AC0837C-BBF8-452A-850D-79D08E667CA7} | virtual folder
        Conflicts                | {4BFEFB45-347D-4006-A5BE-AC0CB0567192} | virtual folder
        Contacts                 | {56784854-C6CB-462B-8169-88E350ACB882} | %USERPROFILE%\Contacts
        Control Panel            | {82A74AEB-AEB4-465C-A014-D097EE346D63} | virtual folder
        Cookies                  | {2B0F765D-C0E9-4171-908E-08A611B84FF6} | %APPDATA%\Microsoft\Windows\Cookies
        Desktop                  | {B4BFCC3A-DB2C-424C-B029-7FE99A87C641} | %USERPROFILE%\Desktop
        DeviceMetadataStore      | {5CE4A5E9-E4EB-479D-B89F-130C02886155} | %ALLUSERSPROFILE%\Microsoft\Windows\DeviceMetadataStore
        Documents                | {24D89E24-2F19-4534-9DDE-6A6671FBB8FE} | %USERPROFILE%\OneDrive\Documents
        Documents                | {7B0DB17D-9CD2-4A93-9733-46CC89022E7C} | %APPDATA%\Microsoft\Windows\Libraries\Documents.library-ms
        Documents                | {FDD39AD0-238F-46AF-ADB4-6C85480369C7} | %USERPROFILE%\Documents
        Downloads                | {374DE290-123F-4565-9164-39C4925E467B} | %USERPROFILE%\Downloads or %HOMEDRIVE%%HOMEPATH%\Downloads
        Favorites                | {1777F761-68AD-4D8A-87BD-30B759FA33DD} | %USERPROFILE%\Favorites
        Fonts                    | {FD228CB7-AE11-4AE3-864C-16F3910AB8FE} | %windir%\Fonts
        Gadgets                  | {7B396E54-9EC5-4300-BE0A-2482EBAE1A26} | %ProgramFiles%\Windows Sidebar\Gadgets
        Gadgets                  | {A75D362E-50FC-4FB7-AC2C-A8BEAA314493} | %LOCALAPPDATA%\Microsoft\Windows Sidebar\Gadgets
        GameExplorer             | {054FAE61-4DD8-4787-80B6-090220C4B700} | %LOCALAPPDATA%\Microsoft\Windows\GameExplorer
        GameExplorer             | {DEBF2536-E1A8-4C59-B6A2-414586476AEA} | %ALLUSERSPROFILE%\Microsoft\Windows\GameExplorer
        Games                    | {CAC52C1A-B53D-4EDC-92D7-6B2E8AC19434} | virtual folder
        Get Programs             | {DE61D971-5EBC-4F02-A3A9-6C82895E5C04} | Virtual folder
        History                  | {0D4C3DB6-03A3-462F-A0E6-08924C41B5D4} | %LOCALAPPDATA%\Microsoft\Windows\ConnectedSearch\History
        History                  | {D9DC8A3B-B784-432E-A781-5A1130A75963} | %LOCALAPPDATA%\Microsoft\Windows\History
        Homegroup                | {52528A6B-B9E3-4ADD-B60D-588C2DBA842D} | virtual folder
        ImplicitAppShortcuts     | {BCB5256F-79F6-4CEE-B725-DC34E402FD46} | %APPDATA%\Microsoft\Internet Explorer\Quick Launch\User Pinned\ImplicitAppShortcuts
        Installed Updates        | {A305CE99-F527-492B-8B1A-7E76FA98D6E4} | Virtual folder
        Libraries                | {1B3EA5DC-B587-4786-B4EF-BD1DC332AEAE} | %APPDATA%\Microsoft\Windows\Libraries
        Libraries                | {48DAF80B-E6CF-4F4E-B800-0E69D84EE384} | %ALLUSERSPROFILE%\Microsoft\Windows\Libraries
        Libraries                | {A302545D-DEFF-464B-ABE8-61C8648D939B} | virtual folder
        Links                    | {BFB9D5E0-C6A9-404C-B2B2-AE6DB6AF4968} | %USERPROFILE%\Links
        Local                    | {F1B32785-6FBA-4FCF-9D55-7B8E7F157091} | %LOCALAPPDATA% (%USERPROFILE%\AppData\Local)
        LocalLow                 | {A520A1A4-1780-4FF6-BD18-167343C5AF16} | %USERPROFILE%\AppData\LocalLow
        Microsoft Office Outlook | {98EC0E18-2098-4D44-8644-66979315A281} | virtual folder
        Music                    | {2112AB0A-C86A-4FFE-A368-0DE96E47012E} | %APPDATA%\Microsoft\Windows\Libraries\Music.library-ms
        Music                    | {4BD8D571-6D19-48D3-BE97-422220080E43} | %USERPROFILE%\Music
        Network                  | {D20BEEC4-5CA8-4905-AE3B-BF251EA09B53} | virtual folder
        Network Connections      | {6F0CD92B-2E97-45D1-88FF-B0D186B8DEDD} | virtual folder
        Network Shortcuts        | {C5ABBF53-E17F-4121-8900-86626FC2C973} | %APPDATA%\Microsoft\Windows\Network Shortcuts
        None                     | {2A00375E-224C-49DE-B8D1-440DF7EF3DDC} | %windir%\resources\0409 (code page)
        OEM Links                | {C1BAE2D0-10DF-4334-BEDD-7AA20B227A9D} | %ALLUSERSPROFILE%\OEM Links
        Offline Files            | {EE32E446-31CA-4ABA-814F-A5EBD2FD6D5E} | virtual folder
        OneDrive                 | {A52BBA46-E9E1-435F-B3D9-28DAA648C0F6} | %USERPROFILE%\OneDrive
        Original Images          | {2C36C0AA-5812-4B87-BFD0-4CD0DFB19B39} | %LOCALAPPDATA%\Microsoft\Windows Photo Gallery\Original Images
        Pictures                 | {339719B5-8C47-4894-94C2-D8F77ADD44A6} | %USERPROFILE%\OneDrive\Pictures
        Pictures                 | {33E28130-4E1E-4676-835A-98395C3BC3BB} | %USERPROFILE%\Pictures
        Pictures                 | {A990AE9F-A03B-4E80-94BC-9912D7504104} | %APPDATA%\Microsoft\Windows\Libraries\Pictures.library-ms
        Playlists                | {DE92C1C7-837F-4F69-A3BB-86E631204A23} | %USERPROFILE%\Music\Playlists
        Printer Shortcuts        | {9274BD8D-CFD1-41C3-B35E-B13F55A758F4} | %APPDATA%\Microsoft\Windows\Printer Shortcuts
        Printers                 | {76FC4E2D-D6AD-4519-A663-37BD56068185} | virtual folder
        Program Files            | {6D809377-6AF0-444B-8957-A3773F02200E} | %ProgramFiles% (%SystemDrive%\Program Files)
        Program Files            | {7C5A40EF-A0FB-4BFC-874A-C0F2E0B9FA8E} | %ProgramFiles% (%SystemDrive%\Program Files)
        Program Files            | {905E63B6-C1BF-494E-B29C-65B732D3D21A} | %ProgramFiles% (%SystemDrive%\Program Files)
        ProgramData              | {62AB5D82-FDC1-4DC3-A9DD-070D1D495D97} | %ALLUSERSPROFILE% (%ProgramData%, %SystemDrive%\ProgramData)
        Programs                 | {0139D44E-6AFE-49F2-8690-3DAFCAE6FFB8} | %ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs
        Programs                 | {5CD7AEE2-2219-4A67-B85D-6C9CE15660CB} | %LOCALAPPDATA%\Programs
        Programs                 | {A77F5D77-2E2B-44C3-A6A2-ABA601054A51} | %APPDATA%\Microsoft\Windows\Start Menu\Programs
        Programs                 | {BCBD3057-CA5C-4622-B42D-BC56DB0AE516} | %LOCALAPPDATA%\Programs\Common
        Programs and Features    | {DF7266AC-9274-4867-8D55-3BD661DE872D} | Virtual folder
        Public                   | {DFDF76A2-C82A-4D63-906A-5644AC457385} | %PUBLIC% (%SystemDrive%\Users\Public)
        Public Account Pictures  | {0482AF6C-08F1-4C34-8C90-E17EC98B1E17} | %PUBLIC%\AccountPictures
        Public Desktop           | {C4AA340D-F20F-4863-AFEF-F87EF2E6BA25} | %PUBLIC%\Desktop
        Public Documents         | {ED4824AF-DCE4-45A8-81E2-FC7965083634} | %PUBLIC%\Documents
        Public Downloads         | {3D644C9B-1FB8-4F30-9B45-F670235F79C0} | %PUBLIC%\Downloads
        Public Music             | {3214FAB5-9757-4298-BB61-92A9DEAA44FF} | %PUBLIC%\Music
        Public Pictures          | {B6EBFB86-6907-413C-9AF7-4FC2ABF07CC5} | %PUBLIC%\Pictures
        Public Videos            | {2400183A-6185-49FB-A2D8-4A392A602BA3} | %PUBLIC%\Videos
        Quick Launch             | {52A4F021-7B75-48A9-9F6B-4B87A210BC8F} | %APPDATA%\Microsoft\Internet Explorer\Quick Launch
        Recent Items             | {AE50C081-EBD2-438A-8655-8A092E34987A} | %APPDATA%\Microsoft\Windows\Recent
        Recorded TV              | {1A6FDBA2-F42D-4358-A798-B74D745926C5} | %PUBLIC%\RecordedTV.library-ms
        Recycle Bin              | {B7534046-3ECB-4C18-BE4E-64CD4CB7D6AC} | virtual folder
        Resources                | {8AD10C31-2ADB-4296-A8F7-E4701232C972} | %windir%\Resources
        Ringtones                | {C870044B-F49E-4126-A9C3-B52A1FF411E8} | %LOCALAPPDATA%\Microsoft\Windows\Ringtones
        Ringtones                | {E555AB60-153B-4D17-9F04-A5FE99FC15EC} | %ALLUSERSPROFILE%\Microsoft\Windows\Ringtones
        RoamedTileImages         | {AAA8D5A5-F1D6-4259-BAA8-78E7EF60835E} | %LOCALAPPDATA%\Microsoft\Windows\RoamedTileImages
        Roaming                  | {3EB685DB-65F9-4CF6-A03A-E3EF65729F3D} | %APPDATA% (%USERPROFILE%\AppData\Roaming)
        RoamingTiles             | {00BCFC5A-ED94-4E48-96A1-3F6217F21990} | %LOCALAPPDATA%\Microsoft\Windows\RoamingTiles
        Sample Music             | {B250C668-F57D-4EE1-A63C-290EE7D1AA1F} | %PUBLIC%\Music\Sample Music
        Sample Pictures          | {C4900540-2379-4C75-844B-64E6FAF8716B} | %PUBLIC%\Pictures\Sample Pictures
        Sample Playlists         | {15CA69B3-30EE-49C1-ACE1-6B5EC372AFB5} | %PUBLIC%\Music\Sample Playlists
        Sample Videos            | {859EAD94-2E85-48AD-A71A-0969CB56A6CD} | %PUBLIC%\Videos\Sample Videos
        Saved Games              | {4C5C32FF-BB9D-43B0-B5B4-2D72E54EAAA4} | %USERPROFILE%\Saved Games
        Saved Pictures           | {3B193882-D3AD-4EAB-965A-69829D1FB59F} | %USERPROFILE%\Pictures\Saved Pictures
        Saved Pictures Library   | {E25B5812-BE88-4BD9-94B0-29233477B6C3} | %APPDATE%\Microsoft\Windows\Libraries\SavedPictures.library-ms
        Screenshots              | {B7BEDE81-DF94-4682-A7D8-57A52620B86F} | %USERPROFILE%\Pictures\Screenshots
        Search Results           | {190337D1-B8CA-4121-A639-6D472D16972A} | virtual folder
        Searches                 | {7D1D3A04-DEBB-4115-95CF-2F29DA2920DA} | %USERPROFILE%\Searches
        SendTo                   | {8983036C-27C0-404B-8F08-102D10DCFD74} | %APPDATA%\Microsoft\Windows\SendTo
        Slide Shows              | {69D2CF90-FC33-4FB7-9A0C-EBB0F0FCB43C} | %USERPROFILE%\Pictures\Slide Shows
        Start Menu               | {625B53C3-AB48-4EC1-BA1F-A1EF4146FC19} | %APPDATA%\Microsoft\Windows\Start Menu
        Start Menu               | {A4115719-D62E-491D-AA7C-E74B8BE3B067} | %ALLUSERSPROFILE%\Microsoft\Windows\Start Menu
        Startup                  | {82A5EA35-D9CD-47C5-9629-E15D2F714E6E} | %ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\StartUp
        Startup                  | {B97D20BB-F46A-4C97-BA10-5E3608430854} | %APPDATA%\Microsoft\Windows\Start Menu\Programs\StartUp
        Sync Center              | {43668BF8-C14E-49B2-97C9-747784D784B7} | virtual folder
        Sync Results             | {289A9A43-BE44-4057-A41B-587A76D7E7F9} | virtual folder
        Sync Setup               | {0F214138-B1D3-4A90-BBA9-27CBC0C5389A} | virtual folder
        System32                 | {1AC14E77-02E7-4E5D-B744-2EB1AE5198B7} | %windir%\system32
        System32                 | {D65231B0-B2F1-4857-A4CE-A8E7C6EA7D27} | %windir%\system32
        Templates                | {7E636BFE-DFA9-4D5E-B456-D7B39851D8A9} | %LOCALAPPDATA%\Microsoft\Windows\ConnectedSearch\Templates
        Templates                | {A63293E8-664E-48DB-A079-DF759E0509F7} | %APPDATA%\Microsoft\Windows\Templates
        Templates                | {B94237E7-57AC-4347-9151-B08C6C32D1F7} | %ALLUSERSPROFILE%\Microsoft\Windows\Templates
        Temporary Burn Folder    | {9E52AB10-F80D-49DF-ACB8-4330F5687855} | %LOCALAPPDATA%\Microsoft\Windows\Burn\Burn (?)
        Temporary Internet Files | {352481E8-33BE-4251-BA85-6007CAEDCF9D} | %LOCALAPPDATA%\Microsoft\Windows\Temporary Internet Files
        The Internet             | {4D9F7874-4E0C-4904-967B-40B0D20C3E4B} | virtual folder
        The user's full name     | {F3CE0F7C-4901-4ACC-8648-D5D44B04EF8F} | virtual folder
        User Pinned              | {9E3995AB-1F9C-4F13-B827-48B24B6C7174} | %APPDATA%\Microsoft\Internet Explorer\Quick Launch\User Pinned
        Users                    | {0762D272-C50A-4BB0-A382-697DCD729B80} | %SystemDrive%\Users
        Videos                   | {18989B1D-99B5-455B-841C-AB7C74E4DDFC} | %USERPROFILE%\Videos
        Videos                   | {491E922F-5643-4AF4-A7EB-4E7A138D8174} | %APPDATA%\Microsoft\Windows\Libraries\Videos.library-ms
        Windows                  | {F38BF404-1D43-42F2-9305-67DE0B28FC23} | %windir%
        %USERNAME%               | {5E6C858F-0E22-4760-9AFE-EA3317B67173} | %USERPROFILE% (%SystemDrive%\Users\%USERNAME%)
        %USERNAME%               | {9B74B6A3-0DFD-4F11-9E78-5F7800F2E772} | virtual folder

    .PARAMETER KnownFolderCLSID
    System CLSID for a Special Folder
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    System.string
    .EXAMPLE
    PS> Get-KnownFolderTDO '{374DE290-123F-4565-9164-39C4925E467B}';
    Resolve the CLSID for 'Downloads' to the current user's folder
    .LINK
    https://github.com/tostka/verb-IO
    https://www.reddit.com/r/PowerShell/comments/12zh5uh/using_environmentgetfolderpath_to_find_downloads/
    #>
    [CmdletBinding()]
    #[Alias('expand-ISOFile')]
    #[OutputType([boolean])]
    PARAM (
        [Parameter(Mandatory = $False,Position = 0,ValueFromPipeline = $True, HelpMessage = "System CLSID for a Special Folder[-KnownFolderCLSID '{374DE290-123F-4565-9164-39C4925E467B}'")]
            #[Alias('PsPath')]
            [string]$KnownFolderCLSID        
    ) ;
    $KnownFolderCLSID = $KnownFolderCLSID.Replace('{','').Replace('}','') ; 
    $GetSignature = @'
        [DllImport("shell32.dll", CharSet = CharSet.Unicode)]public extern static int SHGetKnownFolderPath(
        ref Guid folderId,
        uint flags,
        IntPtr token,
        out IntPtr pszProfilePath);
'@
    $GetType = Add-Type -MemberDefinition $GetSignature -Name 'GetKnownFolders' -Namespace 'SHGetKnownFolderPath' -Using "System.Text" -PassThru -ErrorAction SilentlyContinue ; 
    $ptr = [intptr]::Zero ; 
    [void]$GetType::SHGetKnownFolderPath([Ref]"$KnownFolderCLSID", 0, 0, [ref]$ptr) ; 
    $result = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($ptr) ; 
    [System.Runtime.InteropServices.Marshal]::FreeCoTaskMem($ptr) ; 
    return $result ; 
}
#*------^ Get-KnownFolderTDO.ps1 ^------
