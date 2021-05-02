# Updated to use psfspi01 file paths on 08/17/2020

try {
    #Begin script setup
    $scriptDirectory = (Get-Item  -Path $PsScriptRoot).Parent.FullName
    $functionFile = "$scriptDirectory\util\backend\Installation-Functions.ps1"
    . $functionFile
} catch {
    Write-Error -Message "Failed to import installation functions. Ending Script." -ErrorAction Stop
}

### FUNCTION DEFINITIONS ###

function Run-Step {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        $Step
    )

    $result = $Step.Run()

    if($result) {
        Write-Host "Successfully completed step: $($Step.Name)" -ForegroundColor Green
    } else {
        Write-Host "Step failed: $($Step.Name)" -ForegroundColor Red
    }
}

function Handle-Variables {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $VariableString,
        [Parameter(Mandatory=$false)]
        [bool] $NoTrim=$false
    )
    #Remove leading and trailing white space
    $VariableString = $VariableString.Trim()
    #Escape all quotation marks 
    $VariableString = $VariableString -replace '"', '`"'

    $VariableValue = $null
    Invoke-Expression -Command "Set-Variable -Name VariableValue -Value ""$($VariableString)"""
    Write-Host "Parsed string to: [$VariableValue]" -ForegroundColor Blue
    return $VariableValue
}

### FUNCTION DEFINITIONS ###

### USER CHOOSES CONFIG ###
$configs = Get-ChildItem -Path "$scriptDirectory\xmlconfig"
$configsMenu = @{}

Write-Host "Configuration files`n======================================="

for($i = 1; $i -le $configs.count; $i++) {
    Write-Host "`t[$i] $($configs[$i - 1])"
    $configsMenu.Add($i, ($configs[$i - 1].name))
}

[int]$ans = Read-Host -Prompt 'Choose the configuration file'

$InputFile = "$scriptDirectory\xmlconfig\$($configsMenu[$ans])"

### USER CHOOSES CONFIG ###

# Read the xml from the config file
[xml] $xml = [xml](Get-Content -Path $InputFile)

Write-Host "Now running config: $($xml.config.name)" -ForegroundColor Green

# Get all tasks 
$Tasks = $xml.config.task

foreach ($task in $Tasks) {
    Write-Host "Task: $($task.name)"

    $Steps = $task.step

    if($null -eq $Steps) {
        Write-Host "No install steps found for task" -ForegroundColor Red
        continue
    }

    foreach ($step in $Steps) {
        Write-Host "Executing Step [$($step.name)] of type [$($step.type)]" -ForegroundColor Blue

        switch ($step.type) {
            ("file_move") {
                $stepObj = New-FileMoveStep -Name $step.name -File (Handle-Variables -VariableString $step.target) -Destination (Handle-Variables -VariableString $step.destination)
                Run-Step -Step $stepObj
                break
            }
            ("file_copy") {
                $stepObj = New-FileCopyStep -Name $step.name -File (Handle-Variables -VariableString $step.target) -Destination (Handle-Variables -VariableString $step.destination)
                Run-Step -Step $stepObj
                break
            }
            ("file_expand") {
                $stepObj = New-FileExpandStep -Name $step.name -File (Handle-Variables -VariableString $step.target) -Destination (Handle-Variables -VariableString $step.destination)
                Run-Step -Step $stepObj
                break
            }
            ("file_append") {
                $stepObj = New-FileAppendStep -Name $step.name -File (Handle-Variables -VariableString $step.target) -Content (Handle-Variables -VariableString $step.content)
                Run-Step -Step $stepObj
                break
            }
            ("file_write") {
                $stepObj = New-FileWriteStep -Name $step.name -File (Handle-Variables -VariableString $step.target) -Content (Handle-Variables -VariableString $step.content)
                Run-Step -Step $stepObj
                break
            }
            ("file_link") {
                $stepObj = New-FileLinkStep -Name $step.name -File (Handle-Variables -VariableString $step.target) -Location (Handle-Variables -VariableString $step.location)
                Run-Step -Step $stepObj
                break
            }
            ("file_delete") {
                $stepObj = New-FileDeleteStep -Name $step.name -File (Handle-Variables -VariableString $step.target)
                Run-Step -Step $stepObj
                break
            }
            ("file_register") {
                $stepObj = New-FileRegisterStep -Name $step.name -File (Handle-Variables -VariableString $step.target)
                Run-Step -Step $stepObj
                break
            }
            ("folder_create") {
                $stepObj = New-FolderCreateStep -Name $step.name -Folder (Handle-Variables -VariableString $step.target)
                Run-Step -Step $stepObj
                break
            }
            ("folder_delete") {
                $stepObj = New-FolderDeleteStep -Name $step.name -Folder (Handle-Variables -VariableString $step.target)
                Run-Step -Step $stepObj
                break
            }
            ("folder_move") {
                $stepObj = New-FolderCopyStep -Name $step.name -Folder (Handle-Variables -VariableString $step.target) -Destination (Handle-Variables -VariableString $step.destination)
                Run-Step -Step $stepObj
                break
            }
            ("folder_copy") {
                $stepObj = New-FolderCopyStep -Name $step.name -Folder (Handle-Variables -VariableString $step.target) -Destination (Handle-Variables -VariableString $step.destination)
                Run-Step -Step $stepObj
                break
            }
            ("executable") {
                $stepObj = $null
                if($null -ne $step.arguments) {
                    $arguments = $step.arguments -replace "\s+", ' '
                    $stepObj = New-ExecutableStep -Name $step.name -Executable (Handle-Variables -VariableString $step.target) -Arguments (Handle-Variables -VariableString $arguments)
                } else {
                    $stepObj = New-ExecutableStep -Name $step.name -Executable (Handle-Variables -VariableString $step.target)
                }
                Run-Step -Step $stepObj
                break
            }
            ("msi") {
                $stepObj = $null
                if($null -ne $step.arguments) {
                    $arguments = $step.arguments -replace "\s+", ' '
                    $stepObj = New-MsiStep -Name $step.name -Msi (Handle-Variables -VariableString $step.target) -Arguments (Handle-Variables -VariableString $arguments)
                } else {
                    $stepObj = New-MsiStep -Name $step.name -Msi (Handle-Variables -VariableString $step.target)
                }
                Run-Step -Step $stepObj
                break
            }
            ("message") {
                #Replace any leading spaces in messages to get rid of xml formatting
                $message = $step.message -replace "(?m)(^\s+)", ''
                $stepObj = New-UserInformationStep -Name $step.name -Message (Handle-Variables -VariableString $message)
                Run-Step -Step $stepObj
                break
            }
            Default {
                Write-Host "Unknown step type encountered: $($step.name). Moving on..." -ForegroundColor Red
                break
            }
        }
    }
}