Dim shell, fso, cloudflaredPath, configPath, tunnelName, cmd
Set shell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

cloudflaredPath = shell.ExpandEnvironmentStrings("%LOCALAPPDATA%\Microsoft\WinGet\Packages\Cloudflare.cloudflared_Microsoft.Winget.Source_8wekyb3d8bbwe\cloudflared.exe")
If Not fso.FileExists(cloudflaredPath) Then
  cloudflaredPath = "cloudflared"
End If

configPath = "C:\Users\Widox\Desktop\ARGOS\ARGOS_RUNTIME\tools\cloudflared_config.example.yml"
tunnelName = "argos-remote"

cmd = """" & cloudflaredPath & """ tunnel --config """" & configPath & """" run " & tunnelName
shell.Run cmd, 0, False