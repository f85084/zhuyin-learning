param(
  [string]$Output = "moe-zhuyin-index.csv"
)

$ErrorActionPreference = 'Stop'
$base = 'https://dict.concised.moe.edu.tw'
$symbols = 'ㄅㄆㄇㄈㄉㄊㄋㄌㄍㄎㄏㄐㄑㄒㄓㄔㄕㄖㄗㄘㄙㄚㄛㄜㄞㄟㄠㄡㄢㄣㄤㄦㄧㄨㄩ'.ToCharArray()
$rows = [System.Collections.Generic.List[object]]::new()

function Decode([string]$text) {
  return [System.Net.WebUtility]::HtmlDecode($text)
}

foreach ($symbol in $symbols) {
  $sn = [uri]::EscapeDataString([string]$symbol)
  $index = Invoke-WebRequest -UseBasicParsing -Uri "$base/searchP.jsp?SN=$sn"
  $combos = @{}
  foreach ($link in @($index.Links | Where-Object { $_.href -match "SN2=" -and $_.href -match "searchP.jsp" })) {
    $href = ($link.href -replace "^/", "$base/") -replace "&amp;", "&"
    $label = ''
    if ($href -match 'SN2=([^&#]+)') { $label = [uri]::UnescapeDataString($matches[1]) }
    if ($href -and !$combos.ContainsKey($href)) { $combos[$href] = $label }
  }
  foreach ($href in $combos.Keys) {
    $combo = Invoke-WebRequest -UseBasicParsing -Uri $href
    $comboLabel = $combos[$href]
    $wordPattern = '<a href=.*?word=.*?>(.*?)</a>'
    $wordMatches = [regex]::Matches($combo.Content, $wordPattern, [Text.RegularExpressions.RegexOptions]::Singleline)
    $words = @($wordMatches | ForEach-Object { (Decode ($_.Groups[1].Value -replace '<.*?>','')).Trim() } | Where-Object { $_ } | Select-Object -Unique)
    if ($words.Count -eq 0) { $words = @('') }
    foreach ($word in $words) {
      $rows.Add([pscustomobject]@{ BaseSymbol=$symbol; Combination=$comboLabel; Character=$word; SourceUrl=$href })
    }
  }
}

$rows | Sort-Object BaseSymbol,Combination,Character | Export-Csv -NoTypeInformation -Encoding UTF8 -LiteralPath $Output
Write-Output "Scanned $($symbols.Count) base symbols and $($rows.Count) dictionary rows: $Output"
