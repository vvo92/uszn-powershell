$curDir = Get-Location
$mergedCSVPath = $curDir.Path+"\Merged.csv"
$getFirstLine = $true
$title_line = '"iapplication";"id";"nnumber";"csurname";"cname";"cpatronymic";"dsubmitted";"dcancellation";"ccancellationreason";"csri";"cdocumentserie";"cndocumentnumber";"dborn";"cstate";"istate";"csubmittertype";"icurrentstate";"ireceiver";"creceiver";"cnt"'
Add-Content -Encoding "windows-1251" "Merged.csv" $title_line
Get-ChildItem ".\" -Filter "*.csv" | ForEach-Object {
    $filePath = $_
    if ($filePath -notlike $mergedCSVPath){
       Write-Host $filePath
       $lines = Get-Content -Encoding "windows-1251" $filePath  
       $linesToWrite = switch($getFirstLine) {
           $true  {$lines}
           $false {$lines | Select-Object -Skip 1}

       }

       $getFirstLine = $false
       Add-Content -Encoding "windows-1251" "Merged.csv" $linesToWrite
       }
    
    }