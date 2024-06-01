# utils for scoop
# version 0.0.4

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

######################### backup ############################
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
function ScoopUpdate {
    param (
        [Parameter(Mandatory = $true)]
        [System.Object[]]$params
    )
    $excludeApps = ExtractParam $params "--exclude"
    Update-All -exclude $excludeApps
    exit
}

function ScoopMain {
    param (
        [Parameter(Mandatory = $true)]
        [System.Object[]]$params
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
