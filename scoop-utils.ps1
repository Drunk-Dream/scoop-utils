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
    "main" = $commandHelpInfo
    "backup" = $backupHelpInfo
    "update" = $updateHelpInfo
}

# 检查环境变量中是否有scoop
if (-not (Get-Command -Name "scoop" -ErrorAction SilentlyContinue)) {
    Write-Error "scoop is not installed"
    exit
}

function Backup-ScoopList {
    param (
        [Parameter(Mandatory=$false)]
        [string]$FilePath
    )
    try {
        $BackupCommand = "scoop list | Export-Clixml -Path $FilePath"
        Invoke-Expression $BackupCommand
    } catch {
        Write-Error "Backup-ScoopList: $($_.Message)"
        return
    }
}

function Update-All {
    param (
        # $exclude
        [Parameter(Mandatory=$false)]
        [System.String[]]$exclude
    )
    try {
        $AvailableUpdates = Invoke-Expression "scoop status -l"
        foreach ($updateApp in $AvailableUpdates) {
            $name = $updateApp.Name
            if ($exclude -and $name -in $exclude) {
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
if ($args[0] -eq "-h" -or $args[0] -eq "--help") {
    Write-Host $commandHelpInfo
    exit
}

if ($args[0] -eq "help") {
    if ($args[1]) {
        Write-Host $helpInfo[$args[1]]
    } else {
        Write-Host $commandHelpInfo
    }
    exit
}

######################### backup ############################
if ($args[0] -eq "backup") {
    if ($args[1] -eq "-o" -or $args[1] -eq "--output") {
        if ($args[2]) {
            $BackupFilePath = $args[2]
        } else {
            Write-Error "Backup-ScoopList: output file path not specified"
            exit
        }
    } elseif ($args[1]) {
        $BackupFilePath = $args[1]
    } else {
        $BackupFilePath = "scoop-list.xml"
    }
    Backup-ScoopList -FilePath $BackupFilePath
    exit
}

######################### update ############################
if ($args[0] -eq "update") {
    if ($args -contains "--exclude") {
        $index = $args.IndexOf("--exclude") + 1
        if ($index -lt $args.Length -and $args[$index] -notmatch "^-") {
            Update-All -exclude $args[$index]
        } else {
            Write-Error "Update-All: exclude apps not specified"
        }
    } else {
        Update-All
    }
    exit
}
