<#
    This script moves files with .log and .txt extension that have been created older than a 
    specified number of days ago from the source directory to a directory named as the four-digit 
    year of the target file's creation time under the source directory. The source directory can 
    be passed as an optional parameter, otherwise it defaults to "c:\PuttyLogs". The number of 
    days to consider as old can be passed as an optional parameter, otherwise it defaults to 30 
    days. The script validates that the source directory exists before executing the script.
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

<#

    To schedule this script to run at a specific time using the Windows Task Scheduler on Windows 10 and above:
    1. Press the Windows key + R to open the Run dialog box
    2. Type "taskschd.msc" and press Enter to open the Task Scheduler
    3. In the Task Scheduler window, click on the "Action" menu and select "Create Basic Task"
    4. In the "Create Basic Task" wizard, provide a name and description for the task
    5. Select the trigger for when you want the task to run (e.g. daily, weekly, at log on, etc.)
    6. Select the start time and date for the task
    7. In the "Action" section, select "Start a program"
    8. In the "Program/script" field, enter the path to your PowerShell executable (e.g. "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe")
    9. In the "Add arguments" field, enter the full path of your script and any parameters you want to pass (e.g. "C:\PuttyLogs\CleanUpLogs.ps1 -srcDir 'c:\PuttyLogs' -daysBack 45")
    10. Click Finish to create the task
    11. In the Task Scheduler window, you can verify the task is created and check the status of the last run or next run.

    I'd also recommend that you change the settings so that it runs whether you're logged in or not.  Otherwise, everytime it runs,
    it'll popup a powershell screen in your face for it to do the work, which could be distracting.
    
#>
