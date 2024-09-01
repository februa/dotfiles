$AssetsPath = (Convert-Path (Get-ChildItem $env:USERPROFILE\AppData\Local\Packages\Microsoft.Windows.ContentDeliveryManager_*\LocalState\Assets)[0])
$WindowsSpotlight = $env:USERPROFILE + "\OneDrive\Pictures\Windows Spotlight\"
$Landscape = $WindowsSpotlight + "Landscape"
$Portrait = $WindowsSpotlight + "Portrait"
$Square = $WindowsSpotlight + "Square"

$SHELL = New-Object -ComObject Shell.Application
$DIRECTORY = $SHELL.NameSpace($AssetsPath)

$FILELIST=(Get-ChildItem $AssetsPath)

foreach($TEMP_FILEFULLPATH in $FILELIST) {
    $TEMP_FILEBASENAME=($TEMP_FILEFULLPATH).BaseName
    $TEMP_FILEEXTENSION=($TEMP_FILEFULLPATH).Extension

    if($TEMP_FILEEXTENSION -eq ''){
        $OLD_FULLPATH=$AssetsPath + '\' + $TEMP_FILEBASENAME
        $NEW_FULLPATH=$OLD_FULLPATH +'.jpg'
        Copy-Item $OLD_FULLPATH $NEW_FULLPATH

        #Write-Host $OLD_FULLPATH
        Write-Host $TEMP_FILEBASENAME

        $OBJECT = $DIRECTORY.ParseName($TEMP_FILEBASENAME+'.jpg')
        $Detail176 = $DIRECTORY.GetDetailsOf($OBJECT, 176)
        $Detail178 = $DIRECTORY.GetDetailsOf($OBJECT, 178)
        
        try {
            [int]$HIGHT = $Detail176.SubString(1,$Detail176.IndexOf(' '))
            [int]$WIDTH = $Detail178.SubString(1,$Detail178.IndexOf(' '))
        } catch [Exception] {
            Write-Host "This File is not jpeg file."
            continue
        }

        Write-Host ' ->hight x width '$HIGHT' x '$WIDTH
        
        $TARGET_FULLPATH = ''
        if($HIGHT -gt 0 -and $WIDTH -gt 0) {
            if($HIGHT -eq $WIDTH){
                Write-Host ' ->Square'
                $TARGET_FULLPATH=$Square + '\' + $TEMP_FILEBASENAME + '.jpg'
            }elseif($HIGHT -lt $WIDTH){
                Write-Host ' ->Portrait'
                $TARGET_FULLPATH=$Portrait + '\' + $TEMP_FILEBASENAME + '.jpg'
            }else{
                Write-Host ' ->Landscape'
                $TARGET_FULLPATH=$Landscape + '\' + $TEMP_FILEBASENAME + '.jpg'
            }
        }

        if($TARGET_FULLPATH -ne '') {
            try {
                Move-Item $NEW_FULLPATH $TARGET_FULLPATH -ErrorAction Stop

            }catch [Exception] {
                Write-Host 'Filepath is exists.'
            }
        }
        Remove-Item $NEW_FULLPATH
    }
}