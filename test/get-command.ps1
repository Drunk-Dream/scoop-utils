# $command = Get-Command -Name "scoop" -ErrorAction SilentlyContinue

if (-not (Get-Command -Name "test" -ErrorAction SilentlyContinue)) {
    Write-Error "scoop is installed"
    exit
}