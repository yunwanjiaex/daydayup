# 更新 Github 的 hosts
# https://gitlab.com/ineo6/hosts/-/raw/master/next-hosts
# https://raw.hellogithub.com/hosts

$h = "C:\Windows\System32\drivers\etc\hosts"
if (Test-Path -PathType Leaf -Path "$h.ori") {
    Copy-Item -Force -Path "$h.ori" -Destination $h
}
else {
    Copy-Item -Force -Path $h -Destination "$h.ori"
} 
$urls = @(
    "github.io",
    "github.com",
    "api.github.com",
    "raw.github.com",
    "gist.github.com",
    "live.github.com",
    "alive.github.com",
    "githubstatus.com",
    "github.community",
    "central.github.com",
    "codeload.github.com",
    "collector.github.com",
    "education.github.com",
    "assets-cdn.github.com",
    "github.map.fastly.net",
    "github.githubassets.com",
    "raw.githubusercontent.com",
    "camo.githubusercontent.com",
    "media.githubusercontent.com",
    "cloud.githubusercontent.com",
    "github-com.s3.amazonaws.com",
    "github.global.ssl.fastly.net",
    "github-cloud.s3.amazonaws.com",
    "desktop.githubusercontent.com",
    "objects.githubusercontent.com",
    "avatars.githubusercontent.com",
    "avatars0.githubusercontent.com",
    "avatars1.githubusercontent.com",
    "avatars2.githubusercontent.com",
    "avatars3.githubusercontent.com",
    "avatars4.githubusercontent.com",
    "avatars5.githubusercontent.com",
    "favicons.githubusercontent.com",
    "user-images.githubusercontent.com",
    "copilot-proxy.githubusercontent.com",
    "pipelines.actions.githubusercontent.com",
    "private-user-images.githubusercontent.com",
    "github-production-user-asset-6210df.s3.amazonaws.com",
    "github-production-release-asset-2e65be.s3.amazonaws.com",
    "github-production-repository-file-5c1aeb.s3.amazonaws.com"
)

foreach ($u in $urls) {
    # https://www.ipaddress.com/website/github.com
    $t = Invoke-WebRequest -UseBasicParsing -Uri https://www.ipaddress.com/website/$u -UserAgent 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36'
    $t = $t.Content | Select-String -Pattern 'ipv4/(\d+\.\d+\.\d+\.\d+)">\1</a></dd>' | Select-Object -Expand Matches | Select-Object -ExpandProperty Value
    $t = $t | Select-String -Pattern '\d+\.\d+\.\d+\.\d+' | Select-Object -Expand Matches | Select-Object -ExpandProperty Value
    if ($t) { Add-Content -Path $h -Value "$t`t`t$u" }
    Start-Sleep -Seconds 3
}

ipconfig /flushdns