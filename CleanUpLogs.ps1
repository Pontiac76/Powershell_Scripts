<#
    This script moves files with .log and .txt extension that have been modified older than a month ago, and older than the current year from the source directory to a directory named as the modified date of the target file under the source directory. 
    The source directory can be passed as an optional parameter, otherwise it defaults to "c:\PuttyLogs".
    The script validates that the source directory exists before executing the script.
#>
param(
    [string]$srcDir = "c:\PuttyLogs",
    [int]$daysBack = 30
)

if (-not (Test-Path $srcDir)) {
    Write-Error "The specified source directory does not exist: $srcDir"
    return
}

$monthAgo = (Get-Date).AddDays(-$daysBack)

Get-ChildItem -Path $srcDir -Recurse -Include "*.log","*.txt" |
Where-Object {$_.CreationTime -lt $monthAgo} |
Foreach-Object {
    $destination = "$srcDir\$($_.CreationTime.Year)"
    if (!(Test-Path -Path $destination)) {
        New-Item -ItemType Directory -Path $destination
    }
    if (!(Test-Path -Path "$destination\$($_.Name)")) {
        Write-Host "$($_.FullName) is being moved to $destination"
        Move-Item -Path $_.FullName -Destination $destination
    }
}
