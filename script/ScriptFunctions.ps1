try {
    #Begin script setup
    $functionFile = "$PSScriptRoot\InstallationFunctions.ps1"
    . $functionFile
} catch {
    Write-Error -Message "Failed to import installation functions. Ending Script." -ErrorAction Stop
}

function Run-Step {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [InstallStep] $Step
    )

    $result = $Step.Run()

    if($result) {
        $message = "Successfully completed step: $($Step.Name)"
        Write-Host $message -ForegroundColor Green
        $global:Logger.Informational($message)
    } else {
        $message = "Step failed: $($Step.Name)"
        Write-Host $message -ForegroundColor Red
        $global:Logger.Informational($message)
    }
}

function Run-XMLStep {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.Xml.XmlElement] $Step
    )
    $message = "Executing Step [$($Step.name)] of type [$($Step.type)]"
    Write-Host $message -ForegroundColor Blue
    $global:Logger.Informational($message)

    switch ($Step.type) {
        ("file_move") {
            $stepObj = New-FileMoveStep -Name $Step.name -File (Handle-Variables -VariableString $Step.target) -Destination (Handle-Variables -VariableString $Step.destination)
            Run-Step -Step $stepObj
            break
        }
        ("file_copy") {
            $stepObj = New-FileCopyStep -Name $Step.name -File (Handle-Variables -VariableString $Step.target) -Destination (Handle-Variables -VariableString $Step.destination)
            Run-Step -Step $stepObj
            break
        }
        ("file_expand") {
            $stepObj = New-FileExpandStep -Name $Step.name -File (Handle-Variables -VariableString $Step.target) -Destination (Handle-Variables -VariableString $Step.destination)
            Run-Step -Step $stepObj
            break
        }
        ("file_append") {
            $stepObj = New-FileAppendStep -Name $Step.name -File (Handle-Variables -VariableString $Step.target) -Content (Handle-Variables -VariableString $Step.content)
            Run-Step -Step $stepObj
            break
        }
        ("file_write") {
            $stepObj = New-FileWriteStep -Name $Step.name -File (Handle-Variables -VariableString $Step.target) -Content (Handle-Variables -VariableString $Step.content)
            Run-Step -Step $stepObj
            break
        }
        ("file_link") {
            $stepObj = New-FileLinkStep -Name $Step.name -File (Handle-Variables -VariableString $Step.target) -Location (Handle-Variables -VariableString $Step.location)
            Run-Step -Step $stepObj
            break
        }
        ("file_delete") {
            $stepObj = New-FileDeleteStep -Name $Step.name -File (Handle-Variables -VariableString $Step.target)
            Run-Step -Step $stepObj
            break
        }
        ("file_register") {
            $stepObj = New-FileRegisterStep -Name $Step.name -File (Handle-Variables -VariableString $Step.target)
            Run-Step -Step $stepObj
            break
        }
        ("file_font") {
            $stepObj = New-FileFontStep -Name $Step.name -File (Handle-Variables -VariableString $Step.target)
            Run-Step -Step $stepObj
            break
        }
        ("folder_create") {
            $stepObj = New-FolderCreateStep -Name $Step.name -Folder (Handle-Variables -VariableString $Step.target)
            Run-Step -Step $stepObj
            break
        }
        ("folder_delete") {
            $stepObj = New-FolderDeleteStep -Name $Step.name -Folder (Handle-Variables -VariableString $Step.target)
            Run-Step -Step $stepObj
            break
        }
        ("folder_font") {
            $stepObj = New-FolderFontStep -Name $Step.name -Folder (Handle-Variables -VariableString $Step.target)
            Run-Step -Step $stepObj
            break
        }
        ("folder_move") {
            $stepObj = New-FolderCopyStep -Name $Step.name -Folder (Handle-Variables -VariableString $Step.target) -Destination (Handle-Variables -VariableString $Step.destination)
            Run-Step -Step $stepObj
            break
        }
        ("folder_copy") {
            $stepObj = New-FolderCopyStep -Name $Step.name -Folder (Handle-Variables -VariableString $Step.target) -Destination (Handle-Variables -VariableString $Step.destination)
            Run-Step -Step $stepObj
            break
        }
        ("executable") {
            $stepObj = $null
            if($null -ne $step.arguments) {
                $arguments = $Step.arguments -replace "\s+", ' '
                $stepObj = New-ExecutableStep -Name $Step.name -Executable (Handle-Variables -VariableString $Step.target) -Arguments (Handle-Variables -VariableString $arguments)
            } else {
                $stepObj = New-ExecutableStep -Name $Step.name -Executable (Handle-Variables -VariableString $Step.target)
            }
            Run-Step -Step $stepObj
            break
        }
        ("msi") {
            $stepObj = $null
            if($null -ne $step.arguments) {
                $arguments = $step.arguments -replace "\s+", ' '
                $stepObj = New-MsiStep -Name $Step.name -Msi (Handle-Variables -VariableString $Step.target) -Arguments (Handle-Variables -VariableString $arguments)
            } else {
                $stepObj = New-MsiStep -Name $Step.name -Msi (Handle-Variables -VariableString $Step.target)
            }
            Run-Step -Step $stepObj
            break
        }
        ("message") {
            #Replace any leading spaces in messages to get rid of xml formatting
            $message = $step.message -replace "(?m)(^\s+)", ''
            $stepObj = New-UserInformationStep -Name $Step.name -Message (Handle-Variables -VariableString $message)
            Run-Step -Step $stepObj
            break
        }
        Default {
            $message = "Unknown step type encountered: $($Step.name). Exiting Script..."
            Write-Host $message -ForegroundColor Red
            $global:Logger.Error($message)
            Exit
        }
    }
}

function Run-XMLTask {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.Xml.XmlElement] $Task
    )
    Write-Host "Task: $($Task.name)"

    $Steps = $Task.step

    if($null -eq $Steps) {
        $message = "No install steps found for task [$($task.name)]"
        Write-Host $message -ForegroundColor Red
        $global:Logger.Warning($message)
        continue
    }

    foreach ($step in $Steps) {
        Run-XMLStep -Step $step
    }
}

function Handle-Variables {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $VariableString
    )
    $VariableString = $VariableString.Trim()
    $VariableString = $VariableString -replace '"', '`"'

    $VariableValue = $null
    Invoke-Expression -Command "Set-Variable -Name VariableValue -Value ""$($VariableString)"""
    $global:Logger.Informational("Parsed string to: [`n$VariableValue`n]")
    return $VariableValue
}

function Handle-ConfigMenu {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $ConfigDirectory
    )

    $configs = Get-ChildItem -Path "$ConfigDirectory"
    $menuString = "Choose the configuration File:`n"
    for($i = 1; $i -le $configs.count; $i++) {
        $configName = $configs[$i - 1].Name
        $itemString = "`t[$i] $configName"
        $menuString = "$menuString$itemString`n"
    }

    Write-Host $menuString
    $global:Logger.Informational("`n$menuString")

    $selectionPrompt = 'Choose the configuration file'
    [int]$ans = Read-Host -Prompt $selectionPrompt
    $global:Logger.Informational("$($selectionPrompt): $ans")

    if(($ans -lt 1) -or ($ans -gt $configs.count)) {
        $message = "Invalid User Selection: $ans"
        Write-Error $message
        $global:Logger.Error($message)
        return $null
    }

    $chosenConfig = $configs[$ans - 1].Name
    return "$ConfigDirectory\$chosenConfig"
}