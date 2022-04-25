#Якщо $GenREPORT= 'True' скрипт підрахує кількість справ, які починаются на 5 (УСЗН) та 7 (ОТГ), та відобразить кількість в консолі
$GenREPORT = 'False'
#
function createNonExistFolder {
    param (
        $PathToFolder
    )
    If (Test-Path -Path $PathToFolder -PathType Container) {
        Write-Host "Folder $PathToFolder is exist"
      }else{
          New-Item -Path $PathToFolder -ItemType Container
          Write-Host "Folder $PathToFolder is created"
      }     
}
createNonExistFolder -PathToFolder ".\jsons"
createNonExistFolder -PathToFolder ".\results"
$jsonsPath = '.\jsons'
$resultsPath ='.\results'
$jsonsArr = @()
foreach($jsonFile in (Get-ChildItem -Path $jsonsPath -Filter "IPS_*.json")){
    $jsonsArr += Get-Content -Path $jsonFile.FullName | ConvertFrom-Json   
}
$csvFilePath = -join($resultsPath, '\', (Get-Date -Format "yyyy-MM-dd_HH;mm"), "_", 'IPS', '.csv')
$jsonsArr | Export-Csv -Path $csvFilePath -Encoding "windows-1251" -Delimiter ";"
Write-Host "Файл експортовано: $csvFilePath"
if($GenREPORT -eq 'True'){
    $sumOfOur = 0
    $SumOfAnother = 0
    foreach($elem in $jsonsArr){
        if($elem.nnumber[0] -eq '5'){
            $sumOfOur += 1
        }else{
            $SumOfAnother += 1
        }
    }
    Write-Host "Кількість справ УСЗН (починаютстя на 5): $sumOfOur"
    Write-Host "Кількість справ ОТГ (починаютстя на 7): $SumOfAnother"
}
