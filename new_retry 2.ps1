Add-Type -AssemblyName UIAutomationClient

$blockedApps = @("chrome", "msedge", "firefox", "claude")

$lastState = ""

while ($true) {

    $proc = Get-Process | Where-Object {
        $_.MainWindowHandle -ne 0 -and
        $_.MainWindowTitle -like "*Antigravity*"
    }

    if ($proc) {

        try {
            $hwnd = $proc.MainWindowHandle
            $element = [System.Windows.Automation.AutomationElement]::FromHandle($hwnd)

            $condition = New-Object System.Windows.Automation.AndCondition(
                (New-Object System.Windows.Automation.PropertyCondition(
                    [System.Windows.Automation.AutomationElement]::NameProperty, "Retry"
                )),
                (New-Object System.Windows.Automation.PropertyCondition(
                    [System.Windows.Automation.AutomationElement]::ControlTypeProperty,
                    [System.Windows.Automation.ControlType]::Button
                ))
            )

            $btn = $element.FindFirst(
                [System.Windows.Automation.TreeScope]::Descendants,
                $condition
            )

            if ($btn -and ($blockedApps -notcontains $proc.ProcessName.ToLower())) {

                $invokePattern = $btn.GetCurrentPattern(
                    [System.Windows.Automation.InvokePattern]::Pattern
                )

                $invokePattern.Invoke()

                if ($lastState -ne "clicked") {
                    Write-Host "Retry clicked ONLY in Antigravity"
                    $lastState = "clicked"
                }

            }
            else {
                $lastState = "idle"
            }

        }
        catch {
            if ($lastState -ne "safe") {
                Write-Host "Safe mode active"
                $lastState = "safe"
            }
        }
    }

    Start-Sleep -Seconds 2
}
