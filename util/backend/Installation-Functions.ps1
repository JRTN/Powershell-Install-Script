try {
    #Begin script setup
    $frameworkFile = "$PsScriptRoot\Installation-Framework.ps1"
    . $frameworkFile
} catch {
    Write-Error -Message "Failed to import installation framework. Ending Script." -ErrorAction Stop
}

function New-UserInformationStep {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Message
    )
    $step = [UserInformationStep]::new($Name, $Message)

    return $step
}

function New-FileMoveStep {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $File,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Destination
    )

    $step = [FileOperationStep]::new($Name, [FileMode]::Move, $File, $Destination)

    return $step
}

function New-FileCopyStep {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $File,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Destination
    )

    $step = [FileOperationStep]::new($Name, [FileMode]::Copy, $File, $Destination)

    return $step
}

function New-FileExpandStep {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $File,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Destination
    )

    $step = [FileOperationStep]::new($Name, [FileMode]::Expand, $File, $Destination)

    return $step
}

function New-FileAppendStep {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $File,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Content
    )

    $step = [FileOperationStep]::new($Name, [FileMode]::Append, $File, $Content)

    return $step
}

function New-FileWriteStep {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $File,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Content
    )

    $step = [FileOperationStep]::new($Name, [FileMode]::Write, $File, $Content)

    return $step
}

function New-FileLinkStep {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $File,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Location
    )

    $step = [FileOperationStep]::new($Name, [FileMode]::Link, $File, $Location)

    return $step
}

function New-FileDeleteStep {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $File
    )

    $step = [FileOperationStep]::new($Name, [FileMode]::Delete, $File)

    return $step
}

function New-FileRegisterStep {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $File
    )

    $step = [FileOperationStep]::new($Name, [FileMode]::Register, $File)

    return $step
}

function New-FolderCreateStep {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Folder
    )

    $step = [FolderOperationStep]::new($Name, [FolderMode]::Create, $Folder)

    return $step
}

function New-FolderDeleteStep {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Folder
    )

    $step = [FolderOperationStep]::new($Name, [FolderMode]::Delete, $Folder)

    return $step
}

function New-FolderMoveStep {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Folder,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Destination
    )

    $step = [FolderOperationStep]::new($Name, [FolderMode]::Move, $Folder, $Destination)

    return $step
}

function New-FolderCopyStep {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Folder,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Destination
    )

    $step = [FolderOperationStep]::new($Name, [FolderMode]::Copy, $Folder, $Destination)

    return $step
}

function New-ExecutableStep {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Executable,
        [Parameter(Mandatory=$false)]
        [string] $Arguments=[string]::Empty
    )

    $step = [ExecutableStep]::new($Name, $Executable, $Arguments)

    return $step
}

function New-MsiStep {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Msi,
        [Parameter(Mandatory=$false)]
        [string] $Arguments=[string]::Empty
    )

    $step = [MsiStep]::new($Name, $Msi, $Arguments)

    return $step
}

function New-InstallTask {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Name
    )

    $task = [InstallTask]::new($Name)

    return $task
}

