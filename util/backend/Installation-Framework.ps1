#Requires -RunAsAdministrator

#The different types of file operations which can be performed by a FileOperationStep
enum FileMode {
    Write 
    Append
    Copy  
    Delete
    Link
    Expand
    Register
}

#The different types of folder operations which can be performed by a FolderOperationStep
enum FolderMode {
    Create
    Move 
    Copy 
    Delete
}

#Parent class to inherit from in order to create a step in the application install. 
class InstallStep {
    [string] $name

    InstallStep() {
        $type = $this.GetType()

        if($type -eq [InstallStep]) {
            throw("Class $type cannot be instantiated directly and must be inherited.")
        }
    }

    #Executes the step. This is to be overridden by any inheriting class.
    [bool] Run() {
        throw("Method Run() must be overidden")
    }

    #Returns a user friendly string. This is to be overridden by any inheriting class.
    [string] ToString() {
        throw("Method ToString() must be overidden")
    }
}

#Provides information to the user
class UserInformationStep : InstallStep {
    [string] $message

    UserInformationStep() {
        throw("Default constructor for class UserInformationStep cannot be called.")
    }

    UserInformationStep([string] $name, [string] $message) {
        $this.Init($name, $message)
    }

    hidden [void] Init([string] $name, [string] $message) {
        $this.message   = $message
        $this.name      = $name
    }

    #Override
    [bool] Run() {
        Write-Host "Config-defined Message:`n$($this.message)" -ForegroundColor Magenta
        return $true
    }
    
    #Override
    [string] ToString() {
        return "UserInformationStep: NAME=$($this.name) MESSAGE=$($this.message)"
    }
}

#Definition of a file operation step. Examples are copy, delete, and write. 
class FileOperationStep : InstallStep {

    [FileMode]  $mode
    [string]    $file
    [string]    $destination
    [string]    $content

    #Default constructor
    FileOperationStep() {
        throw("Default constructor for class FileOperationStep cannot be called.")
    }

    #Full constructor
    FileOperationStep([string] $name, [FileMode] $mode, [string] $file, [string] $destination, [string] $content) {
        $this.Init($name, $mode, $file, $destination, $content)
    }

    #Delete/Register constructor
    FileOperationStep([string] $name, [FileMode] $mode, [string] $file) {
        $this.Init($name, $mode, $file, [string]::Empty, [string]::Empty)
    }

    #Move/Copy/Append/Write/Expand constructor
    FileOperationStep([string] $name, [FileMode] $mode, [string] $file, [string] $fourthArg) {
        #All four of these modes require a constructor with the signature FileOperationStep(string, FileMode, string, string)
        #So we need to use the mode to determine how the fourth argument is passed - either as the destination in the case
        #of move and copy, or the content for the file as in the case of append and write.
        switch($mode) {
            ( [FileMode]::Move     ) { $this.Init($name, $mode, $file, $fourthArg, [string]::Empty); break }
            ( [FileMode]::Copy     ) { $this.Init($name, $mode, $file, $fourthArg, [string]::Empty); break }
            ( [FileMode]::Expand   ) { $this.Init($name, $mode, $file, $fourthArg, [string]::Empty); break }
            ( [FileMode]::Append   ) { $this.Init($name, $mode, $file, [string]::Empty, $fourthArg); break }
            ( [FileMode]::Write    ) { $this.Init($name, $mode, $file, [string]::Empty, $fourthArg); break }
            ( [FileMode]::Link     ) { $this.Init($name, $mode, $file, [string]::Empty, $fourthArg); break }
            #The following really shouldn't ever be used, instead call FileOperationStep(string, FileMode, string)
            ( [FileMode]::Delete   ) { $this.Init($name, $mode, $file, [string]::Empty, [string]::Empty); break }
            ( [FileMode]::Register ) { $this.Init($name, $mode, $file, [string]::Empty, [string]::Empty); break }

            Default { $this.Init('Default file step', [FileMode]::Copy, [string]::Empty, [string]::Empty, [string]::Empty) }
        }
    }

    hidden [void] Init([string] $name, [FileMode] $mode, [string] $file, [string] $destination, [string] $content) {
        $this.name          = $name
        $this.mode          = $mode
        $this.file          = $file
        $this.destination   = $destination
        $this.content       = $content

    }

    #Override
    [bool] Run() {
        $result = $true
        try {
            switch($this.mode) {
                ([FileMode]::Write) {
                    $this.content | Out-File -FilePath $this.file -Force:$true
                    break 
                }
                ([FileMode]::Append) { 
                    $this.content | Out-File -FilePath $this.file -Append:$true -Force:$true
                    break 
                }
                ([FileMode]::Copy) { 
                    Copy-Item -Path $this.file -Destination $this.destination
                    break 
                }
                ([FileMode]::Delete) { 
                    Remove-Item -Path $this.file -Force:$true
                    break 
                }
                ([FileMode]::Link) {
                    $linkPath = Split-Path -Path $this.file -Parent
                    $linkName = Split-Path -Path $this.file -Leaf
                    New-Item -ItemType SymbolicLink -Name $linkName -Path $linkPath -Value $this.content -Force:$true
                    break
                }
                ([FileMode]::Expand) {
                    Expand-Archive -Path $this.file -DestinationPath $this.destination -Force
                    break
                }
                ([FileMode]::Register) {
                    $exitCode = (Start-Process -FilePath 'regsvr32.exe' -ArgumentList "/s $($this.file)" -Wait:$true -PassThru:$true).ExitCode

                    if( ($exitCode -ne 0) -and ($exitCode -ne 3010) ) {
                        $result = $false
                    }
                    break
                }
                Default {
                    $result = $false
                }
            }
        } catch {
            $result = $false
        }
        return $result
    }

