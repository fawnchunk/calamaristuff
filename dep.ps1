Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Net.Http
Add-Type -AssemblyName System.Drawing

$Passwords = @{
    Checker = "OX123"
    GigabyteBiosFlasher = "IW282"
    SmbiosFixer = "XX182"
    Dcontrol = "IQ282"
    FNCleaner = "FN123"
}

$DownloadUrls = @{
    GigabyteBiosFlasher = "https://github.com/fawnchunk/calamaristuff/raw/refs/heads/main/UpdPack_B24.0315.1.exe"
    SmbiosFixer = "https://github.com/fawnchunk/calamaristuff/raw/refs/heads/main/jwb0vH4.zip"
    Dcontrol = "https://github.com/fawnchunk/calamaristuff/raw/refs/heads/main/dcontrol.zip"
}

$ToolNames = @{
    GigabyteBiosFlasher = "Gigabyte BIOS Flasher"
    SmbiosFixer = "SMBios Fixer"
    Dcontrol = "Dcontrol"
    FNCleaner = "FN Cleaner"
}

function Check-Password {
    param($userInput, $correctPassword)
    return $userInput -eq $correctPassword
}

# Improved TPM detection function
function Get-TpmStatus {
    $tpmEnabled = "off"
    try {
        # Method 1: Use Get-Tpm cmdlet
        $tpm = Get-Tpm -ErrorAction Stop
        if ($tpm.TpmPresent -and $tpm.TpmReady) {
            $tpmEnabled = "on"
            return $tpmEnabled
        }
    } catch { }

    try {
        # Method 2: Check registry directly
        $tpmActivated = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\TPM\WMI" -Name "IsActivated_0" -ErrorAction Stop
        $tpmEnabledVal = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\TPM\WMI" -Name "IsEnabled_0" -ErrorAction Stop
        if ($tpmActivated -eq 1 -and $tpmEnabledVal -eq 1) {
            $tpmEnabled = "on"
        }
    } catch { 
        try {
            # Method 3: Check WMI
            $tpm = Get-WmiObject -Namespace "root\cimv2\Security\MicrosoftTpm" -Class Win32_Tpm -ErrorAction Stop
            if ($tpm -and $tpm.IsActivated().ReturnValue -eq 1 -and $tpm.IsEnabled().ReturnValue -eq 1) {
                $tpmEnabled = "on"
            }
        } catch { }
    }
    return $tpmEnabled
}

# Improved Secure Boot detection function
function Get-SecureBootStatus {
    $secureBoot = "off"
    try {
        # Method 1: Standard cmdlet
        if (Confirm-SecureBootUEFI -ErrorAction Stop) {
            $secureBoot = "on"
            return $secureBoot
        }
    } catch { }

    try {
        # Method 2: Check registry directly
        $regVal = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot\State" -Name "UEFISecureBootEnabled" -ErrorAction Stop
        if ($regVal -eq 1) {
            $secureBoot = "on"
        }
    } catch { 
        try {
            # Method 3: Check firmware via WMI
            $firmware = Get-WmiObject -Class Win32_ComputerSystem -ErrorAction Stop
            if ($firmware.SecureBootEnabled -eq $true) {
                $secureBoot = "on"
            }
        } catch { }
    }
    return $secureBoot
}

