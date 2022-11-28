# Execute "Set-ExecutionPolicy RemoteSigned" if you see "....ps1 cannot be loaded because running scripts is disabled on this system. ..."

if (-not (Get-Command -Name "$PSScriptRoot\bin\ffmpeg.exe" 2>$null)) {
  cmd /c copy /b 'bin\ffmpeg.exe.0+bin\ffmpeg.exe.1+bin\ffmpeg.exe.2' 'bin\ffmpeg.exe' | Out-Null
}

if (-not (Get-Command -Name "$PSScriptRoot\bin\ffmpeg.exe" 2>$null)) {
  Write-Error -Message "$PSScriptRoot\bin\ffmpeg.exe is not executable"
  pause
  exit 1
}

$cameras = @()

& $PSScriptRoot\bin\ffmpeg.exe -list_devices true -f dshow -i dummy -hide_banner 2>&1 `
    | Select-String -Pattern '^\[dshow @ [A-Za-z0-9]+\] "(.*)" \(video\)$' `
    | Select-Object Matches | ForEach-Object {
  $cameras += $_.Matches.Groups[1].Value
}

if (-not ($cameras.Length)) {
  Write-Error "No camera can be found"
  pause
  exit 1
}

$camera_index = 0

if ($cameras.Length -gt 1) {
  for ($i = 0; $i -lt $cameras.Length; $i++) {
    Write-Host "$($i+1)) $($cameras[$i])"
  }
  $choice = $(Read-Host -Prompt "Choose the camera # [default=1]")
  $camera_index = $choice - 1
  if (-not $choice) {
    $camera_index = 0
  }
}

& $PSScriptRoot\bin\ffmpeg.exe -f dshow -show_video_device_dialog true -i video="$($cameras[$camera_index])" 2>&1 | Out-Null
