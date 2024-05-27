# params festlegen für GitHub Actions
param (
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
    param(
        [string]$siteName,
        [string]$sitePath,
        [int]$port
    )
    # Seite holen um zu überprüfen ob NULL oder nicht. Absichtlich die Exception ignorieren
    $site = Get-Website -Name $siteName -ErrorAction SilentlyContinue
    if($site -eq $null){
        Write-Host "IIS Seite existiert nicht. Neue Seite wird erstellt"
        # Check oh physischer Pfad schon existiert, ansonsten create
        if (!(Test-Path $_sitePath)) {
            New-Item -Path $_sitePath -ItemType Directory -Force
        }
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
    # Validierung der Parameter um nukleares Löschen zu verhindern
    if (([string]::IsNullOrEmpty($siteName) -or [string]::IsNullOrEmpty($sitePath) -or [string]::IsNullOrEmpty($sourcePath) )) {
        Write-Error "One or more parameters are null or empty."
        exit 1
    }
    
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