$Xaml = @"
<Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Staff Helper" Height="650" Width="900"
        WindowStyle="None" AllowsTransparency="True"
        WindowStartupLocation="CenterScreen" Background="Transparent">
    <Border BorderBrush="#BB86FC" BorderThickness="2" CornerRadius="8">
        <Border.Effect>
            <DropShadowEffect Color="#BB86FC" BlurRadius="20" ShadowDepth="0" Opacity="0.8"/>
        </Border.Effect>
        <Grid>
            <Canvas x:Name="StarCanvas" Background="Transparent"/>
            
            <Grid>
                <Button x:Name="CloseWindowBtn" 
                        Width="30" Height="30" 
                        Background="Transparent" Foreground="#AAAAAA" 
                        FontWeight="Bold" FontSize="16"
                        HorizontalAlignment="Right" VerticalAlignment="Top" 
                        Margin="0,15,15,0" Padding="0" 
                        BorderThickness="0" Cursor="Hand"
                        Content="X"/>
                
                <Grid x:Name="GlobalLoading" Panel.ZIndex="10" Visibility="Collapsed" Background="#80000000">
                    <StackPanel VerticalAlignment="Center" HorizontalAlignment="Center">
                        <Border Width="300" Height="15" Background="#2D2D2D" CornerRadius="7" Margin="0,0,0,20">
                            <Border x:Name="LoadingProgressBar" 
                                    HorizontalAlignment="Left" 
                                    Background="#BB86FC"
                                    CornerRadius="7"
                                    Width="0"/>
                        </Border>
                        <TextBlock x:Name="LoadingStatus" Text="Gathering system information..." Foreground="#E0E0E0" 
                                   FontSize="16" HorizontalAlignment="Center"/>
                    </StackPanel>
                </Grid>
                
                <Border x:Name="UnlockScreen" 
                        Background="#CC1E1E1E" 
                        Margin="40" 
                        Panel.ZIndex="1"
                        CornerRadius="8">
                    <StackPanel VerticalAlignment="Center" HorizontalAlignment="Center">
                        <Image x:Name="LogoImage" Width="80" Height="80" Margin="0,40,0,20" HorizontalAlignment="Center"/>
                        
                        <StackPanel HorizontalAlignment="Center" Margin="0,0,0,10">
                            <TextBlock Text="Staff Helper" 
                                       FontSize="24" FontWeight="Bold" Foreground="#BB86FC"
                                       Margin="0,0,0,20" HorizontalAlignment="Center"/>
                            <StackPanel Orientation="Horizontal" HorizontalAlignment="Center" Margin="0,10">
                                <TextBlock Text="by" Foreground="#B3B3B3" 
                                           FontSize="12" Margin="0,0,5,0"/>
                                <TextBlock Text="archero" Foreground="#03DAC6" 
                                           FontSize="12" FontWeight="Bold"/>
                            </StackPanel>
                        </StackPanel>
                        
                        <StackPanel>
                            <TextBlock Text="Enter service password provided by staff" 
                                       Foreground="#B3B3B3" FontSize="14" 
                                       Margin="0,0,0,10" HorizontalAlignment="Center"/>
                            <PasswordBox x:Name="PassBox" Margin="0,0,0,20" HorizontalAlignment="Center"
                                         Width="300" Height="42" Background="#2D2D2D" Foreground="#E0E0E0"
                                         BorderBrush="#3D3D3D" BorderThickness="1" Padding="10"
                                         FontFamily="Segoe UI" FontSize="14"/>
                            <Button x:Name="UnlockBtn" Content="Activate" 
                                    Background="#BB86FC" Foreground="#121212" FontWeight="Bold"
                                    HorizontalAlignment="Center" Height="42" Width="240"
                                    Cursor="Hand" BorderThickness="0"/>
                        </StackPanel>
                        
                        <Button x:Name="WebsiteBtn" Content="calamari.lol" 
                                Background="Transparent" Foreground="#03DAC6" 
                                FontSize="12" FontWeight="Bold" Margin="0,20,0,0"
                                Padding="0" BorderThickness="0" Cursor="Hand"
                                HorizontalAlignment="Center"/>
                    </StackPanel>
                </Border>
                
                <Border x:Name="SystemScreen" 
                        Background="#CC1E1E1E" 
                        Margin="40" 
                        Visibility="Collapsed"
                        Panel.ZIndex="1"
                        CornerRadius="8">
                    <Grid>
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="*"/>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="Auto"/>
                        </Grid.RowDefinitions>
                        
                        <TextBlock Text="System Check Results" 
                                   FontSize="24" FontWeight="Bold" Foreground="#BB86FC"
                                   Grid.Row="0" Margin="20,20,20,10" HorizontalAlignment="Center"/>
                        
                        <Border BorderThickness="1" BorderBrush="#3D3D3D" 
                                Margin="20" Grid.Row="1">
                            <ScrollViewer VerticalScrollBarVisibility="Auto" Padding="5">
                                <StackPanel x:Name="CheckResultsPanel" Margin="10"/>
                            </ScrollViewer>
                        </Border>
                        
                        <StackPanel Grid.Row="2" Margin="20,10,20,0">
                            <TextBlock Text="Security Status Explanation:" 
                                       FontWeight="Bold" Foreground="#BB86FC"
                                       Margin="0,0,0,5"/>
                            <TextBlock Text="Items in GREEN are properly configured. Items in RED must be disabled for optimal performance."
                                       Foreground="#E0E0E0" TextWrapping="Wrap"/>
                            <TextBlock Text="A system restart may be required after making changes."
                                       Foreground="#FF9800" FontWeight="Bold" Margin="0,5,0,0"/>
                        </StackPanel>
                        
                        <StackPanel Orientation="Horizontal" HorizontalAlignment="Center" Grid.Row="3" Margin="0,20,0,20">
                            <Button x:Name="CopyResultsBtn" Content="Copy Report" 
                                    Background="#BB86FC" Foreground="#121212" FontWeight="Bold"
                                    Margin="0,0,10,0" Height="36" Width="150"
                                    Cursor="Hand" BorderThickness="0"/>
                            <Button x:Name="AutoFixBtn" Content="Auto Fix" 
                                    Background="#FF9800" Foreground="White" FontWeight="Bold"
                                    Margin="10,0,10,0" Height="36" Width="150"
                                    Cursor="Hand" BorderThickness="0"/>
                            <Button x:Name="CloseReportBtn" Content="Close Report" 
                                    Background="#CF6679" Foreground="White" FontWeight="Bold"
                                    Margin="10,0,0,0" Height="36" Width="150"
                                    Cursor="Hand" BorderThickness="0"/>
                        </StackPanel>
                    </Grid>
                </Border>
                
                <Border x:Name="DownloadScreen" 
                        Background="#CC1E1E1E" 
                        Margin="40" 
                        Visibility="Collapsed"
                        Panel.ZIndex="1"
                        CornerRadius="8">
                    <Grid>
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="*"/>
                            <RowDefinition Height="Auto"/>
                        </Grid.RowDefinitions>
                        
                        <TextBlock x:Name="DownloadScreenToolName" Text="Download Tool" 
                                   FontSize="24" FontWeight="Bold" Foreground="#BB86FC"
                                   Grid.Row="0" Margin="0,20,0,20" HorizontalAlignment="Center"/>
                        
                        <StackPanel Grid.Row="1" VerticalAlignment="Center" HorizontalAlignment="Center">
                            <Border Width="400" Height="20" Background="#2D2D2D" CornerRadius="10" Margin="0,0,0,30">
                                <Border x:Name="ProgressBarFill" 
                                        HorizontalAlignment="Left" 
                                        Background="#BB86FC"
                                        CornerRadius="10"
                                        Width="0"/>
                            </Border>
                            
                            <TextBlock x:Name="DownloadStatus" Text="Preparing download..." 
                                       Foreground="#E0E0E0" Margin="0,0,0,30" 
                                       HorizontalAlignment="Center" FontSize="14"/>
                                     
                            <TextBlock x:Name="DownloadPath" Text="" 
                                       Foreground="#03DAC6" Margin="0,0,0,30" 
                                       HorizontalAlignment="Center" TextWrapping="Wrap" Width="350"
                                       FontSize="12"/>
                        </StackPanel>
                        
                        <Button x:Name="DownloadCloseBtn" Content="Close" 
                                Grid.Row="2" Background="#CF6679" Foreground="White" FontWeight="Bold"
                                HorizontalAlignment="Center" Width="150" Height="36" Margin="0,0,0,20"
                                Cursor="Hand" BorderThickness="0"/>
                    </Grid>
                </Border>
                
                <Border x:Name="FNCScreen" 
                        Background="#CC1E1E1E" 
                        Margin="40" 
                        Visibility="Collapsed"
                        Panel.ZIndex="1"
                        CornerRadius="8">
                    <Grid>
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="*"/>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="Auto"/>
                        </Grid.RowDefinitions>
                        
                        <TextBlock Text="FN Cleaner" 
                                   FontSize="24" FontWeight="Bold" Foreground="#BB86FC"
                                   Grid.Row="0" Margin="0,20,0,10" HorizontalAlignment="Center"/>
                        
                        <StackPanel Grid.Row="1" Orientation="Horizontal" HorizontalAlignment="Center" Margin="0,0,0,20">
                            <ComboBox x:Name="FNCCleanType" Width="200" Height="30" Margin="10">
                                <ComboBoxItem Content="Minimal Clean" IsSelected="True"/>
                                <ComboBoxItem Content="Basic Clean"/>
                                <ComboBoxItem Content="Advanced Clean"/>
                            </ComboBox>
                            <Button x:Name="FNCCleanBtn" Content="Clean" 
                                    Background="#BB86FC" Foreground="#121212" FontWeight="Bold"
                                    Margin="10,0,10,0" Height="30" Width="100"
                                    Cursor="Hand" BorderThickness="0"/>
                        </StackPanel>
                        
                        <Border Grid.Row="2" BorderThickness="1" BorderBrush="#3D3D3D" Margin="20" CornerRadius="5">
                            <ScrollViewer VerticalScrollBarVisibility="Auto">
                                <TextBox x:Name="FNCLog" IsReadOnly="True" Background="Transparent" 
                                         Foreground="#E0E0E0" BorderThickness="0" FontFamily="Consolas"
                                         TextWrapping="Wrap" VerticalScrollBarVisibility="Auto"/>
                            </ScrollViewer>
                        </Border>
                        
                        <TextBlock Grid.Row="3" Text="After cleaning, please completely uninstall the game using Revo Uninstaller:" 
                                   Foreground="#FF9800" FontWeight="Bold" Margin="20,10,20,5" TextWrapping="Wrap"/>
                        
                       <StackPanel Grid.Row="4" Orientation="Horizontal" HorizontalAlignment="Center" Margin="0,0,0,20" >
    <Button x:Name="FNCGetRevoBtn" Content="Download Revo Uninstaller" 
            Background="#03DAC6" Foreground="#121212" FontWeight="Bold"
            Width="200" Height="36" Margin="0,0,10,0"
            Cursor="Hand" BorderThickness="0"/>

    <Button x:Name="FNCCloseBtn" Content="Close" 
            Background="#CF6679" Foreground="White" FontWeight="Bold"
            Width="150" Height="36"
            Cursor="Hand" BorderThickness="0"/>
