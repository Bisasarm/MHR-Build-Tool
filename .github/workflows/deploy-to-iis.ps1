# params festlegen für GitHub Actions
params (
    [string]$_siteName,
    [string]$_sitePath,
    [string]$_sourcePath,
    [int]$_port
)

# importieren des nötigen Moduls für IIS
Import-Module WebAdministration

# Zuerst werden 2 Funktionen definiert um zwei Schritte zu durchlaufen
# Schritt 1 - Überprüfen ob Seite im IIS schon vorhanden, wenn nein, dann erstellen
# Schritt 2 - Deployment der WebApp

# Schritt 1:

function Create-IISSiteIfNotExists{
    params(
        [string]$siteName,
        [string]$sitePath,
        [int]$port
    )
    # Seite holen um zu überprüfen ob NULL oder nicht. Absichtlich die Exception ignorieren
    $site = Get-Website -Name $siteName -ErrorAction SilentlyContinue
    if($site -eq $null){
        Write-Host "IIS Seite existiert nicht. Neue Seite wird erstellt"
        New-Website -Name $siteName -PhysicalPath $sitePath -Port $port
    }
    else{
        Write-Host "Seite existiert bereits"
    }
}

# Schritt 2: Deployment Function
function Deploy-Application{
    param(
        [string]$siteName,
        [string]$sitePath,
        [string]$sourcePath
    )
    # IIS Stopp
    Write-Host "IIS Stopp"
    Stop-Website -Name $siteName

    # Alte Dateien entfernen
    Write-Host "Alte Files entfernen"
    Remove-Item -Recurse -Force -Path $sitePath\*

    # Neue Files von Quelle rüberkopieren
    Write-Host "Kopieren neuer Files auf Zielmaschine"
    Copy-Item -Recurse -Force -Path $sourcePath\* -Destination $sitePath

    # Starten der Seite
    Write-Host "Seite wird mit neuen Files gestartet"
    Start-Website -Name $siteName

    Write-Host "Deployment durchgeführt"
}

# Durchführen der Schritte

Create-IISSiteIfNotExists -siteName $_siteName -sitePath $_sitePath -port $_port
Deploy-Application -siteName $_siteName -sitePath $_sitePath -sourcePath $_sourcePath
