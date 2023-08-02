#Requires -Version 5.0
Set-StrictMode -Version latest;

################################################## GLOBAL VARIABLES / SETTINGS

### Package installation directory
$MainDirPath = "C:\tools\libwebp"

### Package location
$TempDirPath = "$PWD\temp"

### Package installation type
$FlagVariableStatus = 1
# 0 - not installed
# 1 - user
# 2 - all

### Temporary files delete mode
$TempDeleteMode = 0
# 0 - delete all
# 1 - delete only archive folder
# 2 - delete only library archive

### Package website URL
$WebsiteDownloadUrl = 'https://storage.googleapis.com/downloads.webmproject.org/releases/webp'

### Log mode
$LogOff = 0
# 0 - on
# 1 - off

################################################## FUNCTIONS

function Write-Copyright {
    Write-LogMessage ">> WebP PowerShell Installer" -MessageType Info -LogMode 0
    Write-LogMessage "> Author: (c) Alexey `"bru1t`" Kuznetsov" -MessageType Info -LogMode 0
    Write-LogMessage "> GitHub: https://github.com/bru1t" -MessageType Info -LogMode 0
}

enum MessageTypes {
    Empty
    Success
    Warning
    Error
    Info
}

function Write-LogMessage([string]$LogMessage, [MessageTypes]$MessageType, [int]$LogMode = $LogOff) {

    if ($LogMode) {return}

    switch ($MessageType) {
        Empty {Write-Host $LogMessage}
        Success {Write-Host "[SUCCESS]"$LogMessage -ForegroundColor Green}
        Warning {Write-Host "[WARNING]"$LogMessage -ForegroundColor Yellow}
        Error {Write-Host "[ERROR]"$LogMessage -ForegroundColor Red}
        Info {Write-Host "[INFO]"$LogMessage}
        Default {Write-Host "[LOG]"$LogMessage}
    }

}

function Get-Architecture {
    
    switch ([Environment]::Is64BitOperatingSystem) {
        $true  { 64; break }
        $false { 32; break }
        default {
            (Get-WmiObject -Class Win32_OperatingSystem).OSArchitecture -replace '\D'
        }
    }

}

function Test-IsPathVariable([string]$Path) {

    Write-LogMessage "Start Environment Variable checking..."
    Write-LogMessage "Check Path - `"$Path`""
    
    $UserPathVar = [Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::User)
    $SystemPathVar = [Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::Machine)

    if ($UserPathVar.contains("$Path")) {
        Write-LogMessage "`"$Path`" is User Variable!" -MessageType Success
        return 1
    }

    if ($SystemPathVar.contains("$Path")) {
        Write-LogMessage "`"$Path`" is System Variable!" -MessageType Success
        return 2
    }

    Write-LogMessage "`"$Path`" is not a Variable!" -MessageType Warning
    return 0

}

function Copy-AllWebPData([string]$InputPath = $TempDirPath) {

    if (Test-Path -Path $InputPath) {

        Write-LogMessage "Start copying data..."
        
        if (Test-Path -Path $MainDirPath) {
            Remove-Item -Path $MainDirPath -Force -Recurse
            Write-LogMessage "Workspace has been cleared." -MessageType Success
        }

        New-Item -ItemType "directory" -Path $MainDirPath | Out-Null
        Write-LogMessage "Main directory created."

        Copy-Item -Path "$InputPath\*" -Destination $MainDirPath -Recurse -Force
        Write-LogMessage "Temp data has been transfered."

        Remove-Item -Path "$MainDirPath\*" -Include *.* -Force -Confirm:$false
        Write-LogMessage "Threw out the trash."

        Write-LogMessage "Data copying is complete." -MessageType Success

    } else {
        Write-LogMessage "Entered data path is not valid!" -MessageType Error
    }

}

function Test-InstallationWebPLib([string]$LibDirPath = $TempDirPath) {

    Write-LogMessage "Start Installation check..."

    # VARIABLE CHECK
    $FlagIsProgramFullInstalled = Test-IsPathVariable("$MainDirPath\bin")

    # INSTALLATION CHECK
    $TempContentBin = Get-ChildItem -Recurse -Path "$LibDirPath\bin" -Name
    $TempContentInclude = Get-ChildItem -Recurse -Path "$LibDirPath\include" -Name
    $TempContentLib = Get-ChildItem -Recurse -Path "$LibDirPath\lib" -Name

    $MainContentBin = Get-ChildItem -Recurse -Path "$MainDirPath\bin" -Name
    $MainContentInclude = Get-ChildItem -Recurse -Path "$MainDirPath\include" -Name
    $MainContentLib = Get-ChildItem -Recurse -Path "$MainDirPath\lib" -Name

    $FlagBinFolderDifference = "$TempContentBin" -eq "$MainContentBin"
    $FlagIncludeFolderDifference = "$TempContentInclude" -eq "$MainContentInclude"
    $FlagLibFolderDifference = "$TempContentLib" -eq "$MainContentLib"
    
    # END
    $FlagIsProgramFullInstalled = $FlagIsProgramFullInstalled -and $FlagBinFolderDifference -and $FlagIncludeFolderDifference -and $FlagLibFolderDifference
    
    if (!($FlagIsProgramFullInstalled)) {
        Write-LogMessage "The necessary data is missing!" -MessageType Error
    } else {
        Write-LogMessage "All necessary data is intact." -MessageType Success
    }
    
    return $FlagIsProgramFullInstalled
    
}

function Add-PathToEnvironmentVariable([string]$Path) {

    if (!(Test-IsPathVariable("$Path"))) {

        Write-LogMessage "Start adding Environment Variable..."

        switch ($FlagVariableStatus) {

            1 { # FOR USER

                $Path = [Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::User) + $Path + [IO.Path]::PathSeparator
                [Environment]::SetEnvironmentVariable("Path", $Path, [System.EnvironmentVariableTarget]::User)
            
                Write-LogMessage "Path added for User." -MessageType Success
                return

            }

            2 { # FOR ALL

                $Path = [Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::Machine) + $Path + [IO.Path]::PathSeparator
                [Environment]::SetEnvironmentVariable("Path", $Path, [System.EnvironmentVariableTarget]::Machine)
            
                Write-LogMessage "Path added for All." -MessageType Success
                return

            }

            Default {
                Write-LogMessage "Path not added!" -MessageType Error
            }

        }

        Write-LogMessage "Path not added!" -MessageType Error

    } else {
        Write-LogMessage "Path already exists." -MessageType Warning
    }

}

function Get-WebPLibLastVersionName {

    Write-LogMessage "Receiving information about the latest version of the library..."
    
    $WebsiteUrl = Invoke-WebRequest -UseBasicParsing -Uri "$WebsiteDownloadUrl/index.html"
    $websiteDownloadTableParseTemp = $WebsiteUrl.links |`
                                     Where-Object { $_.tagName -eq 'A' -and $_.href.ToLower().Contains("-windows-x$(Get-Architecture).zip") -and $_.href.ToLower().EndsWith(".zip") } |`
                                     Sort-Object href -desc |`
                                     Select-Object href -first 1
    $WebsiteDownloadTableParseTemp = $WebsiteDownloadTableParseTemp.href.ToString()

    $FilenamePosition = $WebsiteDownloadTableParseTemp.IndexOf("libwebp-")
    $Filename = $WebsiteDownloadTableParseTemp.Substring($FilenamePosition)

    Write-LogMessage "Receiving information is complete." -MessageType Success
    Write-LogMessage "Latest version of the library: $Filename"

    return $Filename

}