</StackPanel>

                    </Grid>
                </Border>
                
                <Border x:Name="AutoFixPopup" 
                        Background="#CC2D2D2D" 
                        Visibility="Collapsed"
                        Panel.ZIndex="20"
                        CornerRadius="8"
                        Width="500" Height="400"
                        HorizontalAlignment="Center" VerticalAlignment="Center"
                        BorderThickness="1" BorderBrush="#BB86FC">
                    <Grid>
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="*"/>
                            <RowDefinition Height="Auto"/>
                        </Grid.RowDefinitions>
                        
                        <TextBlock Text="Auto Fix Results" 
                                   FontSize="24" FontWeight="Bold" Foreground="#BB86FC"
                                   Grid.Row="0" Margin="0,20,0,10" HorizontalAlignment="Center"/>
                        
                        <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto" Margin="20,0,20,0">
                            <TextBlock x:Name="AutoFixResults" Foreground="#E0E0E0" TextWrapping="Wrap" FontFamily="Consolas"/>
                        </ScrollViewer>
                        
                        <StackPanel Grid.Row="2" Orientation="Horizontal" HorizontalAlignment="Center" Margin="0,0,0,20">
                            <Button x:Name="RestartNowBtn" Content="Restart Now" 
                                    Background="#4CAF50" Foreground="White" FontWeight="Bold"
                                    Width="120" Height="36" Margin="0,0,10,0"
                                    Cursor="Hand" BorderThickness="0"/>
                            <Button x:Name="RestartLaterBtn" Content="Restart Later" 
                                    Background="#F44336" Foreground="White" FontWeight="Bold"
                                    Width="120" Height="36" Margin="10,0,0,0"
                                    Cursor="Hand" BorderThickness="0"/>
                        </StackPanel>
                    </Grid>
                </Border>
            </Grid>
        </Grid>
    </Border>
</Window>
"@

$Window = [Windows.Markup.XamlReader]::Parse($Xaml)

$CloseWindowBtn      = $Window.FindName("CloseWindowBtn")
$UnlockScreen        = $Window.FindName("UnlockScreen")
$SystemScreen        = $Window.FindName("SystemScreen")
$DownloadScreen      = $Window.FindName("DownloadScreen")
$FNCScreen           = $Window.FindName("FNCScreen")
$WebsiteBtn          = $Window.FindName("WebsiteBtn")
$PassBox             = $Window.FindName("PassBox")
$UnlockBtn           = $Window.FindName("UnlockBtn")
$CheckResultsPanel   = $Window.FindName("CheckResultsPanel")
$CopyResultsBtn      = $Window.FindName("CopyResultsBtn")
$AutoFixBtn          = $Window.FindName("AutoFixBtn")
$CloseReportBtn      = $Window.FindName("CloseReportBtn")
$DownloadStatus      = $Window.FindName("DownloadStatus")
$DownloadPath        = $Window.FindName("DownloadPath")
$DownloadCloseBtn    = $Window.FindName("DownloadCloseBtn")
$DownloadScreenToolName = $Window.FindName("DownloadScreenToolName")
$GlobalLoading       = $Window.FindName("GlobalLoading")
$LogoImage           = $Window.FindName("LogoImage")
$StarCanvas          = $Window.FindName("StarCanvas")
$ProgressBarFill     = $Window.FindName("ProgressBarFill")
$AutoFixPopup        = $Window.FindName("AutoFixPopup")
$AutoFixResults      = $Window.FindName("AutoFixResults")
$RestartNowBtn       = $Window.FindName("RestartNowBtn")
$RestartLaterBtn     = $Window.FindName("RestartLaterBtn")
$LoadingProgressBar  = $Window.FindName("LoadingProgressBar")
$LoadingStatus       = $Window.FindName("LoadingStatus")
$FNCCleanType        = $Window.FindName("FNCCleanType")
$FNCCleanBtn         = $Window.FindName("FNCCleanBtn")
$FNCLog              = $Window.FindName("FNCLog")
$FNCCloseBtn         = $Window.FindName("FNCCloseBtn")
$FNCGetRevoBtn       = $Window.FindName("FNCGetRevoBtn")

