$modifiedSince = "2020-12-29T13:02:38.3525654Z" # 24 hour time notation

$response = Invoke-WebRequest `
    -Uri "past HTTP GET URL from FLOW" `
    -Method Get `
    -ContentType application/json

# HTTP GET URL should look something like: https://prod-28.westeurope.logic.azure.com/workflows/c49fda0c49fda0c49fda8688a46da0c4/triggers/manual/paths/invoke/modifiedSince/$($modifiedSince)?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=JyX4ySR5_RltZcgM4WEs
