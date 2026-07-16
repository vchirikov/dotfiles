Import-Module posh-git
$env:POSH_GIT_ENABLED = $true
Invoke-Expression (oh-my-posh init pwsh --config="q:\code\vchirikov\dotfiles\oh-my-posh\config.omp.json")

$env:RCLONE_CONFIG = "Q:\code\vchirikov\dotfiles\secrets\rclone.conf"

# color helpers
[string] $color_red = "`e[0;31m";
[string] $color_green = "`e[0;32m";
[string] $color_off = "`e[0m";

# for profiling
#Import-Module PSProfiler
#Measure-Script {
Import-Module PSReadLine
# zsh-like menu complete, for bash-like use `Complete`
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
# Show auto-complete predictions from history

$PSReadLineOptions = @{
    BellStyle                     = "None"
    HistoryNoDuplicates           = $true
    HistorySearchCursorMovesToEnd = $true
    ShowToolTips                  = $true
    PredictionSource              = "history"
}

Set-PSReadLineOption @PSReadLineOptions
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# FZF bindings for powershell, should be imported after PSReadLine - https://github.com/kelleyma49/PSFzf
# Install-Module -Name PSFzf
# also choco install fzf fd
Remove-PSReadlineKeyHandler 'Ctrl+r'
Remove-PSReadlineKeyHandler 'Ctrl+t'

$env:FZF_DEFAULT_COMMAND = 'fd --color=always --type file --follow --hidden --exclude .git'
$env:FZF_DEFAULT_OPTS = '--color=dark,gutter:#22262e,bg+:#303b4d --height 40% --layout=reverse';
$env:FZF__OPTS = '--color=dark,gutter:#22262e,bg+:#303b4d --height 40% --layout=reverse';
$env:BAT_PAGER = ''
$env:KUBE_EDITOR = 'code -w'

# https://github.com/nickcox/cd-extras
# https://github.com/nickcox/cd-extras/issues/40
# $cde = @{
#     AUTO_CD  = $true
#     CD_PATH  = 'q:\\code\\Telgorithm', 'q:\\code\\vchirikov'
#     NOARG_CD = 'q:\\code'
# }
Import-Module cd-extras

setocd AUTO_CD $true
#setocd CD_PATH 'q:\\code\\alphy', 'q:\\code\\vchirikov'
setocd CD_PATH 'q:\\code\\vchirikov'
setocd NOARG_CD 'q:\\code'
# https://github.com/DHowett/DirColors, maybe later
setocd ColorCompletion $false


Import-Module PSFzf
# Fzf tab completion
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
Set-PsFzfOption -EnableFd -TabExpansion -GitKeyBindings -EnableAliasFuzzyEdit -EnableAliasFuzzyHistory -EnableAliasFuzzyKillProcess -EnableAliasFuzzySetLocation -EnableAliasFuzzySetEverything

Set-Alias fzf Invoke-Fzf
Set-Alias whereis Get-Command

# Set-Alias sed 'C:\Program Files\Git\usr\bin\sed.exe'
# Set-Alias nano 'C:\Program Files\Git\usr\bin\nano.exe'

# it's better to use [ShimGen](https://docs.chocolatey.org/en-us/features/shim) for sed/nano etc (note, path must be relative)

# c:\ProgramData\chocolatey\tools\shimgen.exe --output=c:\ProgramData\Chocolatey\bin\sed.exe --path="..\..\..\Program Files\Git\usr\bin\sed.exe"
# c:\ProgramData\chocolatey\tools\shimgen.exe --output=c:\ProgramData\Chocolatey\bin\grep.exe --path="..\..\..\Program Files\Git\usr\bin\grep.exe"
# c:\ProgramData\chocolatey\tools\shimgen.exe --output=c:\ProgramData\Chocolatey\bin\nano.exe --path="..\..\..\Program Files\Git\usr\bin\nano.exe"
# c:\ProgramData\chocolatey\tools\shimgen.exe --output=c:\ProgramData\Chocolatey\bin\vim.exe --path="..\..\..\Program Files\Git\usr\bin\vim.exe"
# c:\ProgramData\chocolatey\tools\shimgen.exe --output=c:\ProgramData\Chocolatey\bin\vi.exe --path="..\..\..\Program Files\Git\usr\bin\vim.exe"


# https://github.com/chawyehsu/base16-concfg colors
$GitPromptSettings.DefaultPromptPath.ForegroundColor = 0x61F053 ;
$GitPromptSettings.DefaultPromptBeforeSuffix.Text = ''
$GitPromptSettings.DefaultPromptSuffix.Text = ''
$GitPromptSettings.DefaultPromptEnableTiming = $false;
$GitPromptSettings.DefaultPromptTimingFormat = "`e[93m[{0}ms]`e[0m";

# disable posh-git title logic
$GitPromptSettings.WindowTitle = $null;

# function prompt {
#     # add posh-git default prompt
#     $prompt = ""
#     $command = Get-History -Count 1
#     $prompt += & $GitPromptScriptBlock
#     if ($command) {
#         [TimeSpan] $span = $command.EndExecutionTime - $command.StartExecutionTime;
#         $prompt += "`e[93m 祥 ";
#         $format = "N2";
#         $prompt += $($span.TotalMilliseconds -lt 1000 ? $span.TotalMilliseconds.ToString($format, [System.Globalization.CultureInfo]::InvariantCulture) + "ms"
#             : ($span.TotalSeconds -lt 60 ? $span.TotalSeconds.ToString($format, [System.Globalization.CultureInfo]::InvariantCulture) + "s"
#                 : ($span.TotalMinutes -lt 60 ? $span.TotalMinutes.ToString($format, [System.Globalization.CultureInfo]::InvariantCulture) + "m"
#                     : ($span.TotalHours -lt 24 ? $span.TotalHours.ToString($format, [System.Globalization.CultureInfo]::InvariantCulture) + "h"
#                         : $span.TotalDays.ToString($format, [System.Globalization.CultureInfo]::InvariantCulture) + "d")))).ToString();
#         $prompt += "`e[0m";
#     }
#     $prompt += "`e[31m>`e[0m"
#     $host.ui.RawUI.WindowTitle = Get-Location | Split-Path -leaf
#     "$prompt "
# }

# returns is current user an admin or not via checking well-known SID of the admin group
function isAdmin {
    [Security.Principal.WindowsIdentity]::GetCurrent().Groups -contains 'S-1-5-32-544'
}

# https://github.com/Canop/broot
function mouse_on {
    $unixCmd = 'printf "\x1B[?1003h\x1B[?1006h"';
    wsl $unixCmd.Split(' ')
}

function mouse_off {
    $unixCmd = 'printf "\e[?1000l"';
    wsl $unixCmd.Split(' ')
}

function far {
    $dir = [System.IO.Path]::GetFullPath($PWD);
    mouse_on;
    & "C:\Program Files\Far Manager\Far.exe" $dir
    mouse_off;
}

