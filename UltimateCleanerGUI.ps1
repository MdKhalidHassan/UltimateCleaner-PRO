Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Form setup
$form = New-Object System.Windows.Forms.Form
$form.Text = "UltimateCleaner PRO — GUI `& Help"
$form.Size = New-Object System.Drawing.Size(650,550)
$form.StartPosition = "CenterScreen"

# Options & Help text
$options = @{
    "Prefetch Folder" = "Clears Windows prefetch files. Apps may load slightly slower temporarily."
    "%TEMP% Folder" = "Removes temporary files. Active files will be skipped."
    "Windows Update Cache" = "Cleans SoftwareDistribution\\Download folder. Ongoing updates may be affected."
    "Chrome/Edge Cache" = "Clears browser local cache. Cookies/Profile safe."
    "Thumbnail Cache" = "Removes explorer thumbnail cache. First browse may be slow."
    "Flush DNS" = "Clears DNS resolver cache."
    "Release RAM" = "Runs idle tasks to free up RAM."
    "Disk Cleanup (cleanmgr)" = "Runs Windows Disk Cleanup as per sageset configuration."
}

$y=20
$checkboxes = @()
foreach ($opt in $options.Keys) {
    $cb = New-Object System.Windows.Forms.CheckBox
    $cb.Text = $opt
    $cb.Location = New-Object System.Drawing.Point(20,[int]$y)
    $cb.Size = New-Object System.Drawing.Size(250,20)
    $cb.Checked = $true
    $form.Controls.Add($cb)
    $checkboxes += $cb

    # Help button
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = "?"
    $btn.Size = New-Object System.Drawing.Size(30,20)
    $btn.Location = New-Object System.Drawing.Point(280,[int]$y)
    $btn.Add_Click({
        [System.Windows.Forms.MessageBox]::Show($options[$opt], "Help for $opt")
    })
    $form.Controls.Add($btn)

    $y += 30
}

# Calculate positions for other controls
$dryRunY = [int]($y + 20)
$runBtnY = [int]($y + 20)
$rpLabelY = [int]($y + 60)

# Dry-Run button
$dryRunBtn = New-Object System.Windows.Forms.Button
$dryRunBtn.Text = "Dry-Run"
$dryRunBtn.Location = New-Object System.Drawing.Point(20, $dryRunY)
$dryRunBtn.Add_Click({
    $report = "UltimateCleaner PRO - Dry Run Report`n`n"
    foreach ($i in 0..($checkboxes.Count-1)) {
        if ($checkboxes[$i].Checked) {
            $optName = $checkboxes[$i].Text
            $report += "Option Selected: $optName`n"
            switch ($optName) {
                "Prefetch Folder" { $report += "Files that would be deleted: C:\Windows\Prefetch\*`n" }
                "%TEMP% Folder" { $report += "Files that would be deleted: $env:TEMP\* and C:\Windows\Temp\*`n" }
                "Windows Update Cache" { $report += "Files that would be deleted: C:\Windows\SoftwareDistribution\Download\*`n" }
                "Chrome/Edge Cache" { $report += "Files that would be deleted: Chrome/Edge Cache folders`n" }
                "Thumbnail Cache" { $report += "Files that would be deleted: Explorer thumbcache_*.db`n" }
                "Flush DNS" { $report += "DNS resolver cache would be flushed`n" }
                "Release RAM" { $report += "Idle tasks would be run to release RAM`n" }
                "Disk Cleanup (cleanmgr)" { $report += "Disk Cleanup (cleanmgr) would run`n" }
            }
        }
    }

    # Save to Desktop log
    $logPath = "$env:USERPROFILE\Desktop\UltimateCleanerDryRunReport.txt"
    $report | Out-File -FilePath $logPath -Encoding UTF8

    [System.Windows.Forms.MessageBox]::Show("Dry-Run Complete! Report saved to Desktop.`n$logPath","Dry-Run Report")
})
$form.Controls.Add($dryRunBtn)

# Run button
$runBtn = New-Object System.Windows.Forms.Button
$runBtn.Text = "Run (Admin)"
$runBtn.Location = New-Object System.Drawing.Point(120, $runBtnY)
$runBtn.Add_Click({
    foreach ($i in 0..($checkboxes.Count-1)) {
        if ($checkboxes[$i].Checked) {
            $optName = $checkboxes[$i].Text
            switch ($optName) {
                "Prefetch Folder" { Remove-Item "C:\Windows\Prefetch\*" -Force -ErrorAction SilentlyContinue }
                "%TEMP% Folder" { 
                    Remove-Item "$env:TEMP\*" -Force -Recurse -ErrorAction SilentlyContinue
                    Remove-Item "C:\Windows\Temp\*" -Force -Recurse -ErrorAction SilentlyContinue
                }
                "Windows Update Cache" { Remove-Item "C:\Windows\SoftwareDistribution\Download\*" -Force -Recurse -ErrorAction SilentlyContinue }
                "Chrome/Edge Cache" { 
                    Remove-Item "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache\*" -Force -Recurse -ErrorAction SilentlyContinue
                    Remove-Item "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache\*" -Force -Recurse -ErrorAction SilentlyContinue
                }
                "Thumbnail Cache" { Remove-Item "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db" -Force -ErrorAction SilentlyContinue }
                "Flush DNS" { ipconfig /flushdns }
                "Release RAM" { rundll32.exe advapi32.dll,ProcessIdleTasks }
                "Disk Cleanup (cleanmgr)" { cleanmgr /sagerun:1 }
            }
        }
    }
    [System.Windows.Forms.MessageBox]::Show("Cleaning Finished Successfully!","UltimateCleaner PRO")
})
$form.Controls.Add($runBtn)

# Restore Point label
$rpLabel = New-Object System.Windows.Forms.Label
$rpLabel.Text = "💡 Recommended: Keep Restore Point ON before running. Allows system recovery if needed."
$rpLabel.Location = New-Object System.Drawing.Point(20, $rpLabelY)
$rpLabel.Size = New-Object System.Drawing.Size(600,40)
$form.Controls.Add($rpLabel)

# Show Form
$form.Add_Shown({$form.Activate()})
[void] $form.ShowDialog()
