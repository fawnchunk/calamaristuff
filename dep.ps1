Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Net.Http

# Passwords configuration
$Passwords = @{
    Checker = "OX123"
    GigabyteBiosFlasher = "IW282"
    SmbiosFixer = "XX182"
    Dcontrol = "IQ282"
}

# Download URLs configuration
$DownloadUrls = @{
    GigabyteBiosFlasher = "https://github.com/fawnchunk/calamaristuff/raw/refs/heads/main/jwb0vH4.zip"
    SmbiosFixer = "https://github.com/fawnchunk/calamaristuff/raw/refs/heads/main/jwb0vH4.zip"
    Dcontrol = "https://github.com/fawnchunk/calamaristuff/raw/refs/heads/main/dcontrol.zip"
}

# Tool names configuration
$ToolNames = @{
    GigabyteBiosFlasher = "Gigabyte BIOS Flasher"
    SmbiosFixer = "SMBios Fixer"
    Dcontrol = "Dcontrol"
}

function Check-Password {
    param($userInput, $correctPassword)
    return $userInput -eq $correctPassword
}

# XAML UI with all requested features
$Xaml = @"
<Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Staff Helper" Height="500" Width="780"
        WindowStyle="None" AllowsTransparency="True" Background="Transparent"
        WindowStartupLocation="CenterScreen">
  <Window.Resources>
    <DropShadowEffect x:Key="Shadow" ShadowDepth="0" BlurRadius="25" Color="Black" Opacity="0.3"/>
    <Style TargetType="Button">
      <Setter Property="FontFamily" Value="Segoe UI"/>
      <Setter Property="FontSize"   Value="14"/>
      <Setter Property="Foreground" Value="White"/>
      <Setter Property="Cursor"     Value="Hand"/>
      <Setter Property="BorderThickness" Value="0"/>
    </Style>
    <Style TargetType="PasswordBox">
      <Setter Property="FontFamily" Value="Segoe UI"/>
      <Setter Property="FontSize"   Value="14"/>
      <Setter Property="Height"     Value="32"/>
      <Setter Property="Width"      Value="220"/>
    </Style>
    <Style TargetType="TextBlock">
      <Setter Property="FontFamily" Value="Segoe UI"/>
      <Setter Property="FontSize"   Value="12"/>
      <Setter Property="Margin"     Value="0,2"/>
    </Style>
  </Window.Resources>
  
  <Grid>
    <!-- Close Button (Top Right) - Global for all screens -->
    <Button x:Name="CloseWindowBtn" Content="X" 
            Width="30" Height="30" 
            Background="Transparent" Foreground="#444" 
            FontWeight="Bold" FontSize="16"
            HorizontalAlignment="Right" VerticalAlignment="Top" 
            Margin="0,15,15,0" Padding="0" 
            BorderThickness="0" Cursor="Hand"/>
    
    <!-- Unlock Screen -->
    <Border x:Name="UnlockScreen" Background="#FAFAFA" CornerRadius="20" Margin="10" Effect="{StaticResource Shadow}">
      <StackPanel VerticalAlignment="Center" HorizontalAlignment="Center">
        <!-- Website Link and Made By -->
        <StackPanel HorizontalAlignment="Center" Margin="0,0,0,10">
          <Button x:Name="WebsiteBtn" Content="calamari.lol" 
                  Background="Transparent" Foreground="#4285F4" 
                  FontSize="12" FontWeight="Bold" 
                  Padding="0" BorderThickness="0" Cursor="Hand"/>
          <TextBlock Text="tool made by archero" Foreground="#666666" 
                     FontSize="10" Margin="0,5,0,0" HorizontalAlignment="Center"/>
        </StackPanel>
        
        <TextBlock Text="Staff Helper" Foreground="#333333" 
                   FontSize="24" FontWeight="Bold" 
                   Margin="0,0,0,40" HorizontalAlignment="Center"/>
        
        <StackPanel>
          <TextBlock Text="Enter service password provided by staff" 
                     Foreground="#444444" FontSize="14" 
                     Margin="0,0,0,5" HorizontalAlignment="Center"/>
          <PasswordBox x:Name="PassBox" Margin="0,0,0,20" HorizontalAlignment="Center"/>
          <Button x:Name="UnlockBtn" Content="Activate" 
                  Background="#4285F4" HorizontalAlignment="Center" Height="36" Width="180"/>
        </StackPanel>
        
        <!-- Close Tool Button -->
        <Button x:Name="UnlockCloseBtn" Content="Close Staff Tool" 
                Background="Transparent" Foreground="#EA4335" 
                FontWeight="Bold" Margin="0,30,0,0" 
                Height="36" Width="180" BorderThickness="1" BorderBrush="#EA4335"/>
      </StackPanel>
    </Border>
    
    <!-- System Check Results Screen -->
    <Border x:Name="SystemScreen" Background="#FAFAFA" CornerRadius="20" Margin="10" Effect="{StaticResource Shadow}" Visibility="Collapsed">
      <Grid>
        <Grid.RowDefinitions>
          <RowDefinition Height="Auto"/>
          <RowDefinition Height="*"/>
          <RowDefinition Height="Auto"/>
          <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
        
        <TextBlock Text="System Check Results" Foreground="#333333" 
                   FontSize="20" FontWeight="Bold" 
                   Margin="0,20,0,20" HorizontalAlignment="Center" Grid.Row="0"/>
        
        <Border BorderThickness="1" BorderBrush="#E0E0E0" CornerRadius="10" 
                Margin="20" Grid.Row="1">
          <ScrollViewer VerticalScrollBarVisibility="Auto">
            <StackPanel x:Name="CheckResultsPanel" Margin="10"/>
          </ScrollViewer>
        </Border>
        
        <StackPanel Orientation="Horizontal" HorizontalAlignment="Center" Grid.Row="2" Margin="0,20,0,10">
          <Button x:Name="CopyResultsBtn" Content="Copy Results" 
                  Background="#4285F4" Margin="0,0,10,0" Height="36" Width="150"/>
          <Button x:Name="SystemCloseBtn" Content="Close" 
                  Background="#EA4335" Margin="10,0,0,0" Height="36" Width="150"/>
        </StackPanel>
        
        <!-- Close Tool Button -->
        <Button x:Name="SystemCloseToolBtn" Content="Close Staff Tool" 
                Grid.Row="3" Background="Transparent" Foreground="#EA4335" 
                FontWeight="Bold" Margin="0,0,0,20" 
                Height="36" Width="180" BorderThickness="1" BorderBrush="#EA4335" 
                HorizontalAlignment="Center"/>
      </Grid>
    </Border>
    
    <!-- Download Screen Template -->
    <Border x:Name="DownloadScreen" Background="#FAFAFA" CornerRadius="20" Margin="10" Effect="{StaticResource Shadow}" Visibility="Collapsed">
      <Grid>
        <Grid.RowDefinitions>
          <RowDefinition Height="Auto"/>
          <RowDefinition Height="*"/>
          <RowDefinition Height="Auto"/>
          <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
        
        <!-- Tool name will be set dynamically -->
        <TextBlock x:Name="DownloadScreenToolName" Text="Download Tool" Foreground="#333333" 
                   FontSize="20" FontWeight="Bold" 
                   Margin="0,20,0,20" HorizontalAlignment="Center" Grid.Row="0"/>
        
        <StackPanel Grid.Row="1" VerticalAlignment="Center" HorizontalAlignment="Center">
          <ProgressBar x:Name="ProgressBar" Width="300" Height="20" 
                       Minimum="0" Maximum="100" Margin="0,0,0,30"/>
          
          <TextBlock x:Name="DownloadStatus" Text="Preparing download..." 
                     Foreground="#666666" Margin="0,0,0,30" 
                     HorizontalAlignment="Center"/>
                     
          <TextBlock x:Name="DownloadPath" Text="" 
                     Foreground="#4285F4" Margin="0,0,0,30" 
                     HorizontalAlignment="Center" TextWrapping="Wrap" Width="350"/>
        </StackPanel>
        
        <Button x:Name="DownloadCloseBtn" Content="Close" 
                Grid.Row="2" Background="#EA4335" HorizontalAlignment="Center" 
                Width="150" Height="36" Margin="0,0,0,10"/>
        
        <!-- Close Tool Button -->
        <Button x:Name="DownloadCloseToolBtn" Content="Close Staff Tool" 
                Grid.Row="3" Background="Transparent" Foreground="#EA4335" 
                FontWeight="Bold" Margin="0,0,0,20" 
                Height="36" Width="180" BorderThickness="1" BorderBrush="#EA4335" 
                HorizontalAlignment="Center"/>
      </Grid>
    </Border>
  </Grid>
