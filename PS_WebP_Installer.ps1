#Requires -Version 5.0

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

### System bit
$SystemBit = 64
# 64 - 64bit
# 86 - 32bit

### Temporary files delete mode
$TempDeleteMode = 0
# 0 - delete all
# 1 - delete only archive folder
# 2 - delete only library archive

### Package website URL
$WebsiteDownloadUrl = 'https://storage.googleapis.com/downloads.webmproject.org/releases/webp'

################################################## FUNCTIONS

function Write-Copyright {
    Write-Host ">> WebP PowerShell Installer"
    Write-Host "> Author: (c) Alexey `"bru1t`" Kuznetsov"
    Write-Host "> GitHub: https://github.com/bru1t"
}

function Test-IsPathVariable([string]$Path) {

    Write-Host "[LOG] Start Environment Variable checking..."
    Write-Host "[LOG] Check Path - `"$Path`""
    
    $UserPathVar = [Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::User)
    $SystemPathVar = [Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::Machine)

    if ($UserPathVar.contains("$Path")) {
        Write-Host "[LOG] `"$Path`" is User Variable!"
        return 1
    }

    if ($SystemPathVar.contains("$Path")) {
        Write-Host "[LOG] `"$Path`" is System Variable!"
        return 2
    }

    Write-Host "[LOG] `"$Path`" is not a Variable!"
    return 0

}

function Copy-AllWebPData([string]$InputPath = $TempDirPath) {

    if (Test-Path -Path $InputPath) {

        Write-Host "[LOG] Start copying data..."
        
        if (Test-Path -Path $MainDirPath) {
            Remove-Item -Path $MainDirPath -Force -Recurse
            Write-Host "[LOG] Workspace has been cleared."
        }

        New-Item -ItemType "directory" -Path $MainDirPath | Out-Null
        Write-Host "[LOG] Main directory created."

        Copy-Item -Path "$InputPath\*" -Destination $MainDirPath -Recurse -Force
        Write-Host "[LOG] Temp data has been transfered."

        Remove-Item -Path "$MainDirPath\*" -Include *.* -Force -Confirm:$false
        Write-Host "[LOG] Threw out the trash."

        Write-Host "[LOG] Data copying is complete."

    } else {
        Write-Host "[LOG] Entered data path is not valid!"
    }

}

function Test-InstallationWebPLib([string]$LibDirPath = $TempDirPath) {

    Write-Host "[LOG] Start Installation check..."

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
        Write-Host "[LOG] The necessary data is missing!"
    } else {
        Write-Host "[LOG] All necessary data is intact."
    }
    
    return $FlagIsProgramFullInstalled
    
}

function Add-PathToEnvironmentVariable([string]$Path) {

    if (!(Test-IsPathVariable("$Path"))) {

        Write-Host "[LOG] Start adding Environment Variable..."

        switch ($FlagVariableStatus) {

            1 { # FOR USER

                $Path = [Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::User) + $Path + [IO.Path]::PathSeparator
                [Environment]::SetEnvironmentVariable("Path", $Path, [System.EnvironmentVariableTarget]::User)
            
                Write-Host "[LOG] Path added for User."
                exit

            }

            2 { # FOR ALL

                $Path = [Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::Machine) + $Path + [IO.Path]::PathSeparator
                [Environment]::SetEnvironmentVariable("Path", $Path, [System.EnvironmentVariableTarget]::Machine)
            
                Write-Host "[LOG] Path added for All."
                exit

            }

            Default {
                Write-Host "[LOG] Path not added!"
            }

        }

        Write-Host "[LOG] Path not added!"

    } else {
        Write-Host "[LOG] Path already exists."
    }

}

function Get-WebPLibLastVersionName {

    Write-Host "[LOG] Receiving information about the latest version of the library..."
    
    $WebsiteUrl = Invoke-WebRequest -UseBasicParsing -Uri "$WebsiteDownloadUrl/index.html"
    $websiteDownloadTableParseTemp = $WebsiteUrl.links |`
                                     Where-Object { $_.tagName -eq 'A' -and $_.href.ToLower().Contains("-windows-x$SystemBit.zip") -and $_.href.ToLower().EndsWith(".zip") } |`
                                     Sort-Object href -desc |`
                                     Select-Object href -first 1
    $WebsiteDownloadTableParseTemp = $WebsiteDownloadTableParseTemp.href.ToString()

    $FilenamePosition = $WebsiteDownloadTableParseTemp.IndexOf("libwebp-")
    $Filename = $WebsiteDownloadTableParseTemp.Substring($FilenamePosition)

    Write-Host "[LOG] Receiving information is complete."
    Write-Host "[LOG] Latest version of the library: $Filename"

    return $Filename

}

function Receive-WebPLib([string]$LibVersionFullName, [string]$Path = $TempDirPath) {

    Write-Host "[LOG] Starting a library download..."

    if (!(Test-Path -Path $Path)) {
        New-Item -ItemType "directory" -Path $Path | Out-Null
    }

    Invoke-WebRequest "$WebsiteDownloadUrl\$LibVersionFullName.zip" -OutFile "$Path\$LibVersionFullName.zip"

    if (!(Test-Path -Path "$Path\$LibVersionFullName.zip" -PathType leaf)) {
        Write-Host "[LOG] Download error occurred!"
        return $false
    }

    Write-Host "[LOG] Library download is complete."

    return $true

}

function Expand-WebPLib([string]$Path) {

    Write-Host "[LOG] Starting to unpack the archive..."

    if (!(Test-Path -Path $Path -PathType leaf)) {
        Write-Host "[LOG] The required archive was not found!"
        return $false
    }

    Expand-Archive -Path $Path -DestinationPath $TempDirPath -Force
    Write-Host "[LOG] Unpacking completed."
    return $true

}

function Remove-LibWebPTemp([string]$Filename,[int]$Mode = $TempDeleteMode) {

    Write-Host "[LOG] Starting to delete temporary files..."

    switch ($Mode) {

        1 {
            Remove-Item -Path "$TempDirPath/$Filename" -Recurse
            Write-Host "[LOG] Deletion was completed."
            exit
        }

        2 {
            Remove-Item -Path "$TempDirPath/$Filename.zip"
            Write-Host "[LOG] Deletion was completed."
            exit
        }

        Default {
            Remove-Item -Path "$TempDirPath/$Filename" -Recurse
            Remove-Item -Path "$TempDirPath/$Filename.zip"

            if ($TempDirPath -ne $PWD) {
                Remove-Item -Path $TempDirPath -Recurse
            }

            Write-Host "[LOG] Deletion was completed."
            exit
        }

    }

    Write-Host "[LOG] Files for deletion not found."
    
}

################################################## MAIN

Write-Host "`n[TASK START]"
Write-Copyright
Write-Host ""

# UPDATE
$FullFilename = Get-WebPLibLastVersionName
$Filename = $FullFilename.Substring(0, $FullFilename.Length - 4)

[void](Receive-WebPLib $Filename)
[void](Expand-WebPLib "$TempDirPath\$FullFilename")

# INSTALL
if (!(Test-InstallationWebPLib "$TempDirPath\$Filename" )) {

    Write-Host "[LOG] Program installation is required"

    Copy-AllWebPData "$TempDirPath\$Filename" 
    Add-PathToEnvironmentVariable "$MainDirPath\bin" 

} else {
    Write-Host "[LOG] Program is already installed."
}

Remove-LibWebPTemp $Filename 

Write-Host "`n[TASK COMPLETED]`n"

Pause