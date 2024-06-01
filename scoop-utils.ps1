# utils for scoop
# version 0.0.3

######################### help info ############################
$commandHelpInfo = @"
This is a utils for scoop

Usage: scoop-utils.ps1 <command> [<options>]

Type 'scoop-utils.ps1 help <command>' to get help for a specific command.

Available commands:
    backup     backup scoop list
    update     update all
    help       show this help message
"@

$backupHelpInfo = @"
Usage: scoop-utils.ps1 backup [<options>]

Options:
    -o, --output <path>    output file path
"@

$updateHelpInfo = @"
Usage: scoop-utils.ps1 update [<options>]

Options:
    --exclude <apps>       exclude apps, e.g. --exclude vscode,vncviewer
"@

$helpInfo = @{
    "main"   = $commandHelpInfo
    "backup" = $backupHelpInfo
    "update" = $updateHelpInfo
}

# 检查环境变量中是否有scoop
function ScoopCheck {
    if (-not (Get-Command -Name "scoop" -ErrorAction SilentlyContinue)) {
        Write-Error "scoop is not installed"
        exit
    }
}

function Backup-ScoopList {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )
    try {
        $BackupCommand = "scoop list | Export-Clixml -Path $FilePath"
        Invoke-Expression $BackupCommand
    }
    catch {
        Write-Error "Backup-ScoopList: $($_.Message)"
        return
    }
}

function Update-All {
    param (
        # $exclude
        [Parameter(Mandatory = $true)]
        [System.String[]]$exclude
    )
    try {
        $AvailableUpdates = Invoke-Expression "scoop status -l"
        foreach ($updateApp in $AvailableUpdates) {
            $name = $updateApp.Name
            $info = $updateApp.Info
            if (
                ($info -eq "Held package") -or
                ($exclude -and $name -in $exclude)
            ) {
                continue
            }
            $UpdateCommand = "scoop update $name"
            Invoke-Expression $UpdateCommand
            # Write-Host $UpdateCommand
        }
    }
    catch {
        Write-Error "Update-All: $($_.Message)"
        return
    }
}

######################### help info ############################
function ScoopHelp {
    param (
        [Parameter(Mandatory = $true)]
        [System.Object]$params
    )
    if ($params[0] -eq "-h" -or $params[0] -eq "--help") {
        Write-Host $commandHelpInfo
        exit
    }

    if ($params[0] -eq "help") {
        if ($params[1]) {
            Write-Host $helpInfo[$params[1]]
        }
        else {
            Write-Host $commandHelpInfo
        }
        exit
    }
}

######################### backup ############################
#TODO: 重构参数识别的代码
function ScoopBackup {
    param (
        [Parameter(Mandatory = $true)]
        [System.Object]$params
    )
    if ($params[0] -eq "backup") {
        if ($params[1] -eq "-o" -or $params[1] -eq "--output") {
            if ($params[2]) {
                $BackupFilePath = $params[2]
            }
            else {
                Write-Error "Backup-ScoopList: output file path not specified"
                exit
            }
        }
        elseif ($params[1]) {
            $BackupFilePath = $params[1]
        }
        else {
            $BackupFilePath = "scoop-list.xml"
        }
        Backup-ScoopList -FilePath $BackupFilePath
        exit
    }
}

######################### update ############################
function ScoopUpdate {
    param (
        [Parameter(Mandatory = $true)]
        [System.Object]$params
    )
    if ($params -contains "--exclude") {
        $index = $params.IndexOf("--exclude") + 1
        if ($index -lt $params.Length -and $params[$index] -notmatch "^-") {
            $excludeApps = $params[$index]
        }
        else {
            Write-Error "Update-All: exclude apps not specified"
            exit
        }
    }
    else {
        $excludeApps = $null
    }
    Update-All -exclude $excludeApps
    exit
}

function ScoopMain {
    param (
        [Parameter(Mandatory = $true)]
        [System.Object]$params
    )
    ScoopCheck
    if ($params[0] -eq "-h" -or $params[0] -eq "--help" -or $params[0] -eq "help") {
        ScoopHelp -params $params
    }
    if ($params[0] -eq "backup") {
        ScoopBackup -params $params
    }
    if ($params[0] -eq "update") {
        ScoopUpdate -params $params
    }
    Write-Host "scoop-utils: command not found"
    exit
}

ScoopMain -params $args
