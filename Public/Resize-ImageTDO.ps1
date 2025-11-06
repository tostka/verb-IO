# Resize-ImageTDO.ps1

    #region RESIZE_IMAGE ; #*------v Resize-ImageTDO v------
    Function Resize-ImageTDO() {        
        <#
        .SYNOPSIS
        Resize-ImageTDO - Resize an image 
        .NOTES
        Version     : 0.0.
        Author      : Christopher Walker
        Website     : https://gist.github.com/someshinyobject/617bf00556bc43af87cd
        Twitter     : 
        CreatedDate : 2025-
        FileName    : Resize-ImageTDO.ps1
        License     : (none-asserted)
        Copyright   : (none-asserted)
        Github      : https://github.com/tostka/verb-io
        Tags        : Powershell,Graphics,Image,Resizing,Manipulation
        AddedCredit : Todd Kadrie
        AddedWebsite: http://www.toddomation.com
        AddedTwitter: @tostka / http://twitter.com/tostka
        REVISIONS
        * 2:28 PM 11/6/2025 fixed bug: it's creating png files named .jpg; Added explicit format on image extension & Added extension format support for the range documented at:
            [ImageFormat Class (System.Drawing.Imaging) Microsoft Learn https://learn.microsoft.com › Learn › .NET › API browser](https://learn.microsoft.com/en-us/dotnet/api/system.drawing.imaging.imageformat?view=windowsdesktop-9.0)
            Issue: 
                > When utilizing the System.Drawing namespace in PowerShell to save images, the 
                > default behavior of the Save() method without specifying an ImageFormat can 
                > result in a PNG file being created, even if the intention was to create a JPG. 
                > This is because System.Drawing.Imaging.ImageFormat.Png is often the default or 
                > inferred format in certain scenarios or when handling images with transparency. 
            - renamed to Resize-ImageTDO differentiate from orig (aliased orig name) and added to vio.
            - Ported copy bundled with Tony Redmond's posted New Teams Client bg conversion script, expanded CBH, added NameModifier to CBH, added HelpMessage to params

        .DESCRIPTION
        Resize-ImageTDO - Resize an image
        Resize an image based on a new given height or width or a single dimension and a maintain ratio flag. 
        The execution of this CmdLet creates a new file named "OriginalName_resized" and maintains the original
        file extension
        .PARAMETER Width
           The new width of the image. Can be given alone with the MaintainRatio flag
        .PARAMETER Height
           The new height of the image. Can be given alone with the MaintainRatio flag
        .PARAMETER ImagePath
           The path to the image being resized
        .PARAMETER MaintainRatio
           Maintain the ratio of the image by setting either width or height. Setting both width and height and also this parameter
           results in an error
        .PARAMETER Percentage
           Resize the image *to* the size given in this parameter. It's imperative to know that this does not resize by the percentage but to the percentage of
           the image.
        .PARAMETER SmoothingMode
           Sets the smoothing mode. Default is HighQuality.
        .PARAMETER InterpolationMode
           Sets the interpolation mode. Default is HighQualityBicubic.
        .PARAMETER PixelOffsetMode
           Sets the pixel offset mode. Default is HighQuality.
        .PARAMETER NameModifier
        String that is automatically appended to original file name as _`$NameModifier
        .INPUTS
        None. Does not accepted piped input.(.NET types, can add description)
        .OUTPUTS
        None. Returns no objects or output (.NET types)
        System.Boolean
        [| get-member the output to see what .NET obj TypeName is returned, to use here]
        .EXAMPLE
           Resize-ImageTDO -Height 45 -Width 45 -ImagePath "Path/to/image.jpg"
        .EXAMPLE
           Resize-ImageTDO -Height 45 -MaintainRatio -ImagePath "Path/to/image.jpg"
        .EXAMPLE
           #Resize to 50% of the given image
           Resize-ImageTDO -Percentage 50 -ImagePath "Path/to/image.jpg"    
        .LINK
        https://github.com/tostka/powershellbb/
        #>
        [CmdLetBinding(
            SupportsShouldProcess=$true, 
            PositionalBinding=$false,
            ConfirmImpact="Medium",
            DefaultParameterSetName="Absolute"
        )]
        PARAM (
            [Parameter(Mandatory=$True)]
                [ValidateScript({
                    $_ | ForEach-Object {
                        Test-Path $_
                    }
                })]
                [String[]]$ImagePath,
            [Parameter(Mandatory=$False,HelpMessage='Maintain the ratio of the image by setting either width or height. Setting both width and height and also this parameter results in an error')]
                [Switch]$MaintainRatio,
            [Parameter(Mandatory=$False, ParameterSetName="Absolute",HelpMessage='The new height of the image. Can be given alone with the MaintainRatio flag')]
                [Int]$Height,
            [Parameter(Mandatory=$False, ParameterSetName="Absolute",HelpMessage='The new width of the image. Can be given alone with the MaintainRatio flag')]
                [Int]$Width,
            [Parameter(Mandatory=$False, ParameterSetName="Percent",HelpMessage="Resize the image *to* the size given in this parameter. It's imperative to know that this does not resize by the percentage but to the percentage of
the image.")]
                [Double]$Percentage,
            [Parameter(Mandatory=$False,HelpMessage='Sets the smoothing mode. Default is HighQuality.')]
                [System.Drawing.Drawing2D.SmoothingMode]$SmoothingMode = "HighQuality",
            [Parameter(Mandatory=$False,HelpMessage='Sets the interpolation mode. Default is HighQualityBicubic.')]
                [System.Drawing.Drawing2D.InterpolationMode]$InterpolationMode = "HighQualityBicubic",
            [Parameter(Mandatory=$False,HelpMessage='Sets the pixel offset mode. Default is HighQuality.')]
                [System.Drawing.Drawing2D.PixelOffsetMode]$PixelOffsetMode = "HighQuality",
            [Parameter(Mandatory=$False,HelpMessage="String that is automatically appended to original file name as _`$NameModifier")]
                [String]$NameModifier = "resized"
        )
        BEGIN {
            If ($Width -and $Height -and $MaintainRatio) {
                Throw "Absolute Width and Height cannot be given with the MaintainRatio parameter."
            }
 
            If (($Width -xor $Height) -and (-not $MaintainRatio)) {
                Throw "MaintainRatio must be set with incomplete size parameters (Missing height or width without MaintainRatio)"
            }
 
            If ($Percentage -and $MaintainRatio) {
                Write-Warning "The MaintainRatio flag while using the Percentage parameter does nothing"
            }
        }
        PROCESS {
            Add-Type -AssemblyName 'System.Drawing'
            ForEach ($Image in $ImagePath) {
                $Path = (Resolve-Path $Image).Path
                $Dot = $Path.LastIndexOf(".")

                #Add name modifier (OriginalName_{$NameModifier}.jpg)
                $OutputPath = $Path.Substring(0,$Dot) + "_" + $NameModifier + $Path.Substring($Dot,$Path.Length - $Dot)
                $ext = $Path.Substring($Dot,$Path.Length - $Dot) ; 
                $OldImage = New-Object -TypeName System.Drawing.Bitmap -ArgumentList $Path
                # Grab these for use in calculations below. 
                $OldHeight = $OldImage.Height
                $OldWidth = $OldImage.Width
 
                If ($MaintainRatio) {
                    $OldHeight = $OldImage.Height
                    $OldWidth = $OldImage.Width
                    If ($Height) {
                        $Width = $OldWidth / $OldHeight * $Height
                    }
                    If ($Width) {
                        $Height = $OldHeight / $OldWidth * $Width
                    }
                }
 
                If ($Percentage) {
                    $Product = ($Percentage / 100)
                    $Height = $OldHeight * $Product
                    $Width = $OldWidth * $Product
                }

                $Bitmap = New-Object -TypeName System.Drawing.Bitmap -ArgumentList $Width, $Height
                $NewImage = [System.Drawing.Graphics]::FromImage($Bitmap)
             
                #Retrieving the best quality possible
                $NewImage.SmoothingMode = $SmoothingMode
                $NewImage.InterpolationMode = $InterpolationMode
                $NewImage.PixelOffsetMode = $PixelOffsetMode
                $NewImage.DrawImage($OldImage, $(New-Object -TypeName System.Drawing.Rectangle -ArgumentList 0, 0, $Width, $Height))

                If ($PSCmdlet.ShouldProcess("Resized image based on $Path", "save to $OutputPath")) {
                    #$Bitmap.Save($OutputPath)
                    # above can create misnamed .png files (named .jpg)
                    # explicitly set the format:
                    <# supported formats
                    |Name | Desc|
                    |---|---|
                    |Bmp | Gets the bitmap (BMP) image format.|
                    |Emf|Gets the enhanced metafile (EMF) image format.|
                    |Exif|Gets the Exchangeable Image File (Exif) format.|
                    |Gif|Gets the Graphics Interchange Format (GIF) image format.|
                    |Guid|Gets a Guid structure that represents this ImageFormat object.|
                    |Heif|Specifies the High Efficiency Image Format (HEIF).|
                    |Icon|Gets the Windows icon image format.|
                    |Jpeg|Gets the Joint Photographic Experts Group (JPEG) image format.|
                    |MemoryBmp|Gets the format of a bitmap in memory.|
                    |Png|Gets the W3C Portable Network Graphics (PNG) image format.|
                    |Tiff|Gets the Tagged Image File Format (TIFF) image format.|
                    |Webp|Specifies the WebP image format.|
                    |Wmf|Gets the Windows metafile (WMF) image format.|
                    #>
                    switch($ext){
                        '.png' {                        
                            # png
                            #bitmap.Save(@"C:\Users\johndoe\test.png", ImageFormat.Png);
                            $Bitmap.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
                        }
                        '.jpg' {$Bitmap.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Jpeg)}
                        '.Bmp' {$Bitmap.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Bmp)}
                        '.Emf' {$Bitmap.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Emf)}
                        '.Exif' {$Bitmap.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Exif)}
                        '.Gif' {$Bitmap.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Gif)}
                        '.Guid' {$Bitmap.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Guid)}
                        '.Heif' {$Bitmap.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Heif)}
                        '.Ico' {$Bitmap.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Icon)}
                        '.MemoryBmp' {$Bitmap.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::MemoryBmp)}
                        '.Tiff' {$Bitmap.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Tiff)}
                        '.Webp' {$Bitmap.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Webp)}
                        '.Wmf' {$Bitmap.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Wmf)}
                        default {
                            $smsg = "Unrecognized Extension: $($Ext)!" ; 
                            throw $smsg ; 
                            break ; 
                        } ; 
                    } ; 
                }            
                $Bitmap.Dispose()
                $NewImage.Dispose()
                $OldImage.Dispose()
            }
        }
    }
    #endregion RESIZE_IMAGE ; #*------^ END Resize-ImageTDO ^------