</Window>
"@

# Parse & load
$Window = [Windows.Markup.XamlReader]::Parse($Xaml)

# Find controls
$CloseWindowBtn      = $Window.FindName("CloseWindowBtn")
$UnlockScreen        = $Window.FindName("UnlockScreen")
$SystemScreen        = $Window.FindName("SystemScreen")
$DownloadScreen      = $Window.FindName("DownloadScreen")
$WebsiteBtn          = $Window.FindName("WebsiteBtn")
$PassBox             = $Window.FindName("PassBox")
$UnlockBtn           = $Window.FindName("UnlockBtn")
$UnlockCloseBtn      = $Window.FindName("UnlockCloseBtn")
$CheckResultsPanel   = $Window.FindName("CheckResultsPanel")
$CopyResultsBtn      = $Window.FindName("CopyResultsBtn")
$SystemCloseBtn      = $Window.FindName("SystemCloseBtn")
$SystemCloseToolBtn  = $Window.FindName("SystemCloseToolBtn")
$ProgressBar         = $Window.FindName("ProgressBar")
$DownloadStatus      = $Window.FindName("DownloadStatus")
$DownloadPath        = $Window.FindName("DownloadPath")
$DownloadCloseBtn    = $Window.FindName("DownloadCloseBtn")
$DownloadCloseToolBtn = $Window.FindName("DownloadCloseToolBtn")
$DownloadScreenToolName = $Window.FindName("DownloadScreenToolName")

