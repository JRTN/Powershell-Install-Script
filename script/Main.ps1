#Requires -RunAsAdministrator

try {
    #Begin script setup
    $functionFile = "$PSScriptRoot\ScriptFunctions.ps1"
    . $functionFile
} catch {
    Write-Error -Message "Failed to import Script functions. Ending Script." -ErrorAction Stop
}

$MainDirectory = [System.IO.Path]::GetFullPath("$PSScriptRoot\..")
$ConfigDirectory = [System.IO.Path]::GetFullPath("$MainDirectory\xmlconfig")

$global:Logger.Informational(
@"

Main Directory: $MainDirectory
User: $env:USERDOMAIN\$env:USERNAME
Machine Name: $env:COMPUTERNAME

"@)

$InputFile = Handle-ConfigMenu -ConfigDirectory $ConfigDirectory
if($null -eq $InputFile) { Exit }

$fileContents = (Get-Content -Path $InputFile)
$global:Logger.Informational("Read XML from $($InputFile): $fileContents")

try {
   [xml] $xml = [xml]$fileContents 
} catch {
    $message = "Failed to convert file contents to xml.`n$($_.Exception.Message)"
    Write-Host -Message $message
    $global:Logger.Error($message)
    Exit
}

$message = "Now running config: $($xml.config.name)"
Write-Host $message -ForegroundColor Green
$global:Logger.Informational($message)

# Run all tasks 
$Tasks = $xml.config.task
foreach ($task in $Tasks) {
    Run-XMLTask -Task $task
}