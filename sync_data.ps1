# sync_data.ps1 — Rebuild khampha card grid + bando data array from restaurants.json
$ErrorActionPreference = 'Stop'
$bom  = New-Object System.Text.UTF8Encoding($true)
$base = $PSScriptRoot

# ── Load JSON ────────────────────────────────────────────────
Add-Type -AssemblyName System.Web
$raw  = [System.IO.File]::ReadAllText("$base\restaurants.json", [System.Text.Encoding]::UTF8)
$data = $raw | ConvertFrom-Json
Write-Host "Loaded $($data.Count) restaurants"

# ── Helpers ──────────────────────────────────────────────────
function Budget($p) {
    $ns = [regex]::Matches($p, '\d{1,3}(?:\.\d{3})+') | % { [double]($_.Value -replace '\.','') }
    if (-not $ns) { return 'mid' }
    $mx = ($ns | Measure-Object -Maximum).Maximum
    if ($mx -le 100000) {'cheap'} elseif ($mx -le 300000) {'mid'} elseif ($mx -le 600000) {'high'} else {'premium'}
}
function Hours($h) {
    if ($h -match '24/24|00:00') { return 'ngay' }
    $m = [regex]::Match($h, '(\d{1,2}):\d{2}')
    if ($m.Success) { $hr = [int]$m.Groups[1].Value; if ($hr -lt 11) {'sang'} elseif ($hr -lt 14) {'trua'} else {'toi'} } else {'ngay'}
}
function ShortP($p) {
    $ns = [regex]::Matches($p, '\d{1,3}(?:\.\d{3})+') | % { [double]($_.Value -replace '\.','') }
    if ($ns.Count -ge 2) { return "$([int]($ns[0]/1000))k – $([int]($ns[1]/1000))k" }
    elseif ($ns.Count -eq 1) { return "$([int]($ns[0]/1000))k" }
    return 'Liên hệ'
}
function Clean($a) { ($a -replace '^\.\s*','').Trim() }

# ── 1. Rebuild khampha card grid ─────────────────────────────
Write-Host "Rebuilding khampha.html card grid..."
$sbK = New-Object System.Text.StringBuilder
foreach ($r in $data) {
    $bud   = Budget  $r.Price
    $hcat  = Hours   $r.Hours
    $sp    = ShortP  $r.Price
    $desc  = $r.Description
    if ($desc.Length -gt 110) { $desc = $desc.Substring(0,110) + '...' }
    $nl    = $r.Name.ToLower()

    [void]$sbK.AppendLine("        <article class='card' data-district='$($r.District)' data-type='$($r.Type)' data-budget='$bud' data-rating='$($r.Rating)' data-hours='$hcat' data-name='$nl'>")
    [void]$sbK.AppendLine("          <div class='card-img-wrap'><img src='https://images.pexels.com/photos/$($r.ImgId)/pexels-photo-$($r.ImgId).jpeg?auto=compress&cs=tinysrgb&w=800' alt='$($r.Name)' class='card-img' loading='lazy' /></div>")
    [void]$sbK.AppendLine("          <div class='card-body'>")
    [void]$sbK.AppendLine("            <div class='card-meta-top'><span class='badge badge-district'>$($r.District)</span><span class='badge badge-type'>$($r.Type)</span></div>")
    [void]$sbK.AppendLine("            <h3 class='card-title'><a href='quan-$($r.Num).html'>$($r.Name)</a></h3>")
    [void]$sbK.AppendLine("            <p class='card-desc'>$desc</p>")
    [void]$sbK.AppendLine("            <div class='card-footer'><span class='price'>$sp</span><span class='stars'>★ $($r.Rating)</span></div>")
    [void]$sbK.AppendLine("          </div>")
    [void]$sbK.AppendLine("        </article>")
    [void]$sbK.AppendLine("")
}
$newGrid = $sbK.ToString()

