Import-Module PSReadLine
# zsh-like menu complete, for bash-like use `Complete`
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadlineOption -ShowToolTips
Set-PSReadlineOption -BellStyle None
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

Import-Module posh-git

# FZF bindings for powershell, should be imported after PSReadLine - https://github.com/kelleyma49/PSFzf
# Install-Module -Name PSFzf 
# also choco install fzf fd
Remove-PSReadlineKeyHandler 'Ctrl+r'
Remove-PSReadlineKeyHandler 'Ctrl+t'

$env:FZF_DEFAULT_COMMAND = 'fd --color=always --type file --follow --hidden --exclude .git'
$env:FZF_DEFAULT_OPTS = "--color=dark,gutter:#22262e,bg+:#303b4d --height 40% --layout=reverse";
$env:FZF__OPTS = "--color=dark,gutter:#22262e,bg+:#303b4d --height 40% --layout=reverse";

# https://github.com/nickcox/cd-extras
$cde = @{
    AUTO_CD  = $false
    CD_PATH  = 'C:\\code\\servicetitan', 'C:\\code\\vchirikov'
    NOARG_CD = 'C:\\code'
}
Import-Module cd-extras
Import-Module PSFzf
# Fzf tab completion
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
Set-PsFzfOption -EnableFd -TabExpansion -GitKeyBindings -EnableAliasFuzzyEdit -EnableAliasFuzzyHistory -EnableAliasFuzzyKillProcess -EnableAliasFuzzySetLocation -EnableAliasFuzzySetEverything

Set-Alias fzf Invoke-Fzf
# https://github.com/chawyehsu/base16-concfg colors
$GitPromptSettings.DefaultPromptPath.ForegroundColor = 0x61F053 ;
$GitPromptSettings.DefaultPromptBeforeSuffix.Text = ''
$GitPromptSettings.DefaultPromptSuffix.Text = ''
$GitPromptSettings.DefaultPromptEnableTiming = $false;
$GitPromptSettings.DefaultPromptTimingFormat = "`e[93m[{0}ms]`e[0m";

# disable posh-git title logic
$GitPromptSettings.WindowTitle = $null;

function prompt {
    # add posh-git default prompt
    $prompt = ""
    $command = Get-History -Count 1
    $prompt += & $GitPromptScriptBlock
    if ($command) {
        [TimeSpan] $span = $command.EndExecutionTime - $command.StartExecutionTime;
        $prompt += "`e[93m 祥 ";
        $format = "N2";
        $prompt += $($span.TotalMilliseconds -lt 1000 ? $span.TotalMilliseconds.ToString($format, [System.Globalization.CultureInfo]::InvariantCulture) + "ms"
            : ($span.TotalSeconds -lt 60 ? $span.TotalSeconds.ToString($format, [System.Globalization.CultureInfo]::InvariantCulture) + "s"
                : ($span.TotalMinutes -lt 60 ? $span.TotalMinutes.ToString($format, [System.Globalization.CultureInfo]::InvariantCulture) + "m"
                    : ($span.TotalHours -lt 24 ? $span.TotalHours.ToString($format, [System.Globalization.CultureInfo]::InvariantCulture) + "h"
                        : $span.TotalDays.ToString($format, [System.Globalization.CultureInfo]::InvariantCulture) + "d")))).ToString();
        $prompt += "`e[0m";
    }
    $prompt += "`e[31m>`e[0m"
    $host.ui.RawUI.WindowTitle = Get-Location | Split-Path -leaf
    "$prompt "
}

# https://github.com/Canop/broot
function mouse_on{
    $unixCmd = 'printf "\x1B[?1003h\x1B[?1006h"';
    wsl $unixCmd.Split(' ')
}

function mouse_off{
    $unixCmd = 'printf "\e[?1000l"';
    wsl $unixCmd.Split(' ')
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
    } finally {
        mouse_off;
        Remove-Item -force $tempFile
    }
}

