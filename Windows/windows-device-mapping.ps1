#this script will update Computer name based on current user logged-in the Windows devices
# Get the current logged-in username 

$currentUser = (Get-WmiObject -Class Win32_ComputerSystem).UserName

# Extract only the username 

$usernameOnly = ($currentUser -split '\\')[-1]

$cleanUsername = $usernameOnly -replace '\s+', '-' -replace '[^a-zA-Z0-9\-]', ''

# Set the computer name to the cleaned username

Rename-Computer -NewName $cleanUsername
