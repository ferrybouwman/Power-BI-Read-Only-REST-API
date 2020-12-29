### variabelen
$tenantId = "eneco.onmicrosoft.com"
$clientId = "2ebab18d-18b7-4a9c-9536-66b190282470"
$clientSecret = "L0p_4Ju1rUEpEQ4_XXAtU-XHt26B.I38Z~"

$authToken = Get-PBIAuthToken -clientId $clientId -clientSecret $clientSecret -tenantId $tenantId
$folderPath = "D:\temp\PBI_datasets\Output"



### STAP 1: Lijst met workspace Id's opvragen die gewijzigd zijn t.o.v. modifiedSince datum. Zonder modifiedSince krijg je alles terug (gaat snel).

$parameter = "?modifiedSince=$(Get-Content $folderPath\modifiedSince.json)"
$parameter = "" # uncomment this line when retrieving everything

# log tijdstip van bovenstaand request. Schrijf deze weg naar een bestand zodat deze de volgende keer gebruikt kan worden voor modifiedSince
$newModifiedSince = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffffffK") | Out-File $folderPath\modifiedSince.json

# haal workspaces op
$modifiedWorkspaces = Invoke-PBIRequest -authToken $authToken -resource ("admin/workspaces/modified" + $parameter) -method Get -scope Admin -contentType "application/json" -ignoreGroup






### STAP 2: Per 100 workspaces de details opvragen. API is asynchroon, dus eerst opvragen en daarna met separate loop de resultaten ophalen
$batchCount = $modifiedWorkspaces.Count / 100
Write-Host "Processing $([math]::Ceiling($batchCount)) batches of 0..100" -ForegroundColor White
if ($batchCount -lt 1) {$batchCount = 1}
$workspaceInfoRequests = @()

for ($i=0;$i -lt $batchCount;$i++) {

    
    $body = 
@"
{
"workspaces" : [$('"' + ($modifiedWorkspaces[$($i*100)..($($i*100+99))].id -join '","') + '"')]
}
"@
    
    $parameter = "?lineage=True&datasourceDetails=True"
    $workspaceInfoRequests += Invoke-PBIRequest -authToken $authToken -resource ("admin/workspaces/getInfo" + $parameter) -method Post -body $body -scope Admin -contentType "application/json" -ignoreGroup

    start-sleep -ms 200

    Write-Host "Batch $($i)" -ForegroundColor White

}


### STAP 3: Resultaten van alle aanvragen ophalen
$workspaceInfo = @()
$count = 1

foreach ($workspaceInfoRequest in $workspaceInfoRequests) {

    Write-Host "Getting batch $($count) with id $($workspaceInfoRequest.id)" -ForegroundColor White

    $parameter = "/" + $workspaceInfoRequest.id
    #$status = Invoke-PBIRequest -authToken $authToken -resource ("admin/workspaces/scanStatus" + $parameter) -method Get -scope Admin -contentType "application/json" -ignoreGroup

    while ($status.status -ne "Succeeded") { # 5 seconden wachten indien het antwoord nog niet klaar staat (op dit moment is de API nog heel snel)

        $status = Invoke-PBIRequest -authToken $authToken -resource ("admin/workspaces/scanStatus" + $parameter) -method Get -scope Admin -contentType "application/json" -ignoreGroup
        start-sleep 5
        Write-Host "Wait 5 seconds.." -ForegroundColor Yellow
        

    }

    $workspaceInfo += Invoke-PBIRequest -authToken $authToken -resource ("admin/workspaces/scanResult" + $parameter) -method Get -scope Admin -contentType "application/json" -ignoreGroup
    Write-Host "Batch received" -ForegroundColor Green

    $count++

}

# wegschrijven resultaat naar JSON bestand
$workspaceInfo | ConvertTo-Json -Depth 10 | Out-File $folderPath\reportingAPI_$(Get-Date -Format "yyyyMMddHHmmss").json