function ReqDov {
  param (
    $reqID
  )
  $url = "http://192.168.169.1:96/idp/rest/getview/"+$reqID
  $f_name = "dovydka"+"_"+$reqID+".json"
  If (Test-Path -Path .\dovydky\$f_name ) {
    Write-Host "File "$f_name" is exist!"
  } else{
    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.60 Safari/537.36"
    $session.Cookies.Add((New-Object System.Net.Cookie("smhuser-hpsmh_anonymous", "boxorder:Status&boxitemorder:Status&iconview:false&keepalive:false", "/", "192.168.169.1")))
    $session.Cookies.Add((New-Object System.Net.Cookie("PHPSESSID", "tufsfhj4lk13tgkqjb48qgan7v", "/", "192.168.169.1")))
    do{
      $req = Invoke-WebRequest -MaximumRetryCount 3 -RetryIntervalSec 3 -UseBasicParsing -Uri $url `
      -WebSession $session `
      -Headers @{
      "Accept"="application/json, text/plain, */*"
      "Accept-Encoding"="gzip, deflate"
      "Accept-Language"="ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7,uk;q=0.6"
      "Referer"="http://192.168.169.1:96/ips"
      } 
    } until($req.StatusCode -eq "200")
    $f_path = '.\dovydky\'+$f_name
    #$req
    Set-Content -Path $f_path -Value $req.Content
   

    $csvfpath = ".\dovydky\dovydka"+"_"+$reqID+".csv"
    Write-Host $f_path
    If (Test-Path -Path $f_path ) {
      Get-Content -Path $f_path -Encoding 'utf-8' | ConvertFrom-Json | ConvertTo-Csv -Delimiter ";" | Out-File -Encoding "windows-1251" $csvfpath
    }  
  }  
}

$csvData = Import-Csv -Path ".\Merged.csv" -Delimiter ";" -Encoding "windows-1251"
foreach ($line in $csvData){
  Write-Host $line.id
  ReqDov($line.id)
}