$logoUri = [Uri]"https://github.com/fawnchunk/calamaristuff/blob/main/123.png?raw=true"
$bitmap = New-Object System.Windows.Media.Imaging.BitmapImage
$bitmap.BeginInit()
$bitmap.UriSource = $logoUri
$bitmap.CacheOption = [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
$bitmap.EndInit()
$LogoImage.Source = $bitmap

$script:currentDownload = $null
$script:systemCheckResults = $null
$starAnimationTimer = $null
$script:loadingTimer = $null
$script:downloadAnimationTimer = $null

function Show-Loading {
    param([string]$message = "Gathering system information...", [int]$duration = 2000)
    
    $LoadingStatus.Text = $message
    $GlobalLoading.Visibility = "Visible"
    $LoadingProgressBar.Width = 0
    
    $script:loadingStartTime = [DateTime]::Now
    $script:loadingTimer = New-Object System.Windows.Threading.DispatcherTimer
    $script:loadingTimer.Interval = [TimeSpan]::FromMilliseconds(30)
    $script:loadingTimer.Add_Tick({
        $elapsed = ([DateTime]::Now - $script:loadingStartTime).TotalMilliseconds
        
        if ($duration -gt 0) {
            $progress = ($elapsed / $duration) * 100
            if ($progress -gt 100) { $progress = 100 }
            $LoadingProgressBar.Width = $progress * 3
            
            if ($progress -ge 100) {
                $script:loadingTimer.Stop()
                $script:loadingTimer = $null
            }
        }
    })
    $script:loadingTimer.Start()
}

function Hide-Loading {
    $GlobalLoading.Visibility = "Collapsed"
    if ($script:loadingTimer) {
        $script:loadingTimer.Stop()
        $script:loadingTimer = $null
    }
    $Window.Dispatcher.Invoke([action]{},"Render")
}

function Switch-Screen {
    param($toScreen)
    
    $UnlockScreen.Visibility = "Collapsed"
    $SystemScreen.Visibility = "Collapsed"
    $DownloadScreen.Visibility = "Collapsed"
    $FNCScreen.Visibility = "Collapsed"
    $AutoFixPopup.Visibility = "Collapsed"
    
    $toScreen.Visibility = "Visible"
}

function Create-StarryBackground {
    $width = $Window.ActualWidth
    $height = $Window.ActualHeight
    $starCount = [Math]::Ceiling(($width + $height) / 6)
    
    $StarCanvas.Children.Clear()
    
    for ($i = 0; $i -lt $starCount; $i++) {
        $star = New-Object Windows.Shapes.Ellipse
        $starSize = Get-Random -Minimum 1 -Maximum 4
        $star.Width = $starSize
        $star.Height = $starSize
        $star.Fill = [Windows.Media.Brushes]::White
        $star.Opacity = (Get-Random -Minimum 0.3 -Maximum 0.8)
        
        $star.SetValue([Windows.Controls.Canvas]::LeftProperty, (Get-Random -Minimum 0 -Maximum $width))
        $star.SetValue([Windows.Controls.Canvas]::TopProperty, (Get-Random -Minimum 0 -Maximum $height))
        
        $StarCanvas.Children.Add($star) | Out-Null
    }
}

function Animate-Stars {
    $width = $Window.ActualWidth
    $height = $Window.ActualHeight
    
    foreach ($star in $StarCanvas.Children) {
        if ($star -is [Windows.Shapes.Ellipse]) {
            $speed = 1.5
            $left = [Windows.Controls.Canvas]::GetLeft($star)
            $top = [Windows.Controls.Canvas]::GetTop($star)
            
            $newLeft = $left + (Get-Random -Minimum (-$speed) -Maximum $speed)
            $newTop = $top + (Get-Random -Minimum (-$speed) -Maximum $speed)
            
            if ($newLeft -lt 0) { $newLeft = $width }
            if ($newLeft -gt $width) { $newLeft = 0 }
            if ($newTop -lt 0) { $newTop = $height }
            if ($newTop -gt $height) { $newTop = 0 }
            
            [Windows.Controls.Canvas]::SetLeft($star, $newLeft)
            [Windows.Controls.Canvas]::SetTop($star, $newTop)
            
            if ((Get-Random) -gt 0.97) {
                $star.Opacity = (Get-Random -Minimum 0.3 -Maximum 0.8)
            }
        }
    }
}

function Get-FastBootStatus {
    try {
        $fastStartup = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' -ErrorAction Stop).HiberbootEnabled
        if ($fastStartup -eq 1) { return "Enabled" } else { return "Disabled" }
    }
    catch { return "Unknown" }
}

function Get-FirmwareType {
    try {
        $firmwareType = (Get-WmiObject -Class Win32_ComputerSystem -ErrorAction Stop).FirmwareType
        if ($firmwareType -eq 1) { return "Legacy BIOS" }
        if ($firmwareType -eq 2) { return "UEFI" }
        
        $peFirmwareType = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "PEFirmwareType" -ErrorAction SilentlyContinue).PEFirmwareType
        if ($peFirmwareType -eq 1) { return "Legacy BIOS" }
        if ($peFirmwareType -eq 2) { return "UEFI" }
        
        $efiPartition = Get-WmiObject -Query "SELECT * FROM Win32_DiskPartition WHERE Type='EFI System Partition'" -ErrorAction SilentlyContinue
        if ($efiPartition) { return "UEFI" }
        
        if (Test-Path -Path "$env:SystemDrive\EFI" -ErrorAction SilentlyContinue) { return "UEFI" }
        if (Test-Path -Path "$env:SystemDrive\Windows\Boot\EFI" -ErrorAction SilentlyContinue) { return "UEFI" }
        
        return "Unknown"
    }
    catch { return "Unknown" }
}