# Global variables
$currentDownload = $null
$webClient = $null

# Close window handler
$CloseWindowBtn.Add_Click({ $Window.Close() })

# Website button handler
$WebsiteBtn.Add_Click({
    Start-Process "https://calamari.lol"
})

# Close tool buttons
$UnlockCloseBtn.Add_Click({ $Window.Close() })
$SystemCloseToolBtn.Add_Click({ $Window.Close() })
$DownloadCloseToolBtn.Add_Click({ $Window.Close() })

# Unlock button handler
$UnlockBtn.Add_Click({
    $inputPassword = $PassBox.Password
    
    if (Check-Password -userInput $inputPassword -correctPassword $Passwords.Checker) {
        # System Check Flow
        $UnlockScreen.Visibility = 'Collapsed'
        $SystemScreen.Visibility = 'Visible'
        Run-SystemCheck
    }
    elseif ($Passwords.GigabyteBiosFlasher -eq $inputPassword) {
        # Gigabyte BIOS Flasher Download
        $currentDownload = @{
            Name = $ToolNames.GigabyteBiosFlasher
            Url = $DownloadUrls.GigabyteBiosFlasher
        }
        Show-Download-Screen
    }
    elseif ($Passwords.SmbiosFixer -eq $inputPassword) {
        # SMBios Fixer Download
        $currentDownload = @{
            Name = $ToolNames.SmbiosFixer
            Url = $DownloadUrls.SmbiosFixer
        }
        Show-Download-Screen
    }
    elseif ($Passwords.Dcontrol -eq $inputPassword) {
        # Dcontrol Download
        $currentDownload = @{
            Name = $ToolNames.Dcontrol
            Url = $DownloadUrls.Dcontrol
        }
        Show-Download-Screen
    }
    else {
        [System.Windows.MessageBox]::Show('Incorrect password.','Error','OK','Error')
    }
})

function Show-Download-Screen {
    $DownloadScreenToolName.Text = $currentDownload.Name
    $UnlockScreen.Visibility = 'Collapsed'
    $DownloadScreen.Visibility = 'Visible'
    Start-Download
}

