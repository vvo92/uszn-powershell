function ReqD {
  param (
    $reqDate
  )
  $fromDate = $reqDate
  $tillDate = $reqDate
  $url = "http://192.168.169.1:96/idp/application/search?mode=list&from="+$fromDate+"&till="+$tillDate
  $f_name = "vpo_"+$fromDate+"_"+$tillDate+".json"
  If (Test-Path -Path .\$f_name ) {
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
    Set-Content -Path $f_name -Value $req
    
   

  $csvfName = "vpo_"+$fromDate+"_"+$tillDate+".csv"
  If (Test-Path -Path .\$f_name ) {
    Get-Content -Encoding "utf-8" .\$f_name | ConvertFrom-Json | ConvertTo-Csv -Delimiter ";" | Out-File -Encoding "windows-1251" .\$csvfName
  }  
  }  
}

$startDate = New-Object System.DateTime(2022,2,24)
$currentDate = Get-Date
$quantityOfDays = ($currentDate - $startDate).Days
$daysRange = 0..$quantityOfDays
foreach ($day in $daysRange){
    $reqDay = $startDate.AddDays($day).ToString('dd.MM.yyyy') 
    Write-Host "Start downloading file for $reqDay"
    ReqD($reqDay)
}