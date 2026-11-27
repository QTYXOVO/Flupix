#requires -Version 5.1
<#
.SYNOPSIS
    从 pub.dev 同步 ffmpeg_kit_flutter_new_audio 的上游源码到 third_party/。

.DESCRIPTION
    本仓库只保留该插件的 Android 实现（Windows 端改用系统 ffmpeg），因此需要
    从上游发布包里删除 ios / macos / windows / linux 等平台目录，并把
    pubspec.yaml 的 plugin.platforms 收窄为 android。

    升级示例：
        pwsh tool/sync_ffmpeg_kit.ps1 -Version 2.5.9
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, HelpMessage = '要同步的上游版本号，例如 2.5.8')]
    [string]$Version,

    [string]$Destination = (Join-Path $PSScriptRoot '..\third_party\ffmpeg_kit_flutter_new_audio')
)

$ErrorActionPreference = 'Stop'

$package = 'ffmpeg_kit_flutter_new_audio'
$staging = Join-Path ([System.IO.Path]::GetTempPath()) "flupix-$package-$Version"

if (Test-Path $staging) { Remove-Item $staging -Recurse -Force }
New-Item -ItemType Directory -Path $staging | Out-Null
New-Item -ItemType Directory -Path $Destination -Force | Out-Null

$archive = Join-Path $staging 'package.tar.gz'
Write-Host "下载 https://pub.dev/api/archives/$package-$Version.tar.gz"
Invoke-WebRequest "https://pub.dev/api/archives/$package-$Version.tar.gz" -OutFile $archive
tar -xzf $archive -C $staging
Remove-Item $archive

# 只保留 Android 实现；其余平台目录与上游开发辅助内容一并丢弃。
$removed = @('ios', 'macos', 'windows', 'linux', 'example', 'test', 'scripts', 'analysis_options.yaml')
foreach ($item in $removed) {
    Remove-Item (Join-Path $staging $item) -Recurse -Force -ErrorAction SilentlyContinue
}

# 替换目标目录里属于上游的内容，但保留本仓库自己的 UPSTREAM.md。
$synced = @('lib', 'android', 'CHANGELOG.md', 'LICENSE', 'README.md', 'pubspec.yaml')
foreach ($item in $synced) {
    Remove-Item (Join-Path $Destination $item) -Recurse -Force -ErrorAction SilentlyContinue
    Copy-Item (Join-Path $staging $item) -Destination $Destination -Recurse -Force
}

# 收窄 plugin.platforms 为 Android，并标注本地化修改。
$pubspecPath = Join-Path $Destination 'pubspec.yaml'
$pubspec = Get-Content $pubspecPath -Raw
$pubspec = $pubspec -replace '(?m)^description:.*$', 'description: FFmpeg Kit Audio for Flutter (vendored, Android only).'

$androidOnlyPlugin = @(
    'flutter:',
    '  plugin:',
    '    platforms:',
    '      android:',
    '        package: com.antonkarpenko.ffmpegkit',
    '        pluginClass: FFmpegKitFlutterPlugin',
    '',
    ''
) -join "`n"

$pubspec = $pubspec -replace '(?ms)^flutter:.*?(?=^dependencies:)', $androidOnlyPlugin

if ($pubspec -notmatch '(?m)^      android:\n        package: com\.antonkarpenko\.ffmpegkit') {
    throw '上游 pubspec.yaml 结构已变化，请手动检查 plugin.platforms 后再同步。'
}

Set-Content -Path $pubspecPath -Value $pubspec -NoNewline

Remove-Item $staging -Recurse -Force
Write-Host "已同步 $package $Version -> $Destination"
Write-Host '请检查 git diff，并运行 flutter pub get 与 flutter build apk --debug 验证。'