function Receive-WebPLib([string]$LibVersionFullName, [string]$Path = $TempDirPath) {

    Write-LogMessage "Starting a library download..."

    if (!(Test-Path -Path $Path)) {
        New-Item -ItemType "directory" -Path $Path | Out-Null
    }

    Invoke-WebRequest "$WebsiteDownloadUrl\$LibVersionFullName.zip" -OutFile "$Path\$LibVersionFullName.zip"

    if (!(Test-Path -Path "$Path\$LibVersionFullName.zip" -PathType leaf)) {
        Write-LogMessage "Download error occurred!" -MessageType Error
        return $false
    }

    Write-LogMessage "Library download is complete." -MessageType Success

    return $true

}

function Expand-WebPLib([string]$Path) {

    Write-LogMessage "Starting to unpack the archive..."

    if (!(Test-Path -Path $Path -PathType leaf)) {
        Write-LogMessage "The required archive was not found!" -MessageType Error
        return $false
    }

    Expand-Archive -Path $Path -DestinationPath $TempDirPath -Force
    Write-LogMessage "Unpacking completed." -MessageType Success
    return $true

}

function Remove-LibWebPTemp([string]$Filename,[int]$Mode = $TempDeleteMode) {

    Write-LogMessage "Starting to delete temporary files..."

    switch ($Mode) {

        1 {
            Remove-Item -Path "$TempDirPath/$Filename" -Recurse
            Write-LogMessage "Deletion was completed." -MessageType Success
            return
        }

        2 {
            Remove-Item -Path "$TempDirPath/$Filename.zip"
            Write-LogMessage "Deletion was completed." -MessageType Success
            return
        }

        Default {
            Remove-Item -Path "$TempDirPath/$Filename" -Recurse
            Remove-Item -Path "$TempDirPath/$Filename.zip"

            if ($TempDirPath -ne $PWD) {
                Remove-Item -Path $TempDirPath -Recurse
            }

            Write-LogMessage "Deletion was completed." -MessageType Success
            return
        }

    }

    Write-LogMessage "Files for deletion not found." -MessageType Warning
    
}

################################################## MAIN

Write-Host "`n[TASK START]" -ForegroundColor Yellow
Write-Copyright
Write-Host ""

# UPDATE
$FullFilename = Get-WebPLibLastVersionName
$Filename = $FullFilename.Substring(0, $FullFilename.Length - 4)

[void](Receive-WebPLib $Filename)
[void](Expand-WebPLib "$TempDirPath\$FullFilename")

# INSTALL
if (!(Test-InstallationWebPLib "$TempDirPath\$Filename" )) {

    Write-LogMessage "Program installation is required"

    Copy-AllWebPData "$TempDirPath\$Filename" 
    Add-PathToEnvironmentVariable "$MainDirPath\bin" 

} else {
    Write-LogMessage "Program is already installed." -MessageType Warning
}

Remove-LibWebPTemp $Filename

Write-Host "`n[TASK COMPLETED]`n" -ForegroundColor Yellow

Pause