
function OpenConnection () {
    # Please change the connection string to yours. You can specify user and password like this:
    # $connectionString = "Server=localhost\AdminSystem;Database=dbname;User Id=user;Password=yourpassword;MultipleActiveResultSets=True;"
    # https://msdn.microsoft.com/en-us/library/system.data.sqlclient.sqlconnection.connectionstring(v=vs.110).aspx

    $connectionString = "Server={Server/Instance};Database=Utilities;Integrated security=SSPI;MultipleActiveResultSets=True;"
    #Write-Host(("Connecting database {0} ..." -f $connectionString))
    $sqlConnection = New-Object System.Data.SqlClient.SqlConnection
    $sqlConnection.ConnectionString = $connectionString

    $sqlConnection.Open()
    #Write-Host 'Connected to Squeekal!!'
    return $sqlConnection
}

#**************************
#***** WHERE TO BEGIN *****
#**************************
clear
# check if SQL module is loaded, if not better go get it!!!
if (Get-Module -ListAvailable -Name SqlServer) { Write-Host "Module exists" } 
else {
    Write-Host "Module does not exist, so we will try to get it."
    Install-module -Name SqlServer
}


$sqlinstance = "{Server/Instance}"
$squeekal_U  = "{user}"
$squeekal_P  = "{mypassword}"

$params = @{
    'Database'       = "Utilities";
    'ServerInstance' = $sqlinstance;
    'Username'       = $squeekal_U;
    'Password'       = $squeekal_P;
    'TrustServerCertificate' = $true
     }

#****************************************************************************************
#used for debugging
#$query = "exec [Utilities].[dbo].[Job_DailyScan_sp]"
#$results = Invoke-Sqlcmd -Query $query @params
#****************************************************************************************

#get records to email
#open SQL connection
#$sqlConnection = OpenConnection
$query = "select cast(id as varchar(5)) as id, send_from,recipient,bcc_recipient,subject,body,email_type,send_after_dttm from Utilities.dbo.Emailer where processed is null"
#the Invoke apparently does not read or process the entire BODY field
#$dataset = Invoke-Sqlcmd -Query $query @params
#foreach ($row in $dataset) {
#open SQL connection
$sqlConnection = OpenConnection
$sqlCommand = New-Object System.Data.SqlClient.SqlCommand($query, $sqlConnection);
$reader = $sqlCommand.ExecuteReader()

while ($reader.Read()) {
    $count=0
    #$id      = $row[0]
    #$from    = $row[1].Trim()
    #$to      = $row[2].Trim()
    #$bcc     = $row[3]
    # we send to NoBody cause we need a vaild email address, dirty hack
    #IF ([string]::IsNullOrWhitespace($bcc)){$bcc=$to} 
    #$subject = $row[4].Trim()
    #$body    = $row[5].Trim()
    #$type    = $row[6]
    #if ($type -eq "HTML"){$sendType=$true} 
    #else {$sendType=$false}
    
    $id      = $reader.GetString(0).ToString()
    $from    = $reader.GetString(1).Trim()
    $to      = $reader.GetString(2).Trim()
    
    # we send to NoBody cause we need a vaild email address, dirty hack
    #$bcc     = $reader.GetString(3).Trim()
    try{$bcc     = $reader.GetString(3).Trim()} catch {$bcc=""}
    

    $subject = $reader.GetString(4).Trim()
    $body    = $reader.GetString(5).Trim()
    $type    = $reader.GetString(6).Trim()
    if ($type -eq "HTML"){$sendType=$true} 
    else {$sendType=$false}


    ## BEGIN: SEND EMAIL ##
    #Credential = 'domain01\admin01'
    #Bcc        = $bcc
    #DeliveryNotificationOption="OnSuccess"      
    #Priority   = "High"        
    $emails=$to -split ";"
    foreach($email in $emails) 
    {
	    $sendMailMessageSplat = @{
	        From       = $from
	        To         = $to 
	        Subject    = $subject
	        Body       = $body                
	        UseSsl     = $false                
	        BodyAsHtml = $sendType                
	        SmtpServer = "astechep-com.mail.protection.outlook.com"
	        Port       = "25"            
	    }
	    if ($bcc -eq "") {
	        # do nothing    
	    } else {
	        if ($count -eq 0){
	            #append to hash table
	            $sendMailMessageSplat["Bcc"] = $bcc
                $count+=1
	        }
	    }
    }
    #write-output $sendMailMessageSplat   #used for debugging
    ## END: SEND EMAIL ##
    
    try{
        Send-MailMessage @sendMailMessageSplat -ErrorAction Stop

        #mark as completed     
        $sent_dt = get-date -Format "yyyy/MM/dd HH:mm:ss"
        $query   = "update Utilities.dbo.Emailer set processed='Y', sent_dttm='$($sent_dt)' where id=$($id)"
        $results = Invoke-Sqlcmd -Query $query @params  
    }
    catch [System.Exception] {
        "Failed to send email: $($email) : " -f  $_.Exception.Message
        #mark as failed                
        $errMsg = $_.Exception.Message  
        $errMsg = $errMsg.replace("'",'"')
        $query  = "update Utilities.dbo.Emailer set err_message='$($errMsg)' where id=$($id)"        
        $results = Invoke-Sqlcmd -Query $query @params
    }

    #go to next record, or not if all done.
}

#housekeeping, time to take out the trash
$reader.Close > $null
$reader.Dispose > $null
$sqlConnection.Close > $null
$sqlConnection.Dispose > $null
