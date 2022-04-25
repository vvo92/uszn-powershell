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
foreach($jsonFile in (Get-ChildItem -Path $jsonsPath -Filter "dovydka_*.json")){
    #Write-Host $jsonFile.FullName
    $jsonsArr += Get-Content -Path $jsonFile.FullName | ConvertFrom-Json   
}
#$jsonsArr
$csvFilePath = -join($resultsPath, '\', (Get-Date -Format "yyyy-MM-dd_HH;mm"), "_", 'dovydka', '.csv')
$jsonsArr | Export-Csv -Path $csvFilePath -Encoding "windows-1251" -Delimiter ";"
Write-Host "Файл експортовано: $csvFilePath"