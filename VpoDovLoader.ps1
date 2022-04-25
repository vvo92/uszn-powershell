function getCryptoAutographJSON {
    param (
        $URL
    )
    Try{  
        Do{
            $WS = New-Object System.Net.WebSockets.ClientWebSocket                                                
            $CT = New-Object System.Threading.CancellationToken
            $WS.Options.UseDefaultCredentials = $true    
            #Get connected
            $Conn = $WS.ConnectAsync($URL, $CT)
            While (!$Conn.IsCompleted) { 
                Start-Sleep -Milliseconds 100 
            }
            Write-Host "Connected to $($URL)"
            $Size = 1024
            $Array = [byte[]] @(,0) * $Size    
            #Send Starting Request
            $PAYLOAD = [ordered]@{
                id=2;
                command="sign";
                data="MDUzNzYwNjU=";
                pin = "3882";
                storeContent = "true";
                includeCert = "true";
                useStamp = "false"
            }
            $JsonPAYLOAD = ConvertTo-Json -InputObject $PAYLOAD
            $Command = [System.Text.Encoding]::UTF8.GetBytes($JsonPAYLOAD)
            $Send = New-Object System.ArraySegment[byte] -ArgumentList @(,$Command)            
            $Conn = $WS.SendAsync($Send, [System.Net.WebSockets.WebSocketMessageType]::Text, $true, $CT)    
            While (!$Conn.IsCompleted) { 
                Start-Sleep -Milliseconds 100 
            }
            Write-Host "Finished Sending Request"
            #Start reading the received items
            $jsonLoadState = "0"
            While ($WS.State -eq "Open") {                        
                $Recv = New-Object System.ArraySegment[byte] -ArgumentList @(,$Array)
                $Conn = $WS.ReceiveAsync($Recv, $CT)
                While (!$Conn.IsCompleted) { 
                        Start-Sleep -Milliseconds 100
                }
                $resp += [System.Text.Encoding]::utf8.GetString($Recv.array)
                if ($Conn.Result.EndOfMessage -eq $true){
                    Write-Host("Reading data from key is Done!")
                    $ws.Dispose()
                    $jsonLoadState = "1"
                }else {
                    Write-Host("Reading data from key...")
                }
            }
        } Until ($jsonLoadState -eq "1")
        Set-Content -Path .\crypt_token.json -Value ($resp) -Force
    }Finally{
        If ($WS) { 
            Write-Host "Closing websocket"
            $WS.Dispose()
        }
    }
}
function readSign {
    param (
        $PathToAuthJson
    )
    $signFileJson = Get-Content -Path $pathToAuthJson -TotalCount 25 | ConvertFrom-Json
    return $signFileJson.data.data
}
function getAuthToken {
    param (
        $CryptoSrvIP,
        $User,
        $Userpwd
    )
    $signData = readSign -PathToAuthJson ".\crypt_token.json"
    Remove-Item -Path .\crypt_token.json
    $PAYLOAD = [ordered]@{
        api="authApi";
        username="username";
        password="userpass";
        sign = "signData";
        sandbox=0
    }
    $PAYLOAD["username"] = $User
    $PAYLOAD["password"] = $Userpwd
    $PAYLOAD["sign"] = $signData
    $JsonPAYLOAD = ConvertTo-Json -InputObject $PAYLOAD
    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $url = -join("http://",$CryptoSrvIP, ":96/idp/rest/user/login")
    $req = Invoke-WebRequest -UseBasicParsing -Uri $url `
    -Method "POST" `
    -WebSession $session `
    -Headers @{} `
    -ContentType "application/json;charset=UTF-8" `
    -Body $JsonPAYLOAD
    $PHPSESSID = ($req.Headers["Set-Cookie"]).Substring(0, ($req.Headers["Set-Cookie"]).LastIndexof(";"))
    return ($PHPSESSID -split "=")[-1]
}
function DovReqJson {
    param (
        $CRYPTOSRVIP,
        $PHPSESSID,
        $ReqDovID      
    )
    $url = -join("http://", $CRYPTOSRVIP, ":96/idp/rest/getview/", $ReqDovID)
    $jsonPath = -join(".\jsons\dovydka_", $ReqDovID, ".json")
    If (Test-Path -Path $jsonPath  ) {
      Write-Host "File $jsonPath is exist!"
    } else{
      $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
      $session.Cookies.Add((New-Object System.Net.Cookie("PHPSESSID", $PHPSESSID, "/", $CRYPTOSRVIP)))
      do{
        $req = Invoke-WebRequest -UseBasicParsing -Uri $url `
        -WebSession $session `
        -Headers @{} 
      } until($req.StatusCode -eq "200")
      Set-Content -Path $jsonPath -Value $req.Content
    }
}
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
function DovHandler {
    param (
        $CryptoSrvIP,
        $Username,
        $Userpwd
    )
    createNonExistFolder -PathToFolder ".\jsons"
    createNonExistFolder -PathToFolder ".\results"
    getCryptoAutographJSON -Url "ws://localhost:11111"
    $PHPSESSID = getAuthToken -cryptoSrvIP $CryptoSrvIP -user $Username -userpwd $Userpwd
    $jsonsPath = '.\jsons'
    foreach($jsonFile in (Get-ChildItem -Path $jsonsPath -Filter "IPS_*.json")){
        $jsonsArr += Get-Content -Path $jsonFile.FullName | ConvertFrom-Json
    foreach($elem in $jsonsArr){
        $elem.id
        DovReqJson -CRYPTOSRVIP $CryptoSrvIP -PHPSESSID $PHPSESSID -ReqDovID $elem.id
    }
}
} 

#------settings----------------
#For example:
#
#$CRYPTOSRVIP = "127.0.0.1"
#$USERNAME = "User111021"
#$USERPASSWORD = "SA921m410f"
$CRYPTOSRVIP = "127.0.0.1"
$USERNAME = "User111021"
$USERPASSWORD = "User111021"
#------endOfSettings-----------

DovHandler -CryptoSrvIP $CRYPTOSRVIP -Username $USERNAME -Userpwd $USERPASSWORD