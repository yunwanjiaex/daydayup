# 转换哔哩哔哩视频缓存
### 手机端
```powershell
param($directory = $PSScriptRoot)
function ffmpeg { & "C:\Program Files\ffmpeg\bin\ffmpeg.exe" $args }

Get-ChildItem -Path $directory -Recurse -Include video.m4s | ForEach-Object {
    $d = $_.DirectoryName
    $title = Get-Content -Path "$d\..\entry.json" -Encoding UTF8 | ConvertFrom-Json
    $title = ($title.title + "_" + $title.page_data.page + "_" + $title.page_data.part ) -Replace "[$([RegEx]::Escape([string][IO.Path]::GetInvalidFileNameChars()))]", "_"
    ffmpeg -i "$d\video.m4s" -i "$d\audio.m4s" -c copy "$title.mp4"
}
```
* 视频缓存在手机中的位置 `/sdcard/Android/data/tv.danmaku.bili/download`
* 缓存中的 `danmaku.xml` 为弹幕文件,有需要的可以用 [danmakuC](https://github.com/HFrost0/danmakuC) 转换为字幕
* 修改 [ffmpeg](https://github.com/BtbN/FFmpeg-Builds/releases) 为自己的安装目录,将缓存传到电脑里,和脚本同目录,右键运行即可
### PC端
```powershell
param($directory = $PSScriptRoot)
function ffmpeg { & "C:\Program Files\ffmpeg\bin\ffmpeg.exe" $args }

Get-ChildItem -Path $directory -Recurse -Include videoInfo.json | ForEach-Object {
    $d = $_.DirectoryName
    $title = Get-Content -Path "$d\videoInfo.json" -Encoding UTF8 | ConvertFrom-Json
    $title = ($title.groupTitle + "_" + $title.p + "_" + $title.title ) -Replace "[$([RegEx]::Escape([string][IO.Path]::GetInvalidFileNameChars()))]", "_"

    $files = Get-ChildItem -Path $d -Filter *.m4s | ForEach-Object { $_.FullName }
    foreach ($f in $files) {
        # 去除文件中的前9个0
        $b = [System.IO.File]::ReadAllBytes($f)
        $null, $null, $null, $null, $null, $null, $null, $null, $null, $b = $b
        [System.IO.File]::WriteAllBytes($f, $b)
    }
    ffmpeg -i $files[0] -i $files[1] -c copy "$title.mp4"
}
```
### 切割分p视频然后合并
```powershell
param($directory = $PSScriptRoot)
function ffmpeg { & "C:\Program Files\ffmpeg\bin\ffmpeg.exe" $args }

# 取每段视频的前 8 分钟
$len = 480
Get-ChildItem -Filter *.mp4 | Sort-Object { # 确保顺序正常
    [regex]::Replace($_.Name, '\d+', { $args[0].Value.PadLeft(20) })
} | Select-Object -ExpandProperty Name | ForEach-Object -Begin { $c = 0 } -Process {
    $c++ # PowerShell v5 处理 utf-8 会有一些问题,此处用自增数字代替
    ffmpeg -y -ss 00:00:00 -i "$_" -t $len -c copy tmp_$c.mp4
    Add-Content -Value "file 'tmp_$c.mp4'" -Path tmp_1.txt
}
 
ffmpeg -f concat -i tmp_1.txt -c copy output.mp4
Remove-Item -Force -Path tmp_*
```