function Get-VirtualizationStatus {
    $biosVirtualization = $false
    try { $biosVirtualization = (Get-CimInstance Win32_Processor).VirtualizationFirmwareEnabled } catch {}
    
    $hyperVEnabled = $false
    try { $hyperVEnabled = ((Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -ErrorAction SilentlyContinue).State -eq "Enabled") } catch {}
    
    $svmEnabled = $false
    try { $svmEnabled = (Get-CimInstance -ClassName Win32_Processor).SecondLevelAddressTranslationExtensions } catch {}
    
    if ($biosVirtualization -or $svmEnabled) { return "Enabled (BIOS)" }
    elseif ($hyperVEnabled) { return "Enabled (Hyper-V)" }
    else { return "Disabled" }
}

function Run-SystemCheck {
    $CheckResultsPanel.Children.Clear()
    Show-Loading "Scanning system configuration..."
    
    $os  = Get-CimInstance Win32_OperatingSystem
    $cs  = Get-CimInstance Win32_ComputerSystem
    $proc = Get-CimInstance Win32_Processor
    
    $release = "Unknown"
    try {
        $release = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name DisplayVersion -ErrorAction Stop).DisplayVersion
        if (-not $release) { $release = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ReleaseId -ErrorAction Stop).ReleaseId }
    }
    catch { $release = "Unknown" }
    
    # Use improved detection functions
    $secureBoot = Get-SecureBootStatus
    $tpmEnabled = Get-TpmStatus
    
    $defender   = if ((Get-MpComputerStatus).RealTimeProtectionEnabled) { "on" } else { "off" }
    $virt       = Get-VirtualizationStatus
    $fastBoot   = Get-FastBootStatus
    $firmwareType = Get-FirmwareType
    
    $vgkDetected = Test-Path "C:\Windows\System32\drivers\vgk.sys"
    
    $script:systemCheckResults = @{
        OSName = $os.Caption
        OSVersion = $os.Version
        OSBuild = $os.BuildNumber
        Release = $release
        Manufacturer = $cs.Manufacturer
        Model = $cs.Model
        Processor = $proc.Name
        Cores = $cs.NumberOfLogicalProcessors
        RAM = [Math]::Round($cs.TotalPhysicalMemory/1GB,2)
        SecureBoot = $secureBoot
        Virtualization = $virt
        Defender = $defender
        TpmEnabled = $tpmEnabled
        FastBoot = $fastBoot
        FirmwareType = $firmwareType
        VGKDetected = $vgkDetected
    }
    
    $CheckResultsPanel.Children.Add((New-Object Windows.Controls.TextBlock -Property @{
        Text = "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        FontWeight = "Bold"
        Foreground = "#BB86FC"
        Margin = "0,0,0,15"
    }))
    
    $CheckResultsPanel.Children.Add((New-Object Windows.Controls.TextBlock -Property @{
        Text = "OPERATING SYSTEM"
        FontSize = "16"
        FontWeight = "Bold"
        Foreground = "#BB86FC"
        Margin = "0,0,0,10"
    }))
    
    $CheckResultsPanel.Children.Add((New-Object Windows.Controls.TextBlock -Property @{
        Text = "OS Name: $($os.Caption)"
        Foreground = "#B0B0B0"
    }))
    $CheckResultsPanel.Children.Add((New-Object Windows.Controls.TextBlock -Property @{
        Text = "Version: $($os.Version)"
        Foreground = "#B0B0B0"
    }))
    $CheckResultsPanel.Children.Add((New-Object Windows.Controls.TextBlock -Property @{
        Text = "Build: $($os.BuildNumber)"
        Foreground = "#B0B0B0"
    }))
    
    $releaseBlock = New-Object Windows.Controls.TextBlock
    $releaseBlock.Text = "Release: $release"
    $releaseBlock.FontWeight = "Bold"
    $releaseBlock.Foreground = "White"
    $CheckResultsPanel.Children.Add($releaseBlock)
    
    $CheckResultsPanel.Children.Add((New-Object Windows.Controls.TextBlock -Property @{
        Text = "HARDWARE"
        FontSize = "16"
        FontWeight = "Bold"
        Foreground = "#BB86FC"
        Margin = "0,15,0,10"
    }))
    
    $CheckResultsPanel.Children.Add((New-Object Windows.Controls.TextBlock -Property @{
        Text = "Manufacturer: $($cs.Manufacturer)"
        Foreground = "#B0B0B0"
    }))
    $CheckResultsPanel.Children.Add((New-Object Windows.Controls.TextBlock -Property @{
        Text = "Model: $($cs.Model)"
        Foreground = "#B0B0B0"
    }))
    $CheckResultsPanel.Children.Add((New-Object Windows.Controls.TextBlock -Property @{
        Text = "Processor: $($proc.Name)"
        Foreground = "#B0B0B0"
    }))
    $CheckResultsPanel.Children.Add((New-Object Windows.Controls.TextBlock -Property @{
        Text = "CPU Cores: $($cs.NumberOfLogicalProcessors)"
        Foreground = "#B0B0B0"
    }))
    $CheckResultsPanel.Children.Add((New-Object Windows.Controls.TextBlock -Property @{
        Text = "Total RAM: $([Math]::Round($cs.TotalPhysicalMemory/1GB,2)) GB"
        Foreground = "#B0B0B0"
    }))
    
    $CheckResultsPanel.Children.Add((New-Object Windows.Controls.TextBlock -Property @{
        Text = "SECURITY"
        FontSize = "16"
        FontWeight = "Bold"
        Foreground = "#BB86FC"
        Margin = "0,15,0,10"
    }))
    
    $securityItems = @(
        @{Label = "TPM Enabled"; Value = $tpmEnabled},
        @{Label = "Secure Boot"; Value = $secureBoot},
        @{Label = "Virtualization"; Value = $virt},
        @{Label = "Windows Defender"; Value = $defender},
        @{Label = "Fast Boot"; Value = $fastBoot},
        @{Label = "Firmware Type"; Value = $firmwareType},
        @{Label = "Valorant Anti-Cheat"; Value = if ($vgkDetected) { "Detected" } else { "Not Detected" }}
    )
    
    foreach ($item in $securityItems) {
        $stackPanel = New-Object Windows.Controls.StackPanel
        $stackPanel.Orientation = "Horizontal"
        $stackPanel.Margin = "0,0,0,5"
        
        $labelBlock = New-Object Windows.Controls.TextBlock
        $labelBlock.Text = "$($item.Label): "
        $labelBlock.Foreground = "#E0E0E0"
        $labelBlock.Width = 180
        $stackPanel.Children.Add($labelBlock)
        
        $valueBlock = New-Object Windows.Controls.TextBlock
        $valueBlock.Text = $item.Value
        $valueBlock.FontWeight = "Bold"
        
        if ($item.Label -eq "Firmware Type") {
            if ($item.Value -eq "UEFI") { $valueBlock.Foreground = "#4CAF50" }
            elseif ($item.Value -eq "Legacy BIOS") { $valueBlock.Foreground = "#F44336" }
            else { $valueBlock.Foreground = "#FF9800" }
        }
        elseif ($item.Label -eq "Valorant Anti-Cheat") {
            if ($item.Value -eq "Detected") { $valueBlock.Foreground = "#F44336" }
            else { $valueBlock.Foreground = "#4CAF50" }
        }
        else {
            if ($item.Value -match "off|disabled") { $valueBlock.Foreground = "#4CAF50" }
            elseif ($item.Value -match "on|enabled") { $valueBlock.Foreground = "#F44336" }
            else { $valueBlock.Foreground = "#FF9800" }
        }
        
        $stackPanel.Children.Add($valueBlock)
        $CheckResultsPanel.Children.Add($stackPanel)
    }
    
    Hide-Loading
}