function br {
    mouse_on;
    $tempFile = New-TemporaryFile
    try {
        $broot = $env:BROOT
        if (-not $broot) {
            $broot = 'broot'
        }
        & $broot --outcmd $tempFile $args
        if ($LASTEXITCODE -ne 0) {
            Write-Error "$broot exited with code $LASTEXITCODE"
            return
        }
        $command = Get-Content $tempFile
        if ($command) {
            # broot returns extended-length paths but not all PowerShell/Windows
            # versions might handle this so strip the '\\?'
            Invoke-Expression $command.Replace("\\?\", "")
        }
    }
    finally {
        mouse_off;
        Remove-Item -force $tempFile
    }
}

function br {
    mouse_on;
    $tempFile = New-TemporaryFile
    try {
        $broot = $env:BROOT
        if (-not $broot) {
            $broot = 'broot'
        }
        & $broot --outcmd $tempFile $args
        if ($LASTEXITCODE -ne 0) {
            Write-Error "$broot exited with code $LASTEXITCODE"
            return
        }
        $command = Get-Content $tempFile
        if ($command) {
            # broot returns extended-length paths but not all PowerShell/Windows
            # versions might handle this so strip the '\\?'
            Invoke-Expression $command.Replace("\\?\", "")
        }
    }
    finally {
        mouse_off;
        Remove-Item -force $tempFile
    }
}

# PowerShell parameter completion shim for the dotnet CLI
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
    dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

# PowerShell parameter completion for the dotnet CLI and slngen local tool
Register-ArgumentCompleter -Native -CommandName "dotnet" -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
    [string] $cmd = $wordToComplete.Extent.ToString().Replace('"', '\"');
    if ($cmd.StartsWith("dotnet slngen", [System.StringComparison]::OrdinalIgnoreCase)) {

        [string] $configPath = $([System.IO.Path]::Combine([System.IO.Path]::GetFullPath($PWD), ".config"));
        [string] $lastArg = $cmd.Split(" ", [System.StringSplitOptions]::RemoveEmptyEntries) | Select-Object -Last 1 ;
        if ($lastArg -eq "slngen" -or $cmd.EndsWith(' ') -or [System.IO.File]::Exists([System.IO.Path]::Combine($configPath, $lastArg + ".yaml"))) {
            return Get-ChildItem -Path $configPath -Filter "*.yaml" | 
            ForEach-Object { $([System.IO.Path]::GetFileNameWithoutExtension($_)) } | 
            Sort-Object |
            ForEach-Object { $([System.Management.Automation.CompletionResult]::new($_)) }
        }
        else {
            return Get-ChildItem -Path $configPath -Filter "*.yaml" | 
            ForEach-Object { $([System.IO.Path]::GetFileNameWithoutExtension($_)) } | 
            Where-Object { $_.StartsWith($lastArg, [StringComparison]::OrdinalIgnoreCase) } |
            Sort-Object |
            ForEach-Object { $([System.Management.Automation.CompletionResult]::new($_)) }
        }
    }
    else {
        return dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object { [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_) }
    }
}

function killall {
    param(
        [ArgumentCompleter(
            {
                param($cmd, $param, $values)
                get-process |
                Where-Object { $_.Name.StartsWith($values, [StringComparison]::OrdinalIgnoreCase) } |
                Select-Object Name -Unique |
                ForEach-Object { $_.Name } |
                Sort-Object
            }
        )]
        $ProcessName)
    stop-process -Name $ProcessName
}

function killDebugProxy {
    $stdOutTask = $(tasklist /fi "modules eq BrowserDebugHost.dll" /fo "csv" /nh)
    if ($stdOutTask.Contains("No tasks")) {
        Write-Host "`e[93mDebugProxy not found`e[0m";
    }
    else {
        try {
            $toKillPid = $stdOutTask.Split(',')[1].Trim('"');
            Write-Host "`e[93mKill DebugProxy with pid $($toKillPid)`e[0m";
            stop-process -Id $toKillPid
        }
        catch {}
    }
}

function kubeBusybox() {
    kubectl debug -it --target $(kubectl get pods -o name --all-namespaces | fzf) --image=busybox
}
function kubeRes {
    kubectl get pods -o custom-columns='POD:.metadata.name,CPU_REQUEST:.spec.containers[*].resources.requests.cpu,MEM_REQUEST:.spec.containers[*].resources.requests.memory,CPU_LIMIT:.spec.containers[*].resources.limits.cpu,MEM_LIMIT:.spec.containers[*].resources.limits.memory' $args
}

function curltime {
    curl -w "@Q:\tools\utils\curltime_format.txt" -o NUL -s $args
}

function pod() {
    # id = _quake doesn't work well with admin rights
    # createLnk "C:\Users\verysimplenick\AppData\Local\Microsoft\WindowsApps\wt.exe" "$PWD\wt_main.lnk" "q:\code\vchirikov\dotfiles\windows_terminal\terminal.ico" "-w main -d q:\code"
    kubectl get pods --all-namespaces | fzf.exe --info=inline --height 100% --layout=reverse --header-lines=1 `
        --prompt "$(kubectl config current-context | sed 's/-context$//')> " `
        --header "Enter (kubectl exec) / CTRL-L - open log / CTRL-O (open log in editor) / CTRL-R (reload) / CTRL+E change view`n`n" `
        --bind 'ctrl-e:change-preview-window(down,follow,90%,wrap,border-top|)' `
        --bind 'enter:execute-silent(wt.exe -w main sp -V pwsh -NoLogo -NoProfile -c kubectl exec -i -t -n {1} {2} -- sh)+abort' `
        --bind 'ctrl-o:execute(kubectl logs --all-containers --namespace {1} {2} | code -)' `
        --bind 'ctrl-l:execute(kubectl logs --all-containers --namespace {1} {2} --tail 100 -f)' `
        --bind 'ctrl-r:reload(kubectl get pods --all-namespaces)' `
        --preview-window 'down,follow,50%,wrap,border-top' `
        --preview 'kubectl logs --all-containers --tail=100 --namespace {1} {2}'
}

# spindown hdd

function spindown {
    param(
        [ArgumentCompleter(
            {
                param($cmd, $param, $values)
                smartctl --scan-open |
                Where-Object { $_.Contains("ATA device") } |
                ForEach-Object { $_.Split()[0] }  |
                Where-Object { $_.StartsWith($values, [StringComparison]::OrdinalIgnoreCase) } |
                Sort-Object |
                ForEach-Object { $([System.Management.Automation.CompletionResult]::new($_)) }
            }
        )]
        [string] $device)

    if ([string]::IsNullOrWhiteSpace($device)) {
        # stop all hdd
        smartctl --scan-open | Where-Object { $_.Contains("ATA device") } | ForEach-Object { $_.Split()[0] } | ForEach-Object { Write-Host "`e[93msmartctl -s standby,now $($_)`e[0m"; smartctl -s "standby,now" $($_) }
    }
    else {
        Write-Host "`e[93msmartctl -s standby,now $($device)`e[0m";
        smartctl -s "standby,now" $device
    }
}

# run visual studio
function vs {
    param(
        [ArgumentCompleter(
            {
                param($cmd, $param, $values)
                Get-ChildItem -Path $([System.IO.Path]::GetFullPath($PWD)) -Filter "*.slnx" |
                Where-Object { $_.Name.StartsWith($values, [StringComparison]::OrdinalIgnoreCase) } |
                ForEach-Object { $([System.IO.Path]::GetFileName($_)) } |
                Sort-Object |
                ForEach-Object { $([System.Management.Automation.CompletionResult]::new($_)) }
            }
        )]
        [string] $path)

    [string] $vsPath = "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe"
    if ([string]::IsNullOrWhiteSpace($path)) {
        $path = Get-ChildItem -Path $([System.IO.Path]::GetFullPath($PWD)) -Filter "*.slnx" | Select-Object -First 1;
        if ([string]::IsNullOrWhiteSpace($path)) {
            $path = $([System.IO.Path]::GetFullPath($PWD))
        }
    }
    else {
        if (!$path.Contains(':')) {
            $path = $([System.IO.Path]::Combine($PWD, $path))
        }
    }
    Start-Process -FilePath $vsPath -ArgumentList $([System.IO.Path]::GetFullPath($path))
}

function rider {
    param(
        [ArgumentCompleter(
            {
                param($cmd, $param, $values)
                Get-ChildItem -Path $([System.IO.Path]::GetFullPath($PWD)) -Filter "*.slnx" |
                Where-Object { $_.Name.StartsWith($values, [StringComparison]::OrdinalIgnoreCase) } |
                ForEach-Object { $([System.IO.Path]::GetFileName($_)) } |
                Sort-Object |
                ForEach-Object { $([System.Management.Automation.CompletionResult]::new($_)) }
            }
        )]
        [string] $path)

    $env:JETBRAINS_CLIENT_VM_OPTIONS = 'C:\Program Files\JetBrains\_\vmoptions\jetbrains_client.vmoptions';
    $env:JETBRAINSCLIENT_VM_OPTIONS = 'C:\Program Files\JetBrains\_\vmoptions\jetbrainsclient.vmoptions';
    $env:RIDER_VM_OPTIONS = 'C:\Program Files\JetBrains\_\vmoptions\rider.vmoptions';
    $env:STUDIO_VM_OPTIONS = 'C:\Program Files\JetBrains\_\vmoptions\studio.vmoptions';



    [string] $riderPath = "${env:ProgramFiles}\JetBrains\Rider\bin\rider64.exe"
    if ([string]::IsNullOrWhiteSpace($path)) {
        $path = Get-ChildItem -Path $([System.IO.Path]::GetFullPath($PWD)) -Filter "*.slnx" | Select-Object -First 1;
        if ([string]::IsNullOrWhiteSpace($path)) {
            $path = $([System.IO.Path]::GetFullPath($PWD))
        }
    }
    else {
        if (!$path.Contains(':')) {
            $path = $([System.IO.Path]::Combine($PWD, $path))
        }
    }
    Start-Process -FilePath $riderPath -ArgumentList $([System.IO.Path]::GetFullPath($path))
}

function camera_settings {
    # to get all cameras: ffmpeg -list_devices true -f dshow -i dummy -hide_banner
    ffmpeg -f dshow -show_video_device_dialog true -i "video=EMEET SmartCam S600"
}

function base64 {
    param([string] $str)
    $byte = [System.Text.Encoding]::UTF8.GetBytes($str);
    $result = [System.Convert]::ToBase64String($byte);
    Write-Output $result;
}
function unbase64 {
    param([string] $str)
    $decode = [System.Convert]::FromBase64String($str)
    $result = [System.Text.Encoding]::UTF8.GetString($decode)
    Write-Output $result;
}

# run debug msedge
function edgeDbg {
    param([string] $url)

    if ([string]::IsNullOrWhiteSpace($url)) {
        $url = "http://localhost:7080"
    }
    & "runas" /trustlevel:0x20000 "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe --disable-background-networking --disable-background-timer-throttling --disable-backgrounding-occluded-windows --disable-breakpad --disable-client-side-phishing-detection --disable-default-apps --disable-dev-shm-usage --disable-renderer-backgrounding --disable-sync --metrics-recording-only --no-first-run --no-default-browser-check --remote-debugging-port=9222  --profile-directory=Default $url"
}

function todo {
    & "Q:\tools\superproductivity\superProductivity.exe" "--user-data-dir=Q:\tools\superproductivity\data"
}
function removeFkingCreativeDrivers() {
    foreach ($dev in (Get-PnpDevice | Where-Object { $_.Name?.Contains("Sound Blaster", [System.StringComparison]::OrdinalIgnoreCase) -or ($_.Status -eq "Unknown" -and $_.Name?.Contains("Audio", [System.StringComparison]::OrdinalIgnoreCase) ) } )) {
        & "pnputil" /remove-device $dev.InstanceId
    }
}

function kubeDotnetDebug() {
    param(
        [ArgumentCompleter(
            {
                param($cmd, $param, $values)
                if ([string]::IsNullOrWhiteSpace($env:KUBECONFIG)) {
                    return;
                }
                & kubectl get nodes --all-namespaces -o name |
                ForEach-Object { $_.Substring(5) } |
                Sort-Object |
                ForEach-Object { $([System.Management.Automation.CompletionResult]::new($_)) }
            }
        )]
        [string] $node,
        [string] $app,
        [ArgumentCompletions('verysimplenick/dotnet-debug-image:6.0.101-bullseye-slim-amd64')]
        [string] $image,
        [ArgumentCompletions('IfNotPresent', 'Always', 'Never')]
        [string] $imagePullPolicy
    )
    if ([string]::IsNullOrWhiteSpace($image)) {
        $image = 'verysimplenick/dotnet-debug-image:6.0.101-bullseye-slim-amd64';
    }
    if ([string]::IsNullOrWhiteSpace($app)) {
        $app = 'dotnet';
    }
    # if something went wrong with access files - read related issue: https://github.com/moby/moby/issues/2259
    # [string] $command = '[ "/bin/bash", "-c", "dotnetPid=$(ps auxww | grep '+ $app +' | grep -v grep | awk ''{print $2}'') && find /proc/$dotnetPid/root/tmp/ -maxdepth 1 ! -name ''tmp'' ! -name  ''system-commandline-sentinel-files'' -exec sh -c ''ln -s {} /tmp/ > /dev/null 2>&1 || exit 0'' \\;  ; exec /bin/bash"]';
    [string] $command = '["/bin/bash", "-c", "' +
    'export dotnetPid=$(ps auxww | grep ' + $app + ' | grep -v grep | awk ''{print $2}'') ' +
    '&& echo $dotnetPid > /dotnetPid ' +
    '; ln -s /proc/$dotnetPid/root/tmp/ /tmp_external ' +
    '; cp -u -r /root/vsdbg /proc/$dotnetPid/root/root/ > /dev/null 2>&1 ' +
    '; cp -u /bin/ps /proc/$dotnetPid/root/bin/ps > /dev/null 2>&1 ' +
    '; exec /bin/bash' +
    '"]';
    kubeNodeExec $node 'dotnet-debug' $command $image $imagePullPolicy 'true' ;
}

function kubeNodeShell() {
    param(
        [ArgumentCompleter(
            {
                param($cmd, $param, $values)
                if ([string]::IsNullOrWhiteSpace($env:KUBECONFIG)) {
                    return;
                }
                & kubectl get nodes --all-namespaces -o name |
                ForEach-Object { $_.Substring(5) } |
                Sort-Object |
                ForEach-Object { $([System.Management.Automation.CompletionResult]::new($_)) }
            }
        )]
        [string] $node,
        [ArgumentCompletions('/bin/bash', '/bin/ash', '/bin/sh', '/bin/zsh')]
        [string] $shell
    )
    if ([string]::IsNullOrWhiteSpace($shell)) {
        $shell = '/bin/bash';
    }
    # do not use spaces here, it will break .Split(' ')
    [string] $command = "[""/nsenter"",""--target"",""1"",""--mount"",""--uts"",""--ipc"",""--net"",""--pid"",""--"",""$shell""]";
    kubeNodeExec "$node" 'node-shell' "$command" "alexeiled/nsenter:2.38.1" 'IfNotPresent' 'true' ;
}

function kubeNodeExec {
    param(
        [ArgumentCompleter(
            {
                param($cmd, $param, $values)
                if ([string]::IsNullOrWhiteSpace($env:KUBECONFIG)) {
                    return;
                }
                & kubectl get nodes --all-namespaces -o name |
                ForEach-Object { $_.Substring(5) } |
                Sort-Object |
                ForEach-Object { $([System.Management.Automation.CompletionResult]::new($_)) }
            }
        )]
        [string] $node,
        [string] $pod,
        [string] $command,
        [string] $image,
        [ArgumentCompletions('IfNotPresent', 'Always', 'Never')]
        [string] $imagePullPolicy,
        [ArgumentCompletions('true', 'false')]
        [string] $tty
    )

    if ([string]::IsNullOrWhiteSpace($node)) {
        Write-Output 'Specify a node';
        return;
    }
    if ([string]::IsNullOrWhiteSpace($pod)) {
        Write-Output 'Specify a pod name';
        return;
    }
    if ([string]::IsNullOrWhiteSpace($command)) {
        Write-Output 'Specify a command';
        return;
    }
    if ([string]::IsNullOrWhiteSpace($image)) {
        Write-Output 'Specify an image';
        return;
    }
    if ([string]::IsNullOrWhiteSpace($imagePullPolicy)) {
        $imagePullPolicy = 'IfNotPresent';
    }
    if ([string]::IsNullOrWhiteSpace($tty)) {
        $tty = 'true';
    }
    # do not use spaces here, it will break .Split(' ')
    [string] $json = "{""spec"":{""nodeName"":""$node"",""hostPID"":true,""hostNetwork"":true,""hostIPC"":true,""privileged"":true,""allowPrivilegeEscalation"":true,""allowedUnsafeSysctls"":[""*""],""containers"":[{""securityContext"":{""privileged"":true,""capabilities"":{""add"":[""SYS_PTRACE"",""SYS_CHROOT"",""SYS_ADMIN"",""SETGID"",""SETUID"",""CHOWN"",""IPC_LOCK"",""IPC_OWNER"",""CAP_SYS_ADMIN""]}},""image"":""$image"",""imagePullPolicy"":""$imagePullPolicy"",""name"":""$pod"",""stdin"":true,""stdinOnce"":true,""tty"":$tty,""command"":$command}],""tolerations"":[{""operator"":""Exists""}]}}";

    [string] $ctlArgs = "run $pod --pod-running-timeout=5m0s --image-pull-policy=$imagePullPolicy --attach --namespace=default -it --image=$image --restart=Never --rm=true --overrides=$json";
    Write-Host "`e[93mkubectl $ctlArgs`e[0m"
    & "kubectl" $ctlArgs.Split(' ')
}

function touch {
    param([string] $path)

    if ([string]::IsNullOrWhiteSpace($path)) {
        Write-Host "`e[93mEmpty path. NOP.`e[0m";
        return;
    }
    if (!$path.Contains(':')) {
        $path = $([System.IO.Path]::Combine($PWD, $path))
    }
    $(Get-Item $path).lastwritetime = $(Get-Date)
}
# diff catalog
function diff_dir([string] $path1, [string] $path2) {
    $env:COMPARE_FOLDERS = "DIFF";
    code $path1 $path2
    # $files1 = Get-ChildItem -Recurse -File -path $path1 ;
    # $files2 = Get-ChildItem -Recurse -File -path $path2 ;
    # Compare-Object -ReferenceObject $files1 -DifferenceObject $files2 ;
}

# This will add the command to history.
Set-PSReadLineKeyHandler -Key Ctrl+Shift+b `
    -BriefDescription BuildCurrentDirectory `
    -LongDescription "Build the current directory" `
    -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("dotnet build -nologo -maxCpuCount -nodeReuse:false -clp:ErrorsOnly -p:UseRazorBuildServer=false -p:UseSharedCompilation=false -p:EnableAnalyzer=false -p:EnableNETAnalyzers=false")
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

# runs build system command
function bs {
    # Use -p:UseRazorBuildServer=false to disable the Razor (rzc) server.
    # Use -p:UseSharedCompilation=false to disable the Roslyn (vbcscompiler) server.
    # Use /nodeReuse:false for MSBuild to disable node re-use.
    if ($args -eq $null -or $args.Length -eq 0) {
        dotnet build -nologo -maxCpuCount -nodeReuse:false -tl -clp:ErrorsOnly -p:UseRazorBuildServer=false -p:UseSharedCompilation=false -p:EnableAnalyzer=false -p:EnableNETAnalyzers=false
        return;
    }
    if ($args[0] -eq "restore") {
        dotnet restore -nologo -maxCpuCount -nodeReuse:false -tl -p:UseRazorBuildServer=false -p:UseSharedCompilation=false -p:EnableAnalyzer=false -p:EnableNETAnalyzers=false
        return;
    }
    [string] $path = "build";
    if ([System.IO.Directory]::Exists($([System.IO.Path]::Combine($PWD, "_build")))) {
        $path = "_build";
    }
    dotnet run --project $path -tl -- $args
}
# recursive removes bin/obj
function cleanBinObj() {
    (Get-ChildItem $PWD -include bin, obj -Recurse).fullname -inotmatch '\\node_modules\\' | ForEach-Object ($_) { remove-item $_ -Force -Recurse }
}

# creates lnk file, this is useful for paths > 260, which explorer can't create, for example (be careful about WoW64)
# for example for vivaldi
# createLnk "C:\Program Files\Vivaldi\Application\vivaldi.exe" -args "--disk-cache-size=4294967296 --cast-app-background-color=282a3600 --force-dark-mode --default-background-color=282a3600 --dark --process-per-site --disable-new-content-rendering-timeout --disable-extensions-file-access-check --disable-backgrounding-occluded-windows --remote-debugging-port=9223"
# new version:
# createLnk "C:\Program Files\Vivaldi\Application\vivaldi.exe" -args "--disk-cache-size=4294967296 --cast-app-background-color=282a3600 --force-dark-mode --default-background-color=282a3600 --dark --disable-extensions-file-access-check"
# createLnk "C:\Users\verysimplenick\AppData\Local\Microsoft\WindowsApps\wt.exe" "$PWD\wt_main.lnk" "q:\code\vchirikov\dotfiles\windows_terminal\terminal.ico" "-w main -d q:\code"
function createLnk {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True)]
        [string] $path,
        [Parameter(Mandatory = $False)]
        [string] $output = "",
        [Parameter(Mandatory = $False)]
        [string] $iconPath,
        [Parameter(Mandatory = $False)]
        [string] $args = ""
    )
    $path = [System.IO.Path]::GetFullPath($path);

    if ([string]::IsNullOrWhiteSpace($output)) {
        $output = $([System.IO.Path]::Combine($PWD, $([System.IO.Path]::GetFileNameWithoutExtension($path)) + ".lnk"));
    }
    $wsh = New-Object -ComObject WScript.Shell
    $lnk = $wsh.CreateShortcut($output);
    $lnk.TargetPath = $path;
    if (![string]::IsNullOrWhiteSpace($iconPath)) {
        $lnk.IconLocation = "$iconPath,0";
    }
    $lnk.Arguments = $args;
    $lnk.Save();
}


Set-Alias time Measure-Command
Set-Alias import Import-Module
Set-Alias -Name openssl -Value "C:\Program Files\Git\usr\bin\openssl.exe"


# Import-Module PSGitHub
# Import-Module DockerCompletion

function choco_print_backup {
    Write-Output "<?xml version=`"1.0`" encoding=`"utf-8`"?>"
    Write-Output "<packages>"
    choco list -lo -r -y | % { "   <package id=`"$($_.SubString(0, $_.IndexOf("|")))`" version=`"$($_.SubString($_.IndexOf("|") + 1))`" />" }
    Write-Output "</packages>"
}

Remove-Alias ls
[bool] $__shouldImportIcons = $True;
function ls {
    if ($__shouldImportIcons) {
        # very slow command so import this only if needed
        # https://github.com/devblackops/Terminal-Icons
        Import-Module Terminal-Icons
        $__shouldImportIcons = $False;
    }
    if ([string]::IsNullOrWhiteSpace($args)) {
        Get-ChildItem | Format-Wide -AutoSize
    }
    else {
        if ($args -eq "-la") {
            Get-ChildItem
        }
        else {
            Get-ChildItem $args
        }
    }
}

if ($env:TEMP) {
    $script:debuggingTabFile = "$env:TEMP\tabcompletion.json"
}
else {
    # Linux doesn't have TEMP
    $script:debuggingTabFile = New-TemporaryFile
}

function rndpass {
    param (
        [int] $length = 16,
        [int] $useExtra = 1
    )
    $charSet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789{]+-[*=@:)}$^%;(_!&amp;#?>/|.'.ToCharArray()
    if ($useExtra -eq 0) {
        $charSet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'.ToCharArray()
    }
    $rng = New-Object System.Security.Cryptography.RNGCryptoServiceProvider;
    $bytes = New-Object byte[]($length);
    $rng.GetBytes($bytes);
    $result = New-Object char[]($length);
    for ($i = 0 ; $i -lt $length ; $i++) {
        $result[$i] = $charSet[$bytes[$i] % $charSet.Length]
    }
    return (-join $result)
}

# choco install jq
function crd2jsonschema() {
    param(
        [ArgumentCompleter(
            {
                param($cmd, $param, $values)
                if ([string]::IsNullOrWhiteSpace($env:KUBECONFIG)) {
                    return;
                }
                & kubectl get crd --all-namespaces -o name |
                ForEach-Object { $_.Substring("customresourcedefinition.apiextensions.k8s.io/".Length) } |
                Sort-Object |
                ForEach-Object { $([System.Management.Automation.CompletionResult]::new($_)) }
            }
        )]
        [string] $crd,
        [int] $debug = 0
    )

    if ([string]::IsNullOrWhiteSpace($env:KUBECONFIG)) {
        Write-Host "`e[93mSpecify KUBECONFIG env variable`e[0m";
        return;
    }
    $crd = $crd.Replace("customresourcedefinition.apiextensions.k8s.io/", "");
    $json = $(kubectl get -o json customresourcedefinition.apiextensions.k8s.io/$crd)
    $query = @"
    {
    "`$schema": "http://json-schema.org/draft-07/schema",
    "x-kubernetes-group-version-kind.group": .spec.group,
    "x-kubernetes-group-version-kind.kind": .spec.names.kind,
    "x-kubernetes-group-version-kind.version": (.spec.versions[-1].name),
    title: .spec.names.kind,
    type: "object",
    properties: .spec.versions[-1].schema.openAPIV3Schema.properties,
    description: (.spec.versions[-1].schema.openAPIV3Schema.description // ""),
    required: (.spec.versions[-1].schema.openAPIV3Schema.required // [])
    }
"@;
    [string] $tempFile = [System.IO.Path]::GetTempFileName();
    try {
        if ($debug -eq 1) {
            Write-Host "Write query to $tempFile"
        }
        [System.IO.File]::WriteAllText($tempFile, $query);
        Write-Host "`e[93mWrite $crd.schema.json`e[0m";
        $json | jq -S -f $tempFile > "$crd.schema.json"
    }
    finally {
        if ([System.IO.File]::Exists($tempFile)) {
            if ($debug -eq 1) {
                Write-Host "Remove query file $tempFile"
            }
            Remove-Item -Path $tempFile
        }
    }
    if ($debug -eq 1) {
        Write-Host "`e[93mDone`e[0m";
    }
}

function kubeGenerateCrdJsonSchemas {
    [System.Text.StringBuilder] $sb = [System.Text.StringBuilder]::new();
    [void] $sb.AppendLine("{");
    [void] $sb.AppendLine("  ""`$schema"": ""http://json-schema.org/draft-07/schema"",");
    [void] $sb.AppendLine("  ""type"": ""object"",");
    [void] $sb.AppendLine("  ""oneOf"": [");
    kubectl get crd --all-namespaces -o name | ForEach-Object { $name = $_.Replace("customresourcedefinition.apiextensions.k8s.io/", "") ; [void]$sb.AppendLine("    {""`$ref"": ""$name.schema.json"" },"); crd2jsonschema $name 0 ; }
    [void]$sb.Remove($sb.Length - 3, 2);
    [void]$sb.AppendLine("  ]");
    [void]$sb.AppendLine("}");
    [void][System.IO.File]::WriteAllText("crd.json", $sb.ToString());
}

function readDotEnv {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([System.Object[]])]
    param(
        [Parameter(Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]
        $LiteralPath = (Join-Path -Path $PSScriptRoot -ChildPath '.env'),

        [Parameter()]
        [switch]
        $Force
    )

    $linecursor = 0

    if (Test-Path -LiteralPath $LiteralPath) {
        Get-Content -LiteralPath $LiteralPath `
        | ForEach-Object { # go through line by line
            $line = $_.trim() # trim whitespace
            if ($line -match "^\s*#") {
                # it's a comment
                Write-Verbose -Message "Found comment $line at line $linecursor. discarding"
            }
            elseif ($line -match "^\s*$") {
                # it's a blank line
                Write-Verbose -Message "Found a blank line at line $linecursor, discarding"
            }
            elseif ($line -match "^\s*(?<key>[^\n\b\a\f\v\r\s]+?)\s*=\s*(?<value>[^\n\b\a\f\v\r]*)$") {
                # it's not a comment, parse it
                # find the first '='
                $key = $Matches["key"]
                $value = $Matches["value"]

                Write-Verbose -Message "Found [$key] with value [$value]"

                # remove potential trailing comment
                if (-not [string]::IsNullOrWhiteSpace($value)) {
                    $idx = $value.IndexOf('#')
                    if (-1 -lt $idx) {
                        Write-Verbose -Message "`tRemoving trailing comment"
                        $value = $value.Substring(0, $idx - 1).trimEnd()
                    }
                    $quote = $value[0]
                    if ($quote -in "`"", "`'") {
                        Write-Verbose -Message "`tQuoted value found, trimming quotes"
                        $value = $value.trim($quote)
                        Write-Verbose -Message "`tValue is now [$value]"
                    }
                }

                if ($Force -or -not [System.Environment]::GetEnvironmentVariable($key, 'Process')) {
                    if ($PSCmdlet.ShouldProcess("Environment variable [$key]", "Set value [$value]")) {
                        [System.Environment]::SetEnvironmentVariable($key, $value, 'Process')
                    }
                }
                else {
                    Write-Verbose -Message "Environment variable $key already exists"
                }
            }
            else {
                Write-Warning "Invalid line $linecursor -> [$line]"
            }
            $linecursor++
        }
    }
    else {
        Write-Verbose "Dotenv file $LiteralPath not found."
    }
}

# read env variables
readDotEnv 'q:\code\vchirikov\dotfiles\secrets\.env'
# include jira-cli completion
. 'Q:\code\vchirikov\dotfiles\_jira.ps1'

function clearPwshHistory {
    # Read the content of the input file
    [string] $file = "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt";
    if (Test-Path $file) {
        $content = Get-Content -Path $file
        $filteredContent = $content | Where-Object {
            -not $_.StartsWith('cd ') -and
            -not $_.StartsWith('ls ') -and
            -not $_.StartsWith('rm ') -and
            -not $_.StartsWith('ncu ') -and
            -not $_.StartsWith('npm') -and
            -not $_.StartsWith('pnpm') -and
            -not $_.StartsWith('npx') -and
            -not $_.StartsWith('mkdir ') -and
            -not $_.StartsWith('pwd') -and
            -not $_.StartsWith('code ') -and
            -not $_.StartsWith('.') -and
            -not $_.StartsWith('Q:') -and
            -not $_.StartsWith('C:') -and
            -not $_.StartsWith('git') -and
            -not $_.StartsWith('ping') -and
            -not $_.StartsWith('tracert') -and
            -not $_.StartsWith('spindown') -and
            -not $_.StartsWith('rider')
        }
        $filteredContent | Set-Content -Path $file
    }

}

function compressVideoFile {
    $inputFile = $args[0]
    # 0..51 большее число хуже качество CRF (Constant Rate Factor — постоянный фактор качества) — это режим управления качеством в кодеках libx264 и
    # 23-24 оптималочка, при 24 битрейт около 48 мбит
    $crf = if ($args[1]) { $args[1] } else { 23 }
    $preset = if ($args[2]) { $args[2] } else { "medium" }

    if (-not $inputFile) {
        Write-Host "Ошибка: укажите путь к файлу" -ForegroundColor Red
        return
    }

    if (-not (Test-Path $inputFile)) {
        Write-Host "Файл не найден: $inputFile" -ForegroundColor Red
        return
    }

    $outputFile = $inputFile -replace '\.mp4$', '_compressed.mp4'

    Write-Host "Обработка файла: $inputFile" -ForegroundColor Cyan

    # Определение битности
    $probe = & ffprobe -v quiet -select_streams v:0 -show_entries stream=pix_fmt -of csv=p=0 "$inputFile"
    $is10bit = $probe -match "p10le"

    Write-Host "Битность: $(if($is10bit){'10-bit'} else {'8-bit'})" -ForegroundColor Gray

    # Параметры видео
    $videoParams = @("-c:v", "libx265", "-crf", $crf, "-preset", $preset)

    if ($is10bit) {
        $videoParams += @("-profile:v", "main10", "-pix_fmt", "yuv420p10le")
    }

    Write-Host "Сжатие (CRF=$crf, preset=$preset)..." -ForegroundColor Yellow

    & ffmpeg -i "$inputFile" $videoParams -c:a aac -b:a 128k -movflags +faststart -y "$outputFile"

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Успешно: $outputFile" -ForegroundColor Green
    }
    else {
        Write-Host "✗ Ошибка при обработке" -ForegroundColor Red
    }
}

function compressVideosInDirectory {
    $directoryPath = $args[0]
    $crf = if ($args[1]) { $args[1] } else { 23 }
    $preset = if ($args[2]) { $args[2] } else { "medium" }

    if (-not $directoryPath) {
        Write-Host "Ошибка: укажите путь к каталогу" -ForegroundColor Red
        return
    }

    if (-not (Test-Path $directoryPath -PathType Container)) {
        Write-Host "Каталог не найден: $directoryPath" -ForegroundColor Red
        return
    }

    $videoFiles = Get-ChildItem -Path $directoryPath -Recurse -Filter "*.mp4" |
    Where-Object { $_.Name -notlike "*_compressed*" }

    if ($videoFiles.Count -eq 0) {
        Write-Host "MP4-файлы не найдены в каталоге $directoryPath" -ForegroundColor Yellow
        return
    }

    Write-Host "Найдено файлов для обработки: $($videoFiles.Count)" -ForegroundColor Cyan

    foreach ($file in $videoFiles) {
        compressVideoFile $file.FullName $crf $preset
        Write-Host ""   # разделитель
    }

    Write-Host "Обработка каталога завершена." -ForegroundColor Green
}

function jira {
    if ($args[0] -eq "q" -and $args.Length -ge 1) {
        & jira.exe issue list --plain --columns "key,summary,priority,created,status" -q "summary ~ $($args[1])" $($args | Select-Object -Skip 2)
        return;
    }
    # default:
    if ($args -eq $null -or $args.Length -eq 0 -or $args[0] -eq "q" -or $args[0] -eq "my" -or ($args[0] -eq "ls" -and $args.Length -eq 1)) {
        & jira.exe issue list --plain --columns "key,summary,priority,created,status" -q "project = TM AND (component = infra OR assignee = currentUser()) AND status not in (closed, done)"
        return;
    }
    if ($args[0] -eq "h" -or $args[0] -eq "history" -or $args[0] -eq "lg") {
        & jira.exe issue list --plain --columns "key,summary,created,updated,reporter,status" --updated (($args.Length -eq 2) ? ("$($args[1])") : ("-14days")) --order-by updated -q "project = TM AND (component = infra OR assignee = currentUser()) AND status in (closed, done)" $($args | Select-Object -Skip 2)
        return;
    }
    if (($args[0] -eq "s" -or $args[0] -eq "show" -or $args[0] -eq "cat") -and $args.Length -ge 2) {
        & jira.exe issue view --plain ($args[1].ToString().StartsWith("TM", [StringComparison]::OrdinalIgnoreCase) ? ($args[1].ToString()) : ("TM-$($args[1])")) --comments 9999  $($args | Select-Object -Skip 2)
        return;
    }
    if ($args[0] -eq "link") {
        & jira.exe issue link $($args | Select-Object -Skip 1)
        return;
    }
    if ($args[0] -eq "c" -or $args[0] -eq "create" -and $args.Length -eq 1) {
        & jira.exe issue create --web
        return;
    }
    if ($args[0] -eq "c" -or $args[0] -eq "create") {
        & jira.exe issue create $($args | Select-Object -Skip 1)
        return;
    }
    if ($args[0] -eq "cb" -or $args[0] -eq "bug") {
        & jira.exe issue create -tBug --component infra --custom task-size=M $($args | Select-Object -Skip 1)
        return;
    }
    if ($args[0] -eq "ct" -or $args[0] -eq "task") {
        & jira.exe issue create -tTask --component infra --custom task-size=XS --summary $($args | Select-Object -Skip 1)
        return;
    }
    if ($args[0] -eq "cs" -or $args[0] -eq "story") {
        & jira.exe issue create -tStory --component infra --custom task-size=M $($args | Select-Object -Skip 1)
        return;
    }
    if (($args[0] -eq "mv" -or $args[0] -eq "move") -and $args.Length -ge 2) {
        & jira.exe issue move ($args[1].ToString().StartsWith("TM", [StringComparison]::OrdinalIgnoreCase) ? ($args[1].ToString()) : ("TM-$($args[1])")) $($args | Select-Object -Skip 2)
        return;
    }
    if (($args[0] -eq "go") -and $args.Length -eq 2) {
        [string ]$task = $args[1].ToString();
        try { jira backlog "$task" } catch {}
        try { jira select "$task" } catch {}
        try { jira start "$task" } catch {}
        return;
    }

    [string] $state = $null
    switch ($args[0]) {
        'draft' { $state = "To Draft"; break }
        'backlog' { $state = "To Backlog"; break }
        'select' { $state = "Ready To Develop"; break }
        'get' { $state = "Start Work"; break }
        'start' { $state = "Start Work"; break }
        'done' { $state = "Done"; break }
        'close' { $state = "Close"; break }
        default { $state = $null }
    }
    if ($null -ne $state -and $args.Length -eq 2) {
        & jira.exe issue move ($args[1].ToString().StartsWith("TM", [StringComparison]::OrdinalIgnoreCase) ? ($args[1].ToString()) : ("TM-$($args[1])")) $state
        return;
    }
    & jira.exe $args
}

<#
Helper function used to log parameters for tab completion scriptblock

function Write-TabCompletionLog {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    [System.IO.File]::AppendAllText($script:debuggingTabFile, `
            "// === User pressed tab ===`n$(ConvertTo-Json @{commandName=$commandName;parameterName=$parameterName;wordToComplete=$wordToComplete;fakeBoundParameter=$fakeBoundParameter}),`n")
    if ($commandAst) {
        [System.IO.File]::AppendAllText($script:debuggingTabFile, "$(ConvertTo-Json $commandAst -Depth 1),`n") # > 1 breaks tab completion due to error
        if ($commandAst.CommandElements -and $commandAst.CommandElements) {
            [System.IO.File]::AppendAllText($script:debuggingTabFile, "`"Extents`":`n[`n")
            foreach ( $c in $commandAst.CommandElements) {
                if (Get-Member -InputObject $c -Name Extent) {
                    [System.IO.File]::AppendAllText($script:debuggingTabFile, "$(ConvertTo-Json $c.Extent.toString() -Depth 1)`n")
                }
            }
            [System.IO.File]::AppendAllText($script:debuggingTabFile, "]`n")
        }
    }
}

function Get-TabCompletionLogFile {
    [CmdletBinding()]
    param()
    Set-StrictMode -Version Latest

    return $script:debuggingTabFile



}


function TabExpansion2 {
    [CmdletBinding(DefaultParameterSetName = 'ScriptInputSet')]
    Param(
        [Parameter(ParameterSetName = 'ScriptInputSet', Mandatory = $true, Position = 0)]
        [string] $inputScript,

        [Parameter(ParameterSetName = 'ScriptInputSet', Position = 1)]
        [int] $cursorColumn = $inputScript.Length,

        [Parameter(ParameterSetName = 'AstInputSet', Mandatory = $true, Position = 0)]
        [System.Management.Automation.Language.Ast] $ast,

        [Parameter(ParameterSetName = 'AstInputSet', Mandatory = $true, Position = 1)]
        [System.Management.Automation.Language.Token[]] $tokens,

        [Parameter(ParameterSetName = 'AstInputSet', Mandatory = $true, Position = 2)]
        [System.Management.Automation.Language.IScriptPosition] $positionOfCursor,

        [Parameter(ParameterSetName = 'ScriptInputSet', Position = 2)]
        [Parameter(ParameterSetName = 'AstInputSet', Position = 3)]
        [Hashtable] $options = $null
    )

    End {
        [System.Management.Automation.CommandCompletion] $result = $null;
        if ($psCmdlet.ParameterSetName -eq 'ScriptInputSet') {
            $result = [System.Management.Automation.CommandCompletion]::CompleteInput(
                $inputScript,
                $cursorColumn,
                $options)
        }
        else {
            $result = [System.Management.Automation.CommandCompletion]::CompleteInput(
                $ast,
                $tokens,
                $positionOfCursor,
                $options)
        }
        return $result;
    }
}
#>
#}

# DO NOT MODIFY -- coreutils -- 60b36fc6-2d59-49df-be51-28dd2f4c3c9a
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
# Inlining the template into the profile shaves off ~10ms (25%).
$script:__COREUTILS__ = [System.Collections.Generic.HashSet[string]]::new(
    [string[]]@(
        'arch', 'b2sum', 'base32', 'base64', 'basename',
        'basenc', 'cat', 'cksum', 'comm', 'cp',
        'csplit', 'cut', 'date', 'df', 'dirname',
        'du', 'echo', 'env', 'expr', 'factor',
        'false', 'find', 'fmt', 'fold', 'grep',
        'head', 'hostname', 'join', 'la', 'link',
        'ln', 'ls', 'md5sum', 'mkdir', 'mktemp',
        'mv', 'nl', 'nproc', 'numfmt', 'od',
        'pathchk', 'pr', 'printenv', 'printf', 'ptx',
        'pwd', 'readlink', 'realpath', 'rm', 'rmdir',
        'seq', 'sha1sum', 'sha224sum', 'sha256sum', 'sha384sum',
        'sha512sum', 'shuf', 'sleep', 'sort', 'split',
        'stat', 'sum', 'tac', 'tail', 'tee',
        'test', 'touch', 'tr', 'true', 'truncate',
        'tsort', 'unexpand', 'uniq', 'unlink', 'uptime',
        'wc', 'xargs', 'yes'
    ),
    [System.StringComparer]::OrdinalIgnoreCase
)

$script:__COREUTILS_FAST_SKIP__ = [regex]::new(
    '\b(?:' + ($script:__COREUTILS__ -join '|') + ')\b',
    [System.Text.RegularExpressions.RegexOptions]::Compiled -bor `
        [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
)

# Casting the scriptblock to Func<Ast,bool> once and reusing it avoids the
# per-FindAll scriptblock-to-delegate wrapping overhead (~1.7x faster).
$script:__COREUTILS_CMD_PREDICATE__ = [System.Func[System.Management.Automation.Language.Ast, bool]] {
    param($n) $n -is [System.Management.Automation.Language.CommandAst]
}

$script:__COREUTILS_ARG_SPECIAL__ = [char[]] @("'", '"', '`', '$')

# Wrap arguments into quotes. By being a function we can properly handle $variables.
# As per MSVCRT, any `\` before `"` must be doubled to escape them.
function global:__coreutils_q {
    param($s)
    '"' + (([string]$s) -replace '(\\*)"', '$1$1\"' -replace '(\\+)$', '$1$1') + '"'
}

# PowerShell tokenizes `*"a"*` as [BareWord] instead of the expected [DoubleQuoted, BareWord, DoubleQuoted].
# To work around that we use... regex. Group 1 = 'single', 2 = "double", 3 = `escape, 4 = bare run.
$script:__COREUTILS_ARG_RX__ = [regex]::new(
    "'((?:[^']|'')*)'|""((?:[^""``]|""""|``.)*)""|``(.)|([^'""``]+)",
    [System.Text.RegularExpressions.RegexOptions]::Compiled
)
$script:__COREUTILS_ARG_EVAL__ = [System.Text.RegularExpressions.MatchEvaluator] {
    param($m)
    if ($m.Groups[1].Success) {
        # Single-quoted: literal. PS '' -> ', then MSVCRT-quote.
        $body = $m.Groups[1].Value.Replace("''", "'")
        if ($body -match '^(.*?)(\\+)$') {
            return '"' + ($matches[1] -replace '(\\*)"', '$1$1\"') + '"' + $matches[2]
        }
        return '"' + ($body -replace '(\\*)"', '$1$1\"') + '"'
    }
    if ($m.Groups[2].Success) {
        # Double-quoted: collapse PS quote-escapes to raw " / ', let ExpandString
        # resolve `n / `t / $var, then MSVCRT-quote.
        $body = $m.Groups[2].Value.
        Replace('`"', '"').
        Replace("``'", "'").
        Replace('""', '"')
        $body = $ExecutionContext.InvokeCommand.ExpandString($body)
        if ($body -match '^(.*?)(\\+)$') {
            return '"' + ($matches[1] -replace '(\\*)"', '$1$1\"') + '"' + $matches[2]
        }
        return '"' + ($body -replace '(\\*)"', '$1$1\"') + '"'
    }
    if ($m.Groups[3].Success) {
        # Backtick-escaped char outside a string: " -> \"; everything else
        # becomes a one-char quoted region so glob metas stay literal.
        $c = $m.Groups[3].Value
        if ($c -eq '"') {
            return '\"'
        }
        return '"' + $c + '"'
    }
    # Bare run: passed through unquoted so coreutils can glob it; expand $vars.
    return $ExecutionContext.InvokeCommand.ExpandString($m.Groups[4].Value)
}

# PSConsoleHostReadLine override that rewrites coreutils command names to their
# .cmd equivalents after PSReadLine returns (history keeps the original).
#
# Why .cmd over .exe: PSNativeCommandArgumentPassing = 'Windows' results in a behavior
# where passing bare quotes to CreateProcess() is impossible. This prevents us from
# passing "*" as "*" to coreutils and instead will be given as a bare *.
# This causes it to treat it as a glob pattern. "*.cmd" files however are automatically
# treated as PSNativeCommandArgumentPassing = 'Legacy', which preserves quotes.
# It is the only possible workaround and the only way coreutils can work at all.
function PSConsoleHostReadLine {
    [System.Diagnostics.DebuggerHidden()]
    param()

    $lastRunStatus = $?
    Microsoft.PowerShell.Core\Set-StrictMode -Off
    $line = [Microsoft.PowerShell.PSConsoleReadLine]::ReadLine($host.Runspace, $ExecutionContext, $lastRunStatus)

    # If the line contains no coreutils name, we don't need to parse the AST at all.
    if (-not $script:__COREUTILS_FAST_SKIP__.IsMatch($line)) {
        return $line
    }

    $ast = [System.Management.Automation.Language.Parser]::ParseInput($line, [ref]$null, [ref]$null)
    $commands = $ast.FindAll($script:__COREUTILS_CMD_PREDICATE__, $true)

    # Process right-to-left so earlier offsets stay valid after each splice.
    # In-place reverse beats Sort-Object for the typical 1-command line.
    if ($commands.Count -gt 1) {
        $commands = [System.Collections.Generic.List[object]]::new($commands)
        $commands.Reverse()
    }

    foreach ($cmd in $commands) {
        $name = $cmd.GetCommandName()
        if (!$name) {
            continue
        }

        $baseName = $name
        if ($name.EndsWith('.exe') -or $name.EndsWith('.cmd')) {
            $baseName = $name.Substring(0, $name.Length - 4)
        }
        if (!$script:__COREUTILS__.Contains($baseName)) {
            continue
        }

        # ls/la get colour + listing flags injected; la also rewrites to ls.
        $cmdElement = $cmd.CommandElements[0]
        $start = $cmdElement.Extent.StartOffset
        $end = $cmdElement.Extent.EndOffset
        $replacement = "& 'C:\Program Files\coreutils\cmd\"

        switch ($baseName) {
            'la' { $replacement += "ls.cmd' --color=auto -AFhl" }
            'ls' { $replacement += "ls.cmd' --color=auto" }
            default { $replacement += "$baseName.cmd'" }
        }

        # Walk command elements, merging adjacent ones whose extents touch
        # (e.g. `'a'*` parses as [SingleQuoted, BareWord] but is one shell word).
        # The inverse case `*'a'*` parses as a single BareWord whose text
        # contains the embedded quotes, which is why AST-only analysis
        # isn't enough and we still need to re-tokenize the source span.
        $argsStart = $end
        $argsEnd = $cmd.Extent.EndOffset
        $rewrittenArgs = ''
        $elements = $cmd.CommandElements
        $count = $elements.Count
        $i = 1
        while ($i -lt $count) {
            $first = $elements[$i]
            $wordStart = $first.Extent.StartOffset
            $wordEnd = $first.Extent.EndOffset
            $merged = $false
            while ($i + 1 -lt $count -and $elements[$i + 1].Extent.StartOffset -eq $wordEnd) {
                $i++
                $wordEnd = $elements[$i].Extent.EndOffset
                $merged = $true
            }
            $source = $line.Substring($wordStart, $wordEnd - $wordStart)
            $rewrittenArgs += $line.Substring($argsStart, $wordStart - $argsStart)
            $argsStart = $wordEnd
            # IndexOfAny beats running the regex per arg.
            if ($source.IndexOfAny($script:__COREUTILS_ARG_SPECIAL__) -lt 0) {
                $rewrittenArgs += $source
                $i++
                continue
            }
            # A single un-merged PS expression that needs $var resolution
            # (bare $var, "...$var...", $x.Member, $($expr), etc.).
            # Defer evaluation to runtime so the value reaches coreutils as a literal arg.
            # This matches POSIX behaviour where variable expansions don't result in globbing.
            if (-not $merged -and
                ($first -is [System.Management.Automation.Language.VariableExpressionAst] -or
                $first -is [System.Management.Automation.Language.ExpandableStringExpressionAst] -or
                $first -is [System.Management.Automation.Language.MemberExpressionAst])) {
                $rewrittenArgs += '(__coreutils_q ' + $source + ')'
                $i++
                continue
            }
            # Slow path: re-tokenise and re-emit as MSVCRT-style quoting,
            # then wrap in PS single quotes so PS hands the body verbatim.
            $windowsQuoted = $script:__COREUTILS_ARG_RX__.Replace($source, $script:__COREUTILS_ARG_EVAL__)
            $rewrittenArgs += "'" + $windowsQuoted.Replace("'", "''") + "'"
            $i++
        }
        $rewrittenArgs += $line.Substring($argsStart, $argsEnd - $argsStart)

        $line = $line.Substring(0, $start) + $replacement + $rewrittenArgs + $line.Substring($argsEnd)
    }

    return $line
}
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# DO NOT MODIFY -- coreutils -- 60b36fc6-2d59-49df-be51-28dd2f4c3c9a