$kHtml = [System.IO.File]::ReadAllText("$base\khampha.html", [System.Text.Encoding]::UTF8)
$kHtml = [regex]::Replace($kHtml,
    '(?s)(<div class="khampha-cards-grid" id="cardsGrid">).*?(\s*</div>\s*<!-- EMPTY)',
    "`$1`n$newGrid      `$2")
[System.IO.File]::WriteAllText("$base\khampha.html", $kHtml, $bom)
Write-Host "  -> khampha.html: $($data.Count) cards written"

# ── 2. Rebuild bando data array ──────────────────────────────
Write-Host "Rebuilding bando.html data array..."
$sbB = New-Object System.Text.StringBuilder
[void]$sbB.AppendLine("    var R=[")
foreach ($r in $data) {
    $n = $r.Name -replace "'", "\x27"
    [void]$sbB.AppendLine("      {id:$($r.Num),n:'$n',la:$($r.Lat),lo:$($r.Lng),d:'$($r.District)',t:'$($r.Type)',r:$($r.Rating),e:'$($r.Emoji)'},")
}
[void]$sbB.AppendLine("    ];")
$newArr = $sbB.ToString().Trim()

$bHtml = [System.IO.File]::ReadAllText("$base\bando.html", [System.Text.Encoding]::UTF8)
$bHtml = [regex]::Replace($bHtml, '(?s)var R=\[.*?\];', $newArr)
[System.IO.File]::WriteAllText("$base\bando.html", $bHtml, $bom)
Write-Host "  -> bando.html: $($data.Count) entries written"

# ── 3. Cross-check: khampha vs bando (both from same source) ─
Write-Host ""
Write-Host "=== CROSS-CHECK ==="

# Parse bando
$bMap = @{}
foreach ($m in [regex]::Matches($bHtml, '\{id:(\d+),n:''([^'']+)'',la:[^,]+,lo:[^,]+,d:''([^'']+)'',t:''([^'']+)'',r:([^,]+),e:''[^'']+''')) {
    $bMap[[int]$m.Groups[1].Value] = @{
        name = $m.Groups[2].Value
        d    = $m.Groups[3].Value
        t    = $m.Groups[4].Value
        r    = $m.Groups[5].Value
    }
}

# Parse khampha
$kMap = @{}
foreach ($m in [regex]::Matches($kHtml, "data-district='([^']+)' data-type='([^']+)' data-budget='[^']+' data-rating='([^']+)' data-hours='[^']+' data-name='([^']+)'")) {
    $kMap[$m.Groups[4].Value] = @{
        d = $m.Groups[1].Value
        t = $m.Groups[2].Value
        r = $m.Groups[3].Value
    }
}

Write-Host "  bando entries : $($bMap.Count)"
Write-Host "  khampha cards : $($kMap.Count)"

$issues = 0
foreach ($id in ($bMap.Keys | Sort-Object)) {
    $bn = $bMap[$id]
    $nl = $bn.name.ToLower()
    if ($kMap.ContainsKey($nl)) {
        $kn = $kMap[$nl]
        $diffs = @()
        if ($bn.t -ne $kn.t) { $diffs += "type b='$($bn.t)' k='$($kn.t)'" }
        if ($bn.d -ne $kn.d) { $diffs += "dist b='$($bn.d)' k='$($kn.d)'" }
        if ($bn.r -ne $kn.r) { $diffs += "rating b=$($bn.r) k=$($kn.r)" }
        if ($diffs.Count -gt 0) {
            Write-Host "  MISMATCH [$id] $($bn.name): $($diffs -join ' | ')"
            $issues++
        }
    } else {
        Write-Host "  NOT FOUND in khampha [$id] $($bn.name) (key: $nl)"
        $issues++
    }
}

if ($issues -eq 0) {
    Write-Host ""
    Write-Host "All systems in sync! bando <-> khampha: 0 mismatches"
} else {
    Write-Host ""
    Write-Host "$issues issues found"
}