function Apply-SystemFixes {
    Show-Loading "Applying system fixes..." -duration 3000
    
    $fixResults = @()
    $actionCounter = 0
    $totalActions = 7  # Reduced since we removed Game Bar fix
    
    try {
        $actionCounter++
        $LoadingStatus.Text = "Disabling Fast Boot ($actionCounter/$totalActions)"
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name HiberbootEnabled -Value 0 -Force
        $fixResults += "[SUCCESS] Disabled Fast Boot"
    } catch { $fixResults += "[FAILED] Could not disable Fast Boot: $_" }
    
    try {
        $actionCounter++
        $LoadingStatus.Text = "Disabling Windows Defender ($actionCounter/$totalActions)"
        Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
        Set-MpPreference -DisableBehaviorMonitoring $true -ErrorAction SilentlyContinue
        Set-MpPreference -DisableScriptScanning $true -ErrorAction SilentlyContinue
        $fixResults += "[SUCCESS] Disabled Windows Defender"
    } catch { $fixResults += "[FAILED] Could not disable Windows Defender: $_" }
    
    try {
        $actionCounter++
        $LoadingStatus.Text = "Disabling Hyper-V ($actionCounter/$totalActions)"
        Start-Process "bcdedit" -ArgumentList "/set hypervisorlaunchtype off" -Wait -WindowStyle Hidden
        $fixResults += "[SUCCESS] Disabled Hyper-V"
    } catch { $fixResults += "[FAILED] Could not disable Hyper-V: $_" }
    
    try {
        $actionCounter++
        $LoadingStatus.Text = "Optimizing network settings ($actionCounter/$totalActions)"
        Start-Process "ipconfig" -ArgumentList "/flushdns" -WindowStyle Hidden -Wait
        Start-Process "netsh" -ArgumentList "winsock reset" -WindowStyle Hidden -Wait
        Start-Process "ipconfig" -ArgumentList "/release" -WindowStyle Hidden -Wait
        Start-Sleep -Seconds 2
        Start-Process "ipconfig" -ArgumentList "/renew" -WindowStyle Hidden -Wait
        $fixResults += "[SUCCESS] Optimized network settings"
    } catch { $fixResults += "[FAILED] Could not optimize network: $_" }
    
    if ($script:systemCheckResults.VGKDetected) {
        $actionCounter++
        $LoadingStatus.Text = "Checking for anti-cheat software ($actionCounter/$totalActions)"
        $fixResults += "[WARNING] Valorant anti-cheat detected (Must uninstall manually)"
    }
    
    try {
        $actionCounter++
        $LoadingStatus.Text = "Optimizing TCP settings ($actionCounter/$totalActions)"
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "EnablePMTUDiscovery" -Value 1 -Force
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "TcpWindowSize" -Value 64240 -Force
        $fixResults += "[SUCCESS] Optimized TCP/IP parameters"
    } catch { $fixResults += "[FAILED] Could not optimize TCP settings: $_" }
    
    try {
        $actionCounter++
        $LoadingStatus.Text = "Disabling Telemetry ($actionCounter/$totalActions)"
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Force
        $fixResults += "[SUCCESS] Disabled Windows Telemetry"
    } catch { $fixResults += "[FAILED] Could not disable Telemetry: $_" }
    
    Start-Sleep -Milliseconds 500
    Run-SystemCheck
    Hide-Loading
    
    $AutoFixResults.Text = $fixResults -join "`n"
    $AutoFixPopup.Visibility = "Visible"
}

