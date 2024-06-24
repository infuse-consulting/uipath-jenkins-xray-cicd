# Powershell script to upload test results to Xray
#
# $clientID - the client ID for Xray API
# $clientSecret - the client secret for Xray API
# $frameworkEndpoint - the API endpoint depending on the testing framework. Accepts junit, nunit, xunit, testng and robot
# $projectKey - the Jira project key
# $testExecKey - the test execution to push the results to
# $testPlanKey - the test plan to push the results to
# $testEnvironments - a string containing a list of test envs seperated by ";"
# $revision - source code and documentation version used in the test execution
# $fixVersion - the fix version associated with the test execution
# $resultsFile - the results file (e.g. testResults.xml)

param(
    $clientID,
    $clientSecret,
    $frameworkEndpoint,
    $projectKey,
    $testExecKey,
    $testPlanKey,
    $testEnvironments,
    $revision,
    $fixVersion,
    $resultsFile
)

try {
    $jiraBaseURL = 'https://xray.cloud.getxray.app/api/v2'
    $json = @"
    {
     "client_id": "$($clientID)", "client_secret": "$($clientSecret)"
    }
"@
 
    $uri = "$($jiraBaseURL)/authenticate"

    # Get token

    $response = Invoke-WebRequest -Uri $uri -UseBasicParsing -Body $json -Method POST -ContentType "application/json"
    $token = $response -replace '"','' 
 
    # Import results to Xray

    $fileContent = Get-Content -Path $resultsFile -Raw
    $uri = "$($jiraBaseURL)/import/execution/$($frameworkEndpoint)?projectKey=$($projectKey)&testExecKey=$($testExecKey)&testPlanKey=$($testPlanKey)&testEnvironments=$($testEnvironments)&revision=$($revision)&fixVersion=$($fixVersion)"
    Write-Host "Request URI: $($uri)"
    
    $response = Invoke-WebRequest -ContentType "text/xml" -Uri $uri -UseBasicParsing -Body $fileContent -Method POST -Headers @{"Authorization" = "Bearer $token"}
    write-host "Response: $($response)"
  }

catch {
    write-host $_.Exception.Message
}