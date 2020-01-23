Param($server, $account, $password, $artifact, $path)

echo "Connecting to $server..."
Set-Item WSMan:\localhost\Client\TrustedHosts -Value $server -Force
$password = ConvertTo-SecureString -AsPlainText $password -Force
$credential = New-Object System.Management.Automation.PSCredential -ArgumentList $account, $password
$session = New-PSSession -ComputerName $server -Credential $credential

$title = $path.Split('\')[1]

echo "Shutdown service $title"
Invoke-Command -Session $session -ScriptBlock {
  Param($title)
  PsExec -d -s -i 2 taskkill /fi "windowtitle eq $title"
} -ArgumentList $title

echo "Deploying artifact to $path..."
Copy-Item $artifact -Destination $path -ToSession $session

echo "Startup service $title"
Invoke-Command -Session $session -ScriptBlock {
  Param($artifact, $path, $title)
  if ($title.Contains('-dev')) {
    $command = "start ""$title"" java -jar $artifact"
  } else {
    $command = "start ""$title"" java -jar $artifact --spring.profiles.active=prod"
  }
  PsExec -d -s -i 2 -w $path cmd /c $command
} -ArgumentList $artifact, $path, $title

Remove-PSSession -Session $session
echo 'Done'