function Start-Download {
    $ProgressBarFill.Width = 0
    $DownloadStatus.Text = "Preparing download..."
    $DownloadPath.Text = ""
    
    $script:downloadAnimationTimer = New-Object System.Windows.Threading.DispatcherTimer
    $script:downloadAnimationTimer.Interval = [TimeSpan]::FromMilliseconds(100)
    $dots = 0
    $script:downloadAnimationTimer.Add_Tick({
        $dots = ($dots + 1) % 4
        $DownloadStatus.Text = "Downloading" + ("." * $dots) + "   "
    })
    $script:downloadAnimationTimer.Start()

    $fileName = [System.IO.Path]::GetFileName($script:currentDownload.Url)
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $filePath = Join-Path -Path $desktopPath -ChildPath $fileName
    
    $DownloadPath.Text = "Saving to: $filePath"
    
    try {
        $client = New-Object System.Net.WebClient
        
        # Register progress event
        $eventHandler = {
            param($sender, $e)
            $Window.Dispatcher.Invoke([action]{
                $percent = $e.ProgressPercentage
                $ProgressBarFill.Width = [Math]::Max(0, [Math]::Min(400, ($percent * 4)))
                $DownloadStatus.Text = "Downloading... $percent%"
            })
        }
        $client.Add_DownloadProgressChanged($eventHandler)
        
        # Register completion event
        $completedHandler = {
            param($sender, $e)
            $Window.Dispatcher.Invoke([action]{
                if ($script:downloadAnimationTimer) {
                    $script:downloadAnimationTimer.Stop()
                    $script:downloadAnimationTimer = $null
                }
                
                if ($e.Error) {
                    $DownloadStatus.Text = "Download failed: $($e.Error.Message)"
                } 
                elseif ($e.Cancelled) {
                    $DownloadStatus.Text = "Download cancelled"
                } 
                else {
                    $ProgressBarFill.Width = 400
                    $DownloadStatus.Text = "Download completed!"
                    if (Test-Path $filePath) {
                        Start-Process "explorer.exe" -ArgumentList "/select, `"$filePath`""
                    }
                }
                $client.Dispose()
            })
        }
        $client.Add_DownloadFileCompleted($completedHandler)
        
        # Start download
        $client.DownloadFileAsync([Uri]::new($script:currentDownload.Url), $filePath)
    }
    catch {
        if ($script:downloadAnimationTimer) {
            $script:downloadAnimationTimer.Stop()
            $script:downloadAnimationTimer = $null
        }
        $DownloadStatus.Text = "Error: $($_.Exception.Message)"
        [System.Windows.MessageBox]::Show("Download error!`n$($_.Exception.Message)", "Error", "OK", "Error")
    }
}

function Run-FNCCleaner {
    $cleanType = $FNCCleanType.SelectedItem.Content
    $FNCLog.Text = "Starting $cleanType cleaning...`n`n"
    $FNCCleanBtn.IsEnabled = $false
    
    $scripts = @()
    switch ($cleanType) {
        "Minimal Clean" { $scripts = @("https://raw.githubusercontent.com/fawnchunk/calamaristuff/refs/heads/main/cleaner1.bat") }
        "Basic Clean" { $scripts = @(
            "https://raw.githubusercontent.com/fawnchunk/calamaristuff/refs/heads/main/cleaner1.bat",
            "https://raw.githubusercontent.com/fawnchunk/calamaristuff/refs/heads/main/cleaner2.bat"
        )}
        "Advanced Clean" { $scripts = @(
            "https://raw.githubusercontent.com/fawnchunk/calamaristuff/refs/heads/main/cleaner1.bat",
            "https://raw.githubusercontent.com/fawnchunk/calamaristuff/refs/heads/main/cleaner2.bat",
            "https://raw.githubusercontent.com/fawnchunk/calamaristuff/refs/heads/main/cleaner3.bat"
        )}
    }
    
    $tempDir = [System.IO.Path]::GetTempPath()
    $scriptFiles = @()
    
    foreach ($scriptUrl in $scripts) {
        try {
            $scriptName = [System.IO.Path]::GetFileName($scriptUrl)
            $scriptPath = Join-Path -Path $tempDir -ChildPath $scriptName
            
            $FNCLog.Text += "Downloading $scriptName...`n"
            $Window.Dispatcher.Invoke([action]{},"Render")
            
            (New-Object System.Net.WebClient).DownloadFile($scriptUrl, $scriptPath)
            $scriptFiles += $scriptPath
            $FNCLog.Text += "[SUCCESS] Downloaded $scriptName`n"
        }
        catch {
            $FNCLog.Text += "[FAILED] Could not download $scriptName - $($_.Exception.Message)`n"
        }
    }
    
    foreach ($scriptFile in $scriptFiles) {
        try {
            $FNCLog.Text += "`nExecuting $([System.IO.Path]::GetFileName($scriptFile))...`n"
            $Window.Dispatcher.Invoke([action]{},"Render")
            
            $output = & cmd /c $scriptFile 2>&1 | Out-String
            $FNCLog.Text += "$output`n"
            $FNCLog.Text += "[SUCCESS] Execution completed`n"
        }
        catch {
            $FNCLog.Text += "[FAILED] Error executing script - $($_.Exception.Message)`n"
        }
    }
    
    $FNCLog.Text += "`nCleaning process completed!`n"
    $FNCLog.Text += "`nIMPORTANT: For complete removal, please uninstall the game using Revo Uninstaller`n"
    $FNCCleanBtn.IsEnabled = $true
}

function Show-Download-Screen {
    $DownloadScreenToolName.Text = $script:currentDownload.Name
    Switch-Screen -toScreen $DownloadScreen
    Start-Download
}

function Show-FNCScreen {
    $FNCLog.Text = "Select a cleaning option and click Clean to begin..."
    Switch-Screen -toScreen $FNCScreen
}

$CloseWindowBtn.Add_Click({ $Window.Close() })

$WebsiteBtn.Add_Click({ Start-Process "https://calamari.lol" })

$UnlockBtn.Add_Click({
    $inputPassword = $PassBox.Password
    
    if (-not $inputPassword) {
        [System.Windows.MessageBox]::Show('Please enter a password','Error','OK','Error')
        return
    }
    
    Show-Loading
    $UnlockBtn.IsEnabled = $false

    if (Check-Password -userInput $inputPassword -correctPassword $Passwords.Checker) {
        Switch-Screen -toScreen $SystemScreen
        Run-SystemCheck
    }
    elseif (Check-Password -userInput $inputPassword -correctPassword $Passwords.GigabyteBiosFlasher) {
        $script:currentDownload = @{
            Name = $ToolNames.GigabyteBiosFlasher
            Url = $DownloadUrls.GigabyteBiosFlasher
        }
        Show-Download-Screen
    }
    elseif (Check-Password -userInput $inputPassword -correctPassword $Passwords.SmbiosFixer) {
        $script:currentDownload = @{
            Name = $ToolNames.SmbiosFixer
            Url = $DownloadUrls.SmbiosFixer
        }
        Show-Download-Screen
    }
    elseif (Check-Password -userInput $inputPassword -correctPassword $Passwords.Dcontrol) {
        $script:currentDownload = @{
            Name = $ToolNames.Dcontrol
            Url = $DownloadUrls.Dcontrol
        }
        Show-Download-Screen
    }
    elseif (Check-Password -userInput $inputPassword -correctPassword $Passwords.FNCleaner) {
        Show-FNCScreen
    }
    else {
        [System.Windows.MessageBox]::Show('Incorrect password','Error','OK','Error')
    }
    
    Hide-Loading
    $UnlockBtn.IsEnabled = $true
})

$CopyResultsBtn.Add_Click({
    $textToCopy = "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`r`n`r`n"
    $textToCopy += "==**OPERATING SYSTEM**==`r`n`r`n"
    $textToCopy += "OS Name: $($script:systemCheckResults.OSName)`r`n"
    $textToCopy += "Version: $($script:systemCheckResults.OSVersion)`r`n"
    $textToCopy += "Build: $($script:systemCheckResults.OSBuild)`r`n"
    $textToCopy += "Release: **$($script:systemCheckResults.Release)**`r`n`r`n"
    
    $textToCopy += "==**HARDWARE**==`r`n`r`n"
    $textToCopy += "Manufacturer: $($script:systemCheckResults.Manufacturer)`r`n"
    $textToCopy += "Model: $($script:systemCheckResults.Model)`r`n"
    $textToCopy += "Processor: $($script:systemCheckResults.Processor)`r`n"
    $textToCopy += "CPU Cores: $($script:systemCheckResults.Cores)`r`n"
    $textToCopy += "Total RAM: $($script:systemCheckResults.RAM) GB`r`n`r`n"
    
    $textToCopy += "==**SECURITY**==`r`n`r`n"
    $textToCopy += "TPM Enabled: **$($script:systemCheckResults.TpmEnabled)**`r`n"
    $textToCopy += "Secure Boot: **$($script:systemCheckResults.SecureBoot)**`r`n"
    $textToCopy += "Virtualization: **$($script:systemCheckResults.Virtualization)**`r`n"
    $textToCopy += "Windows Defender: **$($script:systemCheckResults.Defender)**`r`n"
    $textToCopy += "Fast Boot: **$($script:systemCheckResults.FastBoot)**`r`n"
    $textToCopy += "Firmware Type: **$($script:systemCheckResults.FirmwareType)**`r`n"
    $textToCopy += "Valorant Anti-Cheat: **$(if ($script:systemCheckResults.VGKDetected) {'Detected'} else {'Not Detected'})**"
    
    [System.Windows.Forms.Clipboard]::SetText($textToCopy)
    [System.Windows.MessageBox]::Show('Report copied to clipboard!','Success','OK','Information')
})

$CloseReportBtn.Add_Click({ 
    Switch-Screen -toScreen $UnlockScreen
    $PassBox.Password = ""
    $PassBox.Focus()
})

$AutoFixBtn.Add_Click({ Apply-SystemFixes })

$RestartNowBtn.Add_Click({
    Start-Process "shutdown" -ArgumentList "/r /t 0" -Verb RunAs
})

$RestartLaterBtn.Add_Click({
    $AutoFixPopup.Visibility = "Collapsed"
})

$DownloadCloseBtn.Add_Click({ 
    if ($script:downloadAnimationTimer) { 
        $script:downloadAnimationTimer.Stop()
        $script:downloadAnimationTimer = $null 
    }
    
    Switch-Screen -toScreen $UnlockScreen
    $PassBox.Password = ""
    $PassBox.Focus()
})

$FNCCleanBtn.Add_Click({
    $FNCCleanBtn.IsEnabled = $false
    Run-FNCCleaner
})

$FNCGetRevoBtn.Add_Click({
    Start-Process "https://www.revouninstaller.com/start-freeware-download/"
})

$FNCCloseBtn.Add_Click({
    Switch-Screen -toScreen $UnlockScreen
    $PassBox.Password = ""
    $PassBox.Focus()
})

$Window.Add_ContentRendered({
    $PassBox.Focus()
    $Window.Activate()
    Create-StarryBackground
    
    $script:starAnimationTimer = New-Object System.Windows.Threading.DispatcherTimer
    $script:starAnimationTimer.Interval = [TimeSpan]::FromMilliseconds(30)
    $script:starAnimationTimer.Add_Tick({ Animate-Stars })
    $script:starAnimationTimer.Start()
})

$Window.Add_SizeChanged({ Create-StarryBackground })

$Window.ShowDialog() | Out-Null
