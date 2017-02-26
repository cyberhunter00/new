
#to send email
Send-Email -toAddress 'email@email.com' -subject 'subject' -body "The Upload Log Is Attached." -attachmentLocation 'c:\log\log.txt'


Function Send-Email{
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$toAddress,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$subject,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$body,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$attachmentLocation
    )

    $fromaddress = "hello@world.com" 
    #$Subject = "" 
    #$body = ""
    #$attachment = "location of attachment"
    $smtpserver = "smtp.gmail.com" 
    $SMTPPort = "587"
    #################################### 
 
    $message = new-object System.Net.Mail.MailMessage 
    $message.From = $fromaddress 
    $message.To.Add($toaddress) 
    $message.Subject = $subject 
    if (($attachmentLocation -ne $null) -and($attachmentLocation -ne ""))
    {
        $attach = new-object Net.Mail.Attachment($attachmentLocation) 
        $message.Attachments.Add($attach) 
    }
    $message.body = $body 
    $smtp = new-object Net.Mail.SmtpClient($smtpserver, $SMTPPort) 
    $smtp.Send($message) 

}

Function Fail-Script {
    Send-Email -toAddress "hello@world.com" -subject "subject of the email" -body "something wrong See attached log." -attachmentLocation $logfile
    Break
}