    #Override
    [string] ToString() {
        return "FileOperationStep: NAME=$($this.name) MODE=$($this.mode) FILE=$($this.file) DESTINATION=$($this.destination) CONTENT=$($this.content)"
    }
}

class FolderOperationStep : InstallStep {
    [FolderMode] $mode
    [string] $folder
    [string] $destination

    #Default constructor
    FolderOperationStep() {
        throw("Default constructor for class FolderOperationStep cannot be called.")
    }

    #Create/Delete constructor
    FolderOperationStep([string] $name, [FolderMode] $mode, [string] $folder) {
        $this.Init($name, $mode, $folder, [string]::Empty)
    }

    #Move/Copy constructor
    FolderOperationStep([string] $name, [FolderMode] $mode, [string] $folder, [string] $destination) {
        $this.Init($name, $mode, $folder, $destination)
    }

    hidden [void] Init([string] $name, [FolderMode] $mode, [string] $folder, [string] $destination) {
        $this.name          = $name
        $this.mode          = $mode
        $this.folder        = $folder
        $this.destination   = $destination
    }

    #Override
    [bool] Run() {
        $result = $true
            try {       
                switch($this.mode) {
                    ([FolderMode]::Create) {
                        New-Item -Path $this.folder -ItemType Directory -Force:$true
                        break
                    }
                    ([FolderMode]::Move) {
                        Move-Item -Path $this.folder -Destination $this.destination
                        break
                    }
                    ([FolderMode]::Copy) {
                        Copy-Item -Path $this.folder -Destination $this.destination -Recurse:$true
                        break
                    }
                    ([FolderMode]::Delete) {
                        Remove-Item -Path $this.folder -Force:$true -Recurse:$true
                        break
                    }
                    Default {
                        $result = $false
                    }
                }
            } catch {
                $result = $false
            }
        return $result
    }
    #Override
    [string] ToString() {
        return "FolderOperationStep: NAME=$($this.name) MODE=$($this.mode) FOLDER=$($this.folder) DESTINATION=$($this.destination)"
    }
}

#Definition of an installer that is in the form of an executable file.
class ExecutableStep : InstallStep {

    [string] $installer
    [string] $arguments

    ExecutableStep() {
        throw("Default constructor for class ExecutableStep cannot be called.")
    }

    #No arguments installer
    ExecutableStep([string] $name, [string] $installer) {
        $this.Init($name, $installer, [string]::Empty)
    }

    ExecutableStep([string] $name, [string] $installer, [string] $arguments) {
        $this.Init($name, $installer, $arguments)
    }

    hidden [void] Init([string] $name, [string] $installer, [string] $arguments) {
        $this.name      = $name
        $this.installer = $installer
        $this.arguments = $arguments

    }

    #Override
    [bool] Run() {
        $result = $true
        try {
            $exitCode = 0
            if([string]::IsNullOrEmpty($this.arguments) -eq $true) {
                $exitCode = (Start-Process -FilePath $this.installer -PassThru:$true -Wait:$true).ExitCode
            } else {
                $exitCode = (Start-Process -FilePath $this.installer -ArgumentList $this.arguments -PassThru:$true -Wait:$true).ExitCode
            }
            if(($exitCode -ne 0) -and ($exitCode -ne 3010))  { #3010 is an acceptable error code; it just means you have to restart
                Write-Host $exitCode -ForegroundColor Blue
                $result = $false
            } 
        } catch {
            Write-Host $_ -ForegroundColor Blue
            $result = $false
        }
        return $result
    }

    #Override
    [string] ToString() {
        return "ExecutableStep: NAME=$($this.name) INSTALLER=$($this.installer) ARGUMENTS=$($this.arguments)"
    }
}

#Definition of an installer that is in msi form
class MsiStep : InstallStep {

    [string] $msi
    [string] $arguments

    MsiStep() {
        throw("Default constructor for class MsiStep cannot be called.")
    }

    MsiStep([string] $name, [string] $msi) {
        $this.Init($name, $msi, [string]::Empty)
    }

    MsiStep([string] $name, [string] $msi, [string] $arguments) {
        $this.Init($name, $msi, $arguments)
    }

    hidden [void] Init([string] $name, [string] $msi, [string] $arguments) {
        $this.name      = $name
        $this.msi       = $msi
        $this.arguments = $arguments

    }

    #Override
    [bool] Run() {
        $result = $true
        try {
            $exitCode = (Start-Process -FilePath 'msiexec.exe' -ArgumentList "/i `"$($this.msi)`" $($this.arguments)" -Wait:$true -PassThru:$true).ExitCode
            if(($exitCode -ne 0) -and ($exitCode -ne 3010)) {
                $result = $false
            } 
        } catch {
            $result = $false
        }
        return $result
    }

    #Override
    [string] ToString() {
        return "MsiStep: NAME=$($this.name) MSI=$($this.msi) ARGUMENTS=$($this.arguments)"
    }
}

#This is the definition of a complete installation task. An installation consists of a series of steps
#executed one after the other. 
class InstallTask {
    [System.Collections.Generic.List[InstallStep]] $installSteps
    [string] $name

    InstallTask([string] $name) {
        $this.Init($name)
    }

    hidden [void] Init($name) {
        $this.name = $name
        $this.installSteps = [System.Collections.Generic.List[InstallStep]]::new()
    }

    [void] AddStep([InstallStep] $step) {
        $this.installSteps.Add($step)
    }

    [bool] Run() {
        [bool] $result = $true

        foreach($step in $this.installSteps) {
            $stepResult = $step.Run()
            $result = $result -and $stepResult

            if(-not $result) {
                break
            }
        }

        return $result
    }

    #Override
    [string] ToString() {
        return "InstallTask: NAME=$($this.name) STEPS=$($this.installSteps)"
    }
}