# dotnet tool install --global dotnet-suggest --version 1.1.142701
# dotnet suggest shell start
$availableToComplete = (dotnet-suggest list) | Out-String
$availableToCompleteArray = $availableToComplete.Split([Environment]::NewLine, [System.StringSplitOptions]::RemoveEmptyEntries) 
Register-ArgumentCompleter -Native -CommandName $availableToCompleteArray -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
    $fullpath = (Get-Command $wordToComplete.CommandElements[0]).Source

    $arguments = $wordToComplete.Extent.ToString().Replace('"', '\"')
    dotnet-suggest get -e $fullpath --position $cursorPosition -- "$arguments" | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
$env:DOTNET_SUGGEST_SCRIPT_VERSION = "1.0.0"
# dotnet suggest script end

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
        smartctl --scan-open | Where-Object { $_.Contains("ATA device") } | ForEach-Object { $_.Split()[0] } | ForEach-Object { Write-Host "`e[93msmartctl -s standby,now $($_)`e[0m"; smartctl -s standby,now $($_) }
    }
    else {
        Write-Host "`e[93msmartctl -s standby,now $($device)`e[0m";
        smartctl -s standby,now $device 
    }
}

# run visual studio
function vs {
    param(
        [ArgumentCompleter(
            {
                param($cmd, $param, $values)
                Get-ChildItem -Path $([System.IO.Path]::GetFullPath($PWD)) -Filter "*.sln" |
                Where-Object { $_.Name.StartsWith($values, [StringComparison]::OrdinalIgnoreCase) } |
                ForEach-Object { $([System.IO.Path]::GetFileName($_)) } | 
                Sort-Object |
                ForEach-Object { $([System.Management.Automation.CompletionResult]::new($_)) }
            }
        )]
        [string] $path)
        
    [string] $vsPath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Preview\Common7\IDE\devenv.exe"
    if ([string]::IsNullOrWhiteSpace($path)) {
        $path = Get-ChildItem -Path $([System.IO.Path]::GetFullPath($PWD)) -Filter "*.sln" | Select-Object -First 1;
    }
    else {
        if (!$path.Contains(':')) {
            $path = $([System.IO.Path]::Combine($PWD, $path))
        }
    }
    Start-Process -FilePath $vsPath -ArgumentList $([System.IO.Path]::GetFullPath($path))
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
        dotnet build -nologo -maxCpuCount -nodeReuse:false -clp:ErrorsOnly -p:UseRazorBuildServer=false -p:UseSharedCompilation=false -p:EnableAnalyzer=false -p:EnableNETAnalyzers=false
        return;
    }
    if($args[0] -eq "restore"){
        dotnet restore -nologo -maxCpuCount -nodeReuse:false -p:UseRazorBuildServer=false -p:UseSharedCompilation=false -p:EnableAnalyzer=false -p:EnableNETAnalyzers=false 
        return;
    }
    [string] $path = "build";
    if ([System.IO.Directory]::Exists($([System.IO.Path]::Combine($PWD, "_build")))) {
        $path = "_build";
    }
    dotnet run --project $path -- $args
}
# recursive removes bin/obj 
function cleanBinObj() {
    Get-ChildItem $PWD -include bin, obj -Recurse | ForEach-Object ($_) { remove-item $_.fullname -Force -Recurse }
}

# creates lnk file, this is useful for paths > 260, which explorer can't create, for example (be careful about WoW64)
# for example for vivaldi
# createLnk "C:\Program Files\Vivaldi\Application\vivaldi.exe" -args "--disk-cache-size=4294967296 --cast-app-background-color=282a3600 --force-dark-mode --default-background-color=282a3600 --dark --process-per-site --disable-new-content-rendering-timeout --disable-extensions-file-access-check --disable-backgrounding-occluded-windows --remote-debugging-port=9222"
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


# Import-Module PSGitHub
# Import-Module DockerCompletion

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
