Add-Type -AssemblyName PresentationFramework

# Définir le XAML
$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="FiveM Cleaner" Height="200" Width="400">
    <Grid Name="grid">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
        </Grid.RowDefinitions>
        <Button Name="cleanButton" Content="Clean FiveM" HorizontalAlignment="Center" VerticalAlignment="Center" Margin="10" Padding="10" Grid.Row="0"/>
        <RichTextBox Name="logTextBox" Grid.Row="1" VerticalAlignment="Stretch" Margin="10" VerticalScrollBarVisibility="Auto"/>
        <TextBlock Name="statusText" HorizontalAlignment="Center" VerticalAlignment="Bottom" Margin="10" Grid.Row="1"/>
    </Grid>
</Window>

"@

# Convertir le XAML en objet .NET
$xamlReader = New-Object System.Xml.XmlTextReader (New-Object System.IO.StringReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($xamlReader)

# Créer une couleur verte pour les messages de réussite
$greenColor = New-Object System.Windows.Media.SolidColorBrush(
    [System.Windows.Media.Color]::FromRgb(0, 255, 0)
)

# Créer une couleur rouge pour les messages d'erreur
$redColor = New-Object System.Windows.Media.SolidColorBrush(
    [System.Windows.Media.Color]::FromRgb(255, 0, 0)
)

# Ajouter du texte à la RichTextBox avec une couleur spécifique
function Add-ColoredText {
    param(
        [string]$text,
        [System.Windows.Media.Brush]$color
    )

    $logTextBox = $window.FindName('logTextBox')

    # Create a TextRange object starting from the end of the existing content
    $textRange = New-Object System.Windows.Documents.TextRange(
        $logTextBox.Document.ContentEnd,
        $logTextBox.Document.ContentEnd
    )

    # Set the color of the TextRange object
    $textRange.Text = $text
    $textRange.ApplyPropertyValue(([System.Windows.Documents.TextElement]::ForegroundProperty), $color)

    # Append the TextRange object to the RichTextBox
    $logTextBox.AppendText("`n")
}


# Ajouter du texte vert à la RichTextBox
function Add-SuccessText {
    param(
        [string]$text
    )

    Add-ColoredText -Text $text -Color $greenColor
}

# Ajouter du texte rouge à la RichTextBox
function Add-ErrorText {
    param(
        [string]$text
    )

    Add-ColoredText -Text $text -Color $redColor
}



#######
# Get the Grid and RichTextBox elements
$grid = $window.FindName('grid')
$logTextBox = $window.FindName('logTextBox')

# Create a shared SizeChanged event handler for the Grid and RichTextBox
$sizeChangedEventHandler = {
    # Calculate the available height for the RichTextBox
    $availableHeight = [Math]::Max(10, $grid.ActualHeight - 80)  # Ensure the available height is at least 10

    # Set the RichTextBox height to the available height or its desired height, whichever is smaller
    $logTextBox.Height = [Math]::Min($availableHeight, $logTextBox.DesiredSize.Height)
}


# Attach the SizeChanged event handler to the Grid and RichTextBox
$grid.Add_SizeChanged($sizeChangedEventHandler)
$logTextBox.Add_SizeChanged($sizeChangedEventHandler)
###########








# Définir le gestionnaire d'événements pour le bouton
$cleanButton = $window.FindName('cleanButton')
$cleanButton.Add_Click({
    # Définir le chemin du dossier AppData de l'utilisateur actuel
    $appDataPath = [Environment]::GetFolderPath([Environment+SpecialFolder]::LocalApplicationData)

    # Définir le chemin du dossier FiveM
    $fiveMPath = Join-Path -Path $appDataPath -ChildPath "FiveM\FiveM.app"                    

    # Vérifier si le dossier FiveM existe
    if (Test-Path -Path $fiveMPath) {
        # Définir les chemins des dossiers à supprimer
        $crashesPath = Join-Path -Path $fiveMPath -ChildPath "Crashes"
        $logsPath = Join-Path -Path $fiveMPath -ChildPath "Logs"
        $dataPath = Join-Path -Path $fiveMPath -ChildPath "data"
        $cachePath = Join-Path -Path $dataPath -ChildPath "cache"
        $nuiStoragePath = Join-Path -Path $dataPath -ChildPath "nui-storage"
        $serverCachePath = Join-Path -Path $dataPath -ChildPath "server-cache"
        $serverCachePrivPath = Join-Path -Path $dataPath -ChildPath "server-cache-priv"

        # Supprimer les dossiers spécifiés
        if (Test-Path -Path $crashesPath) {
            Remove-Item -Path $crashesPath -Recurse -Force
            Add-SuccessText "Crashes folder deleted."
        } else {
            Add-ErrorText "Crashes folder not found."
        }

        if (Test-Path -Path $logsPath) {
            Remove-Item -Path $logsPath -Recurse -Force
            Add-SuccessText "Logs folder deleted."
        } else {
            Add-ErrorText "Logs folder not found."
        }

        if (Test-Path -Path $cachePath) {
            Remove-Item -Path $cachePath -Recurse -Force
            Add-SuccessText "Cache folder deleted."
        } else {
            Add-ErrorText "Cache folder not found."
        }

        if (Test-Path -Path $nuiStoragePath) {
            Remove-Item -Path $nuiStoragePath -Recurse -Force
            Add-SuccessText "NUI storage folder deleted."
        } else {
            Add-ErrorText "NUI storage folder not found."
        }

        if (Test-Path -Path $serverCachePath) {
            Remove-Item -Path $serverCachePath -Recurse -Force
            Add-SuccessText "Server cache folder deleted."
        } else {
            Add-ErrorText "Server cache folder not found."
        }

        if (Test-Path -Path $serverCachePrivPath) {
            Remove-Item -Path $serverCachePrivPath -Recurse -Force
            Add-SuccessText "Server cache private folder deleted."
        } else {
            Add-ErrorText "Server cache private folder not found."
        }

        # Mettre à jour le texte d'état
        $window.FindName('statusText').Text = "Folders deleted successfully."
    } else {
        # Mettre à jour le texte d'état
        $window.FindName('statusText').Text = "FiveM Application Data not found in the default location."
    }
})

# Afficher l'interface utilisateur
$window.ShowDialog()
