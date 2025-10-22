#this script will create user account with the administrator access in the device.

# Ensure script is running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Add-Type -AssemblyName System.Windows.Forms

function Show-CredentialPrompt {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Create Admin User'
    $form.Width = 300
    $form.Height = 220
    $form.StartPosition = 'CenterScreen'

    $labelUser = New-Object System.Windows.Forms.Label
    $labelUser.Text = 'Username:'
    $labelUser.Left = 10
    $labelUser.Top = 20
    $labelUser.Width = 80

    $textBoxUser = New-Object System.Windows.Forms.TextBox
    $textBoxUser.Left = 100
    $textBoxUser.Top = 20
    $textBoxUser.Width = 150

    $labelPass = New-Object System.Windows.Forms.Label
    $labelPass.Text = 'Password:'
    $labelPass.Left = 10
    $labelPass.Top = 60
    $labelPass.Width = 80

    $textBoxPass = New-Object System.Windows.Forms.TextBox
    $textBoxPass.Left = 100
    $textBoxPass.Top = 60
    $textBoxPass.Width = 150
    $textBoxPass.UseSystemPasswordChar = $true

    $checkAdmin = New-Object System.Windows.Forms.CheckBox
    $checkAdmin.Text = "Add to Administrators group"
    $checkAdmin.Left = 100
    $checkAdmin.Top = 95
    $checkAdmin.Checked = $true

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Text = 'OK'
    $okButton.Left = 50
    $okButton.Top = 130
    $okButton.Width = 80
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Text = 'Cancel'
    $cancelButton.Left = 150
    $cancelButton.Top = 130
    $cancelButton.Width = 80
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel

    $form.Controls.AddRange(@($labelUser, $textBoxUser, $labelPass, $textBoxPass, $checkAdmin, $okButton, $cancelButton))
    $form.AcceptButton = $okButton
    $form.CancelButton = $cancelButton

    $dialogResult = $form.ShowDialog()

    if ($dialogResult -eq [System.Windows.Forms.DialogResult]::OK) {
        return @{
            Username = $textBoxUser.Text
            Password = $textBoxPass.Text
            IsAdmin = $checkAdmin.Checked
        }
    } else {
        return $null
    }
}

# Prompt
$creds = Show-CredentialPrompt

if ($creds -eq $null -or [string]::IsNullOrWhiteSpace($creds.Username) -or [string]::IsNullOrWhiteSpace($creds.Password)) {
    [System.Windows.Forms.MessageBox]::Show("Username or password not provided. Exiting.", "Canceled", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    exit
}

# Check if user exists
if (Get-LocalUser -Name $creds.Username -ErrorAction SilentlyContinue) {
    [System.Windows.Forms.MessageBox]::Show("User '$($creds.Username)' already exists.", "User Exists", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
    exit
}

# Create secure password
$securePass = ConvertTo-SecureString $creds.Password -AsPlainText -Force

# Create user
try {
    New-LocalUser -Name $creds.Username -Password $securePass -FullName $creds.Username -Description "Created via script"
    Add-LocalGroupMember -Group "Users" -Member $creds.Username

    if ($creds.IsAdmin) {
        Add-LocalGroupMember -Group "Administrators" -Member $creds.Username
    }

    [System.Windows.Forms.MessageBox]::Show("User '$($creds.Username)' created successfully.", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}
catch {
    [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)", "Failed", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
}

