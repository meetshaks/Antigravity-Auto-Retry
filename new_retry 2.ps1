Add-Type -AssemblyName UIAutomationClient

$blockedApps = @("chrome", "msedge", "firefox", "claude", "opera")

while ($true) {

    # 1️⃣ ONLY Antigravity window
    $proc = Get-Process | Where-Object {
        $_.MainWindowHandle -ne 0 -and
        $_.MainWindowTitle -like "*Antigravity*"
    }

    if ($proc) {

        try {
            $hwnd = $proc.MainWindowHandle
            $element = [System.Windows.Automation.AutomationElement]::FromHandle($hwnd)

            # 2️⃣ Strict Retry button match
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

            # 3️⃣ FINAL SAFETY CHECK (process whitelist)
            if ($btn -and ($blockedApps -notcontains $proc.ProcessName.ToLower())) {

                $invokePattern = $btn.GetCurrentPattern(
                    [System.Windows.Automation.InvokePattern]::Pattern
                )

                $invokePattern.Invoke()
                Write-Host "Retry clicked ONLY in Antigravity"
            }

        }
        catch {
            Write-Host "Skipped cycle (safe mode)"
        }
    }

    Start-Sleep -Seconds 2
}