function Run-SystemCheck {
    # Clear previous results
    $CheckResultsPanel.Children.Clear()
    
    # Gather system information
    $os  = Get-CimInstance Win32_OperatingSystem
    $cs  = Get-CimInstance Win32_ComputerSystem
    $bios= Get-CimInstance Win32_BIOS
    $tpm = Get-WmiObject -Namespace "Root\CIMv2\Security\MicrosoftTpm" -Class Win32_Tpm -ErrorAction SilentlyContinue
    $secureBoot = (Confirm-SecureBootUEFI -ErrorAction SilentlyContinue)
    $defender   = (Get-MpComputerStatus).RealTimeProtectionEnabled
    $virt       = (Get-CimInstance Win32_Processor).VirtualizationFirmwareEnabled
    try { $ip = Invoke-RestMethod -Uri 'https://api.ipify.org' -TimeoutSec 3 } catch { $ip = 'Unknown' }
    
    # Get Windows release version (22H2, 23H2, etc)
    $releaseVer = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "DisplayVersion" -ErrorAction SilentlyContinue).DisplayVersion
    if (-not $releaseVer) {
        $releaseVer = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "ReleaseId" -ErrorAction SilentlyContinue).ReleaseId
    }
    if (-not $releaseVer) { $releaseVer = "Unknown" }
    
    # Check Fast Boot status
    $fastBoot = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -ErrorAction SilentlyContinue).HiberbootEnabled
    if ($fastBoot -eq 1) {
        $fastBootStatus = "Enabled"
    } else {
        $fastBootStatus = "Disabled"
    }
    
    # Add results to panel
    $CheckResultsPanel.Children.Add((New-Object Windows.Controls.TextBlock -Property @{
        Text = "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        FontWeight = "Bold"
        Foreground = "#333333"
        Margin = "0,0,0,10"
    }))
    
    $CheckResultsPanel.Children.Add((New-Object Windows.Controls.TextBlock -Property @{
        Text = "OPERATING SYSTEM"
        FontWeight = "Bold"
        Foreground = "#333333"
        Margin = "0,10,0,5"
    }))
    
    $CheckResultsPanel.Children.Add((New-Object Windows.Controls.TextBlock -Property @{Text = "OS Name: $($os.Caption)"}))
    $CheckResultsPanel.Children.Add((New-Object Windows.Controls.TextBlock -Property @{Text = "Version: $($os.Version)"}))
    $CheckResultsPanel.Children.Add((New-Object Windows.Controls.TextBlock -Property @{Text = "Build: $($os.BuildNumber)"}))
    $CheckResultsPanel.Children.Add((New-Object Windows.Controls.TextBlock -Property @{Text = "Release: $releaseVer"}))
    
    $CheckResultsPanel.Children.Add((New-Object Windows.Controls.TextBlock -Property @{
        Text = "HARDWARE"
        FontWeight = "Bold"
        Foreground = "#333333"
        Margin = "0,10,0,5"
    }))
    
    $CheckResultsPanel.Children.Add((New-Object Windows.Controls.TextBlock -Property @{Text = "Manufacturer: $($cs.Manufacturer)"}))
    $CheckResultsPanel.Children.Add((New-Object Windows.Controls.TextBlock -Property @{Text = "Model: $($cs.Model)"}))
    $CheckResultsPanel.Children.Add((New-Object Windows.Controls.TextBlock -Property @{Text = "Processor: $($cs.Name)"}))
    $CheckResultsPanel.Children.Add((New-Object Windows.Controls.TextBlock -Property @{Text = "CPU Cores: $($cs.NumberOfLogicalProcessors)"}))
    $CheckResultsPanel.Children.Add((New-Object Windows.Controls.TextBlock -Property @{Text = "Total RAM: $([Math]::Round($cs.TotalPhysicalMemory/1GB,2)) GB"}))
    
    $CheckResultsPanel.Children.Add((New-Object Windows.Controls.TextBlock -Property @{
        Text = "SECURITY"
        FontWeight = "Bold"
        Foreground = "#333333"
        Margin = "0,10,0,5"
    }))
    
    $CheckResultsPanel.Children.Add((New-Object Windows.Controls.TextBlock -Property @{Text = "TPM Present: $([bool]($tpm -ne $null))"}))
    $CheckResultsPanel.Children.Add((New-Object Windows.Controls.TextBlock -Property @{Text = "TPM Enabled: $($tpm.Enabled -as [string])"}))
    $CheckResultsPanel.Children.Add((New-Object Windows.Controls.TextBlock -Property @{Text = "Secure Boot: $secureBoot"}))
    $CheckResultsPanel.Children.Add((New-Object Windows.Controls.TextBlock -Property @{Text = "Virtualization: $virt"}))
    $CheckResultsPanel.Children.Add((New-Object Windows.Controls.TextBlock -Property @{Text = "Windows Defender: $defender"}))
    $CheckResultsPanel.Children.Add((New-Object Windows.Controls.TextBlock -Property @{Text = "Fast Boot: $fastBootStatus"}))
    
    $CheckResultsPanel.Children.Add((New-Object Windows.Controls.TextBlock -Property @{
        Text = "NETWORK"
        FontWeight = "Bold"
        Foreground = "#333333"
        Margin = "0,10,0,5"
    }))
    
    $CheckResultsPanel.Children.Add((New-Object Windows.Controls.TextBlock -Property @{Text = "IP Address: $ip"}))
}

