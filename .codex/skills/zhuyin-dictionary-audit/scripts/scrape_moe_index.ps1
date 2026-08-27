param(
  [string]$Output = "moe-zhuyin-index.csv"
)

$ErrorActionPreference = 'Stop'
$base = 'https://dict.concised.moe.edu.tw'
$symbols = 'ㄅㄆㄇㄈㄉㄊㄋㄌㄍㄎㄏㄐㄑㄒㄓㄔㄕㄖㄗㄘㄙㄚㄛㄜㄞㄟㄠㄡㄢㄣㄤㄦㄧㄨㄩ'.ToCharArray()
$rows = [System.Collections.Generic.List[object]]::new()
$seen = @{}

function Decode([string]$text) {
  return [System.Net.WebUtility]::HtmlDecode($text)
}

function CleanHtml([string]$text) {
  $value = $text -replace '<[^>]*>', ''
  return (Decode $value).Trim()
}

function Get-Page([string]$url) {
  for ($attempt = 1; $attempt -le 3; $attempt++) {
    try { return Invoke-WebRequest -UseBasicParsing -Uri $url }
    catch {
      if ($attempt -eq 3) { throw }
      Start-Sleep -Milliseconds (500 * $attempt)
    }
  }
}

function AbsoluteUrl([string]$href) {
  $url = (Decode $href) -replace '^/', "$base/"
  if ($url -notmatch '^https?://') { $url = "$base/$url" }
  return $url
}

foreach ($symbol in $symbols) {
  $sn = [uri]::EscapeDataString([string]$symbol)
  $index = Get-Page "$base/searchP.jsp?SN=$sn"
  $combos = [ordered]@{}
  foreach ($link in @($index.Links | Where-Object { $_.href -match 'SN2=' -and $_.href -match 'searchP.jsp' })) {
    $href = AbsoluteUrl $link.href
    $label = ''
    if ($href -match 'SN2=([^&#]+)') { $label = [uri]::UnescapeDataString($matches[1]) }
    if ($href -and !$combos.Contains($href)) { $combos[$href] = $label }
  }

  foreach ($href in $combos.Keys) {
    $combo = Get-Page $href
    $comboLabel = $combos[$href]
    $charPattern = '<a\s+href=["'']([^"'']*searchP\.jsp[^"'']*word=[^"'']*)["''][^>]*>(.*?)</a>'
    $charMatches = [regex]::Matches($combo.Content, $charPattern, [Text.RegularExpressions.RegexOptions]::IgnoreCase -bor [Text.RegularExpressions.RegexOptions]::Singleline)
    $characters = [ordered]@{}
    foreach ($match in $charMatches) {
      $charUrl = AbsoluteUrl $match.Groups[1].Value
      $character = CleanHtml $match.Groups[2].Value
      if ($character -and !$characters.Contains($character)) { $characters[$character] = $charUrl }
    }

    foreach ($character in $characters.Keys) {
      $charUrl = $characters[$character]
      if (!$seen.ContainsKey("$comboLabel|$character")) {
        $seen["$comboLabel|$character"] = $true
        $charPage = Get-Page $charUrl
        $termPattern = '<a\s+href="([^"]*dictView\.jsp[^"]*)"[^>]*>(.*?)</a>'
        $termMatches = [regex]::Matches($charPage.Content, $termPattern, [Text.RegularExpressions.RegexOptions]::IgnoreCase -bor [Text.RegularExpressions.RegexOptions]::Singleline)
        $terms = @($termMatches | ForEach-Object { CleanHtml $_.Groups[2].Value } | Where-Object { $_ } | Select-Object -Unique)
        if ($terms.Count -eq 0) { throw "No dictionary terms found for $character at $charUrl" }
        foreach ($term in $terms) {
          $rows.Add([pscustomobject]@{
            BaseSymbol = $symbol
            Combination = $comboLabel
            Character = $character
            Words = $term
            SourceUrl = $href
            CharacterUrl = $charUrl
          })
        }
      }
    }
  }
  Write-Output "Completed ${symbol}: $($rows.Count) word rows"
}

$rows | Sort-Object BaseSymbol,Combination,Character,Words | Export-Csv -NoTypeInformation -Encoding UTF8 -LiteralPath $Output
Write-Output "Scanned $($symbols.Count) base symbols and $($rows.Count) character-word rows: $Output"
