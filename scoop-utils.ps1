# utils for scoop
# version 0.0.2

# helpinfo
$commandHelpInfo = @"
This is a utils for scoop

Usage: scoop-utils.ps1 <command> [<options>]

Type 'scoop-utils.ps1 help <command>' to get help for a specific command.

Available commands:
    backup     backup scoop list
    help       show this help message
"@

$backupHelpInfo = @"
Usage: scoop-utils.ps1 backup [<options>]

Options:
    -o, --output <path>    output file path
"@

# 检查环境变量中是否有scoop
if (-not (Get-Command -Name "scoop" -ErrorAction SilentlyContinue)) {
    Write-Error "scoop is installed"
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

if ($args[0] -eq "-h" -or $args[0] -eq "--help") {
    Write-Host $commandHelpInfo
    exit
}

if ($args[0] -eq "help") {
    if ($args[1] -eq "backup") {
        Write-Host $backupHelpInfo
    } else {
        Write-Host $commandHelpInfo
    }
    exit
}

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
