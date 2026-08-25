$EventId = 11,4660,4663

$A = Get-WinEvent -MaxEvents 1  -FilterHashTable @{Logname = "System" ; ID = $EventId}
$Message = $A.Message
$EventID = $A.Id
$MachineName = $A.MachineName
$Source = $A.ProviderName


$EmailFrom = "{myfromemailaddress"
$EmailTo = "{myemailaddress}"
$Subject ="Alert From $MachineName"
$Body = "EventID: $EventID`nSource: $Source`nMachineName: $MachineName `nMessage: $Message"
$SMTPServer = "{SMTPserver}"
write-host $body

$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587)
$SMTPClient.EnableSsl = $true
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential("{user/email}", "{mypassword}");
$SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body)
