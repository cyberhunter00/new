<#
	.AUTHOR
		Will Steele (wlsteele@gmail.com)

	.DEPENDENCIES
		Powershell v2 (for Out-Gridview cmdlet)

	.DESCRIPTION
		This script is a proof of concept. Further work needs to be done.  It 
		requires the user to enter a valid username and password for a gmail.com 
		account.  It then attempts to form an SSL connection with the server, and, 
		retrieve the first email. Unfortunately it returns random results.  Perhaps 
		someone can improve upon it.
	
	.EXAMPLE
		Get-Gmail -username 'you@gmail.com' -password '\/0u|>p@55w0rd'
	
	.EXTERNALHELP
		None.
		
	.FORWARDHELPTARGETNAME
		None.
		
	.INPUTS
		System.Object
		
	.LINK
		http://learningpcs.blogspot.com/2012/01/powershell-v2-read-gmail-more-proof-of.html.
		
	.NAME
		Get-Gmail.ps1
		
	.NOTES
		The script is further explored to find 'From' addressses in the link above.
		I have piped the $str variable to Out-Gridview. This can be changed to something
		more suitable for real processing.
		
	.OUTPUTS
		System.String
		
	.PARAMETER username
		A required parameter for a valid gmail email user. Use the whole string.
		
	.PARAMETER password
		A required parameter for the account password.
	
	.SYNOPSIS
		Read .
#>

[CmdletBinding()]
param(
	[Parameter(
		Mandatory = $true,
		Position = 0,
		ValueFromPipeline = $true
	)]
	[ValidateNotNullOrEmpty()]
	[String]
	$username,
	
	[Parameter(
		Mandatory = $true,
		Position = 1,
		ValueFromPipeline = $true
	)]
	[ValidateNotNullOrEmpty()]
	[String]
	$password
)

Clear-Host 

try {
	Write-Output "Creating new TcpClient."
	$tcpClient = New-Object -TypeName System.Net.Sockets.TcpClient
	
	# Connect to gmail
	$tcpClient.Connect("pop.gmail.com", 995)
	
	if($tcpClient.Connected) {
		Write-Output "You are connected to the host. Attempting to get SSL stream."
		
		# Create new SSL Stream for tcpClient
		Write-Output "Getting SSL stream."
		[System.Net.Security.SslStream] $sslStream = $tcpClient.GetStream()
		
		# Authenticating as client
		Write-Output "Authenticating as client."		
		$sslStream.AuthenticateAsClient("pop.gmail.com");
		
		if($sslStream.IsAuthenticated) {
			Write-Output "You have authenticated. Attempting to login."
			# Asssigned the writer to stream 
			[System.IO.StreamWriter] $sw = $sslstream
			
			# Assigned reader to stream
			[System.IO.StreamReader] $reader = $sslstream
			
			# refer POP rfc command, there very few around 6-9 command
			$sw.WriteLine("USER $username")
			
			# sent to server
			$sw.Flush()
			
			# send pass
			$sw.WriteLine("PASS $password");
			$sw.Flush()
			
			# this will retrive your first email
			$sw.WriteLine("RETR 1")
			$sw.Flush()
			
			$sw.WriteLine("Quit ");
			$sw.Flush();
			
			[String] $str = [String]::Empty
			[String] $strTemp = [String]::Empty

			while (($strTemp = $reader.ReadLine()) -ne $null) {
				# find the . character in line
				if($strTemp -eq '.') {
					break;
				}

				if ($strTemp.IndexOf('-ERR') -ne -1) {
					break;
				}
					
				$str += $strTemp;
			}
			
			# Return raw data
			Write-Output "`nOutput email"
			$str | Out-GridView
		} else { 
			Write-Error "You were not authenticated. Quitting."
		}
		
	} else {
		Write-Error "You are not connected to the host. Quitting"
	}
}

catch {
	$_
}

finally {
	Write-Output "Script complete."
}