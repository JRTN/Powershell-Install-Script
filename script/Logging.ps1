Class PsLogger {
    hidden $logLocation = ""
    hidden $ExecutingScript = ""
    hidden $logFile = ""
    
    PsLogger([string]$logLocation, [string]$ExecutingScript) {
        $this.logLocation = $logLocation
        $this.ExecutingScript = $ExecutingScript

        # Check for and build log path
        if (!(Test-Path -Path $this.logLocation)) {
            [void](New-Item -path $this.logLocation -ItemType directory -force)
        }

        $Date = Get-Date -Format "MM-dd-yy.HH-mm"
        $this.logFile = New-Item -ItemType File -Name "$ExecutingScript`_$($Date.ToString()).log" -Path $logLocation -Force
    }

    Emergency([string]$message) {
        $this.LogMessage($message, "Emergency")
    }

    Alert([string]$message) {
        $this.LogMessage($message, "Alert")
    }

    Critical([string]$message) {
        $this.LogMessage($message, "Critical")
    }

    Error([string]$message) {
        $this.LogMessage($message, "Error")
    }

    Warning([string]$message) {
        $this.LogMessage($message, "Warning")
    }

    Notice([string]$message) {
        $this.LogMessage($message, "Notice")
    }

    Informational([string]$message) {
        $this.LogMessage($message, "Informational")
    }

    Debug([string]$message) {
        $this.LogMessage($message, "Debug")
    }
    
    hidden LogMessage([string]$message, [string]$severity) {
        $funcName = (Get-PSCallStack).FunctionName[2]

        if ($funcName -eq "<ScriptBlock>") {
            $funcName = "N/A"
        }

        $Timestamp = Get-Date -Format "HH:mm:ss"

        $msg = '[{0}] [{1}] {2} - {3}' -f $Timestamp.ToString(), $severity, $funcName, $message
        $msg | Out-File -LiteralPath $this.logFile.FullName -Append:$true -Force:$true
    }
}