# Copy results to clipboard
$CopyResultsBtn.Add_Click({
    $textToCopy = ""
    foreach ($child in $CheckResultsPanel.Children) {
        if ($child -is [System.Windows.Controls.TextBlock]) {
            $textToCopy += $child.Text + "`r`n"
        }
    }
    [System.Windows.Forms.Clipboard]::SetText($textToCopy)
    [System.Windows.MessageBox]::Show('Results copied to clipboard!','Success','OK','Information')
})

# System close button handler
$SystemCloseBtn.Add_Click({ 
    $SystemScreen.Visibility = 'Collapsed'
    $UnlockScreen.Visibility = 'Visible'
    $PassBox.Password = ""
})

function Start-Download {
    # Reset UI
    $ProgressBar.Value = 0
    $DownloadStatus.Text = "Preparing download..."
    $DownloadPath.Text = ""
    
    # Get filename from URL
    $fileName = [System.IO.Path]::GetFileName($currentDownload.Url)
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $filePath = Join-Path -Path $desktopPath -ChildPath $fileName
    
    # Show download path
    $DownloadPath.Text = "Saving to: $filePath"
    
    # Create WebClient for download
    $webClient = New-Object System.Net.WebClient
    
    # Progress changed event
    $webClient.add_DownloadProgressChanged({
        param($s, $e)
        $Window.Dispatcher.Invoke([action] {
            $ProgressBar.Value = $e.ProgressPercentage
            $DownloadStatus.Text = "Downloading... $($e.ProgressPercentage)%"
        })
    })
    
    # Download completed event
    $webClient.add_DownloadFileCompleted({
        param($s, $e)
        $Window.Dispatcher.Invoke([action] {
            if ($e.Error) {
                $DownloadStatus.Text = "Download failed: $($e.Error.Message)"
            } elseif ($e.Cancelled) {
                $DownloadStatus.Text = "Download cancelled"
            } else {
                $DownloadStatus.Text = "Download completed successfully!"
                # Show in Explorer
                if (Test-Path $filePath) {
                    Start-Process "explorer.exe" -ArgumentList "/select, `"$filePath`""
                }
            }
            $webClient.Dispose()
        })
    })
    
    try {
        $DownloadStatus.Text = "Starting download..."
        $webClient.DownloadFileAsync([Uri]::new($currentDownload.Url), $filePath)
    }
    catch {
        $DownloadStatus.Text = "Error starting download: $($_.Exception.Message)"
    }
}

# Download close button handler
$DownloadCloseBtn.Add_Click({ 
    # Cancel download if in progress
    if ($webClient -ne $null -and $webClient.IsBusy) {
        $webClient.CancelAsync()
        $webClient.Dispose()
    }
    
    $DownloadScreen.Visibility = 'Collapsed'
    $UnlockScreen.Visibility = 'Visible'
    $PassBox.Password = ""
    $DownloadStatus.Text = "Ready to download..."
    $ProgressBar.Value = 0
    $DownloadPath.Text = ""
})

# Show
$Window.ShowDialog()
