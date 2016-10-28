$Interval = 30
do {
    # Stop?
    # SHow
    cls
    Write-Host "OS States as of $([DateTime]::Now)"
    gos | sos
    # Cue User
    Write-Host "Next Update at $([DateTime]::Now.AddSeconds( $Interval ))..."
    # Pause
    Start-Sleep -Seconds $Interval
    # Loop
} while( $true )