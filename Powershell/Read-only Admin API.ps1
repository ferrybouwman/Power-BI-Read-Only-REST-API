### set variables
$tenantId = "insert organization.onmicrosoft.com"
$clientId = "inset client id"
$clientSecret = "insert client secret"

# dependency with PowerBIPS module, please install first using install-module powerbips
$authToken = Get-PBIAuthToken -clientId $clientId -clientSecret $clientSecret -tenantId $tenantId
$folderPath = "D:\temp"



### STEP 1: Retrieve list with workspace Ids which have been modified since a given date (optionally). Without modifiedSince essentially you will get a full metadata snapshot.

# get modifiedSince from locally stored file
$parameter = "?modifiedSince=$(Get-Content $folderPath\modifiedSince.txt)"
#$parameter = "" # uncomment this line when retrieving everything

# log timestamp of above request. Store in file for re-use when this script runs again.
$newModifiedSince = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffffffK") | Out-File $folderPath\modifiedSince.txt

# Call /modified endpoint to retrieve workspaces
$modifiedWorkspaces = Invoke-PBIRequest -authToken $authToken -resource ("admin/workspaces/modified" + $parameter) -method Get -scope Admin -contentType "application/json" -ignoreGroup






### STEP 2: Retrieve details per batch of 100 workspaces. API is asynchronous, so request first, then retrieve later in a separate loop.

# determine amount of batches
$batchCount = [math]::Ceiling($modifiedWorkspaces.Count / 100)
Write-Host "Processing $($batchCount) batches of 0..100" -ForegroundColor White

# create array
$workspaceInfoRequests = @()

# loop through batches
for ($i=0;$i -lt $batchCount;$i++) {

    #create json body with workspace IDs corresponding to batch
    $body = 
@"
{
"workspaces" : [$('"' + ($modifiedWorkspaces[$($i*100)..($($i*100+99))].id -join '","') + '"')]
}
"@
    
	# we want lineage and datasource details
    $parameter = "?lineage=True&datasourceDetails=True&datasetSchema=true&datasetExpressions=true"
	# Call /getInfo API
    $workspaceInfoRequests += Invoke-PBIRequest -authToken $authToken -resource ("admin/workspaces/getInfo" + $parameter) -method Post -body $body -scope Admin -contentType "application/json" -ignoreGroup

	# wait a little bit, since the API has a limit, not thoroughly tested, but this prevented the occasionally thrown errors
    start-sleep -ms 200
    Write-Host "Batch $($i)" -ForegroundColor White

}


### STEP 3: Fetch results of earlier requests

#create array in which we append all received data
$workspaceInfo = @()
$count = 1

# loop through all earlier requests
foreach ($workspaceInfoRequest in $workspaceInfoRequests) {

    Write-Host "Getting batch $($count) with id $($workspaceInfoRequest.id)" -ForegroundColor White

    $parameter = "/" + $workspaceInfoRequest.id
    #$status = Invoke-PBIRequest -authToken $authToken -resource ("admin/workspaces/scanStatus" + $parameter) -method Get -scope Admin -contentType "application/json" -ignoreGroup

	# Check if the request is processed already, otherwise wait 5 seconds and check again
    while ($status.status -ne "Succeeded") {

        $status = Invoke-PBIRequest -authToken $authToken -resource ("admin/workspaces/scanStatus" + $parameter) -method Get -scope Admin -contentType "application/json" -ignoreGroup
        start-sleep 5
        Write-Host "Wait 5 seconds.." -ForegroundColor Yellow
        

    }

	# when ready, retrieve data and add to array
    $workspaceInfo += Invoke-PBIRequest -authToken $authToken -resource ("admin/workspaces/scanResult" + $parameter) -method Get -scope Admin -contentType "application/json" -ignoreGroup
    Write-Host "Batch received" -ForegroundColor Green

    $count++

}

# output results to JSON file
$workspaceInfo | ConvertTo-Json -Depth 10 | Out-File $folderPath\PBI_API_output_$(Get-Date -Format "yyyyMMddHHmmss").json
