# utils for scoop
# version 0.0.7

######################### help info ############################
$commandHelpInfo = @"
This is a utils for scoop

Usage: scoop-utils.ps1 <command> [<options>]

Type 'scoop-utils.ps1 help <command>' to get help for a specific command.

Available commands:
    backup     backup scoop list
    install    install all
    update     update all
    help       show this help message
"@

$backupHelpInfo = @"
Usage: scoop-utils.ps1 backup [<options>]

Options:
    -o, --output <path>    output file path, default is ./scoop-list.xml
"@

$updateHelpInfo = @"
Usage: scoop-utils.ps1 update [<options>]

Options:
    --exclude <apps>       exclude apps, e.g. --exclude vscode,vncviewer
"@

$installHelpInfo = @"
Usage: scoop-utils.ps1 install [<options>]

Options:
    -i, --input <path>     input file path, default is ./scoop-list.xml
    -v                     install specified version
    -y                     accept all
"@

$helpInfo = @{
    "main"    = $commandHelpInfo
    "backup"  = $backupHelpInfo
    "update"  = $updateHelpInfo
    "install" = $installHelpInfo
}

# 检查环境变量中是否有scoop
function ScoopCheck {
    if (-not (Get-Command -Name "scoop" -ErrorAction SilentlyContinue)) {
        Write-Error "scoop is not installed"
        exit
    }
}

function ExtractParam {
    param (
        [System.Object[]]$AllParameter,
        [string]$specifiedParameter
    )
    if ($AllParameter -contains $specifiedParameter) {
        $index = $AllParameter.IndexOf($specifiedParameter) + 1
        if ($index -lt $AllParameter.Length -and $AllParameter[$index] -notmatch "^-") {
            return $AllParameter[$index]
        }
        else {
            Write-Error "$specifiedParameter is not specified"
            exit
        }
    }
    else {
        return $null
    }
}

function HasParam {
    param (
        [System.Object[]]$AllParameter,
        [string]$specifiedParameter
    )
    if ($AllParameter -contains $specifiedParameter) {
        return $true
    }
    else {
        return $false
    }
}

######################### help info ############################
function ScoopHelp {
    param (
        [Parameter(Mandatory = $true)]
        [System.Object[]]$params
    )
    if ($params[0] -eq "-h" -or $params[0] -eq "--help") {
        Write-Host $commandHelpInfo
    }
    elseif ($params[0] -eq "help") {
        if ($params[1]) {
            Write-Host $helpInfo[$params[1]]
        }
        else {
            Write-Host $commandHelpInfo
        }
    }
    exit
}

######################### install ############################
function Install-All {
    param (
        [Parameter(Mandatory = $true)]
        [string]$filePath,
        [Parameter(Mandatory = $true)]
        [bool]$hasVersion,
        [Parameter(Mandatory = $true)]
        [bool]$acceptAll
    )
    try {
        $installApps = Import-Clixml -Path $filePath
        foreach ($installApp in $installApps) {
            $appName = $installApp.Name
            $appVersion = $installApp.Version
            $installCommand = "scoop install $appName"
            if ($hasVersion) {
                $installCommand += "@$appVersion"
            }
            if ($acceptAll) {
                Invoke-Expression $installCommand
            }
            else {
                while ($true) {
                    $userChoice = Read-Host "Install $appName[Y/n]?"
                    if ($userChoice -eq "" -or $userChoice.ToLower() -eq "y") {
                        Invoke-Expression $installCommand
                        break
                    }
                    elseif ($userChoice.ToLower() -eq "n") {
                        Write-Host "Skipping installation of $appName"
                        break
                    }
                    else {
                        Read-Host "Invalid input. Please enter Y or N."
                    }
                }
            }
        }
    }
    catch {
        Write-Error "Install-All: $($_.Message)"
        return
    }
}

function ScoopInstall {
    param (
        [Parameter(Mandatory = $true)]
        [System.Object[]]$params
    )
    $installFilePath = ExtractParam $params "-i"
    if (-not $installFilePath) {
        $installFilePath = ExtractParam $params "--input"
    }
    if (-not $installFilePath) {
        $installFilePath = $PWD.Path + "\scoop-list.xml"
    }
    $hasVersion = HasParam $params "-v"
    $acceptAll = HasParam $params "-y"
    Install-All -filePath $installFilePath -hasVersion $hasVersion -acceptAll $acceptAll
}

######################### backup ############################
function Backup-ScoopList {
    param (
        [Parameter(Mandatory = $true)]
        [string]$filePath
    )
    try {
        $BackupCommand = "scoop list | Export-Clixml -Path $filePath"
        Invoke-Expression $BackupCommand
    }
    catch {
        Write-Error "Backup-ScoopList: $($_.Message)"
        return
    }
}

function ScoopBackup {
    param (
        [Parameter(Mandatory = $true)]
        [System.Object[]]$params
    )
    $backupFilePath = ExtractParam $params "-o"
    if (-not $backupFilePath) {
        $backupFilePath = ExtractParam $params "--output"
    }
    if (-not $backupFilePath) {
        $backupFilePath = $PWD.Path + "\scoop-list.xml"
    }
    Backup-ScoopList -FilePath $BackupFilePath
    exit
}

######################### update ############################
function Update-All {
    param (
        # $exclude
        # [Parameter(Mandatory = $true)]
        [System.String[]]$exclude
    )
    try {
        $AvailableUpdates = Invoke-Expression "scoop status -l"
        # example
        # $AvailableUpdates = @(
        #     [PSCustomObject]@{Name = "test1"; Info = "test1" },
        #     [PSCustomObject]@{Name = "test2"; Info = "test2" }
        # )
        # TODO: 添加-s参数交互选择
        $UpdateCommand = "scoop update"
        foreach ($updateApp in $AvailableUpdates) {
            $name = $updateApp.Name
            $info = $updateApp.Info
            if (
                ($info -eq "Held package") -or
                ($exclude -and $name -in $exclude)
            ) {
                continue
            }
            $UpdateCommand = "$UpdateCommand $name"
        }
        if ($AvailableUpdates.Length -gt 0) {
            Invoke-Expression $UpdateCommand
        }
        else {
            Write-Host "No updates available"
        }
    }
    catch {
        Write-Error "Update-All: $($_.Message)"
        return
    }
}

function ScoopUpdate {
    param (
        [Parameter(Mandatory = $true)]
        [System.Object[]]$params
    )
    $excludeApps = ExtractParam $params "--exclude"
    Update-All -exclude $excludeApps
    exit
}

######################### main ############################
function ScoopMain {
    param (
        [Parameter(Mandatory = $true)]
        [System.Object[]]$params
    )
    ScoopCheck
    if ($params[0] -eq "-h" -or $params[0] -eq "--help" -or $params[0] -eq "help") {
        ScoopHelp -params $params
    }
    elseif ($params[0] -eq "backup") {
        ScoopBackup -params $params
    }
    elseif ($params[0] -eq "update") {
        ScoopUpdate -params $params
    }
    elseif ($params[0] -eq "install") {
        ScoopInstall -params $params
    }
    else {
        Write-Host "scoop-utils: command not found"
    }
    exit
}

ScoopMain -params $args
