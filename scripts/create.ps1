# PowerShell

$ErrorActionPreference = "Stop"

$env:LANG="C"
$env:LC_CTYPE="C"
$env:LC_ALL="C"

function usage {
    Write-Host "Running this script will create a new project based on the starterkit."
    Write-Host "It will clone the starterkit-mobile-application-flutter repository to the current directory and rename the project."
    Write-Host "You will be prompted to enter the project name, app id, and directory where the project will be created."
}

usage

function replace {
    param($1, $2)
    Write-Host "Replacing $1 with $2..."
    Get-ChildItem -Path "$DIR/$PROJECT_REPO_NAME" -Recurse -File | ForEach-Object {
        (Get-Content -Path $_.FullName) -replace $1, $2 | Set-Content -Path $_.FullName
    }
}

$PROJECT_NAME=""
$APP_ID=""
$DIR=(Get-Location).Path
$DEV_SECRETS="ewogICAgImFwcEVudmlyb25tZW50IjogImRldiIsCiAgICAiYXBwU2VydmVyVXJsIjogImh0dHBzOi8vanNvbnBsYWNlaG9sZGVyLnR5cGljb2RlLmNvbS8iLAogICAgImFwcElkIjogImNvbS5leGFtcGxlLnN0YXJ0ZXJraXQuYXBwIiwKICAgICJhcHBJZFN1ZmZpeCI6ICIuZGV2IiwKICAgICJhcHBOYW1lIjogIlN0YXJ0ZXJraXQgQXBwIChEZXYpIiwKICAgICJpT1NEZXZlbG9wbWVudFRlYW0iOiAiQUJDREUxMjM0NSIsCiAgICAiaU9TRGV2ZWxvcG1lbnRQcm9maWxlIjogIllvdXIgRGV2ZWxvcG1lbnQgUHJvZmlsZSBOYW1lIiwKICAgICJpT1NEaXN0cmlidXRpb25Qcm9maWxlIjogIllvdXIgRGlzdHJpYnV0aW9uIFByb2ZpbGUgTmFtZSIsCiAgICAiaU9TRXhwb3J0TWV0aG9kIjogImFkLWhvYyIKfQ=="
$PROD_SECRETS="ewogICAgImFwcEVudmlyb25tZW50IjogInByb2QiLAogICAgImFwcFNlcnZlclVybCI6ICJodHRwczovL2pzb25wbGFjZWhvbGRlci50eXBpY29kZS5jb20vIiwKICAgICJhcHBJZCI6ICJjb20uZXhhbXBsZS5zdGFydGVya2l0LmFwcCIsCiAgICAiYXBwSWRTdWZmaXgiOiAiIiwKICAgICJhcHBOYW1lIjogIlN0YXJ0ZXJraXQgQXBwIiwKICAgICJpT1NEZXZlbG9wbWVudFRlYW0iOiAiQUJDREUxMjM0NSIsCiAgICAiaU9TRGV2ZWxvcG1lbnRQcm9maWxlIjogIllvdXIgRGV2ZWxvcG1lbnQgUHJvZmlsZSBOYW1lIiwKICAgICJpT1NEaXN0cmlidXRpb25Qcm9maWxlIjogIllvdXIgRGlzdHJpYnV0aW9uIFByb2ZpbGUgTmFtZSIsCiAgICAiaU9TRXhwb3J0TWV0aG9kIjogImFwcC1zdG9yZSIKfQ=="

$PROJECT_NAME = Read-Host "Enter project name (e.g. my_app)"
$APP_ID = Read-Host "Enter app id (e.g. com.example.my.app)"
$DIR = Read-Host "Enter directory where the project will be created"

if ([string]::IsNullOrEmpty($DIR)) {
    $DIR=(Get-Location).Path
} else {
    # Expand DIR if ~ is used or $ variable
    $DIR = $ExecutionContext.InvokeCommand.ExpandString($DIR)
}

$PROJECT_NAME=$PROJECT_NAME.ToLower()

if ([string]::IsNullOrEmpty($PROJECT_NAME)) {
    Write-Host "Project name is empty, please use -n or --name to set the project name"
    exit
}

if (-not ($PROJECT_NAME -match "^[a-z0-9_]+$")) {
    Write-Host "Project name is not in the correct format, it should be snake case"
    exit
}

if ([string]::IsNullOrEmpty($APP_ID)) {
    Write-Host "App id is empty, please use -i or --app-id to set the app id"
    exit
}

if (-not ($APP_ID -match "^[a-z0-9.]+$") -or ($APP_ID.Split(".").Count -lt 2)) {
    Write-Host "App id is not in the correct format, it should be like com.company.project"
    exit
}

$PROJECT_REPO_NAME=$PROJECT_NAME.Replace("_", "-")
$PROJECT_DIR="$DIR/$PROJECT_REPO_NAME/$PROJECT_NAME"
$APP_NAME=$PROJECT_NAME.Split("_") | ForEach-Object { $_.Substring(0,1).ToUpper()+$_.Substring(1).ToLower() }
$APP_NAME=$APP_NAME -join " "

Write-Host "Project name: $PROJECT_NAME"
Write-Host "Project repo name: $PROJECT_REPO_NAME"
Write-Host "Project Directory: $DIR/$PROJECT_REPO_NAME"
Write-Host "App id: $APP_ID"
Write-Host "App name: $APP_NAME"

$REPLY = Read-Host "Are you sure you want to continue? (y/n)"

if ($REPLY -notmatch "^[Yy]$") {
    exit
}

git clone https://github.com/dustincatap/starterkit-mobile-application-flutter.git "$DIR/$PROJECT_REPO_NAME"
Remove-Item -Recurse -Force "$DIR/$PROJECT_REPO_NAME/.git" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "$DIR/$PROJECT_REPO_NAME/.github" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "$DIR/$PROJECT_REPO_NAME/.gitmodules" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "$DIR/$PROJECT_REPO_NAME/.codecov.yml" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "$DIR/$PROJECT_REPO_NAME/AUTHORS.md" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "$DIR/$PROJECT_REPO_NAME/CONTRIBUTING.md" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "$DIR/$PROJECT_REPO_NAME/LICENSE" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "$DIR/$PROJECT_REPO_NAME/CODE_OF_CONDUCT.md" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "$DIR/$PROJECT_REPO_NAME/README.md" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "$DIR/$PROJECT_REPO_NAME/SECURITY.md" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "$DIR/$PROJECT_REPO_NAME/docs" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "$DIR/$PROJECT_REPO_NAME/scripts/create.sh" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "$DIR/$PROJECT_REPO_NAME/scripts/create.ps1" -ErrorAction SilentlyContinue
Move-Item "$DIR/$PROJECT_REPO_NAME/starterkit_app" "$PROJECT_DIR"

Write-Host "Renaming app name..."
replace "Starterkit App" $APP_NAME

Write-Host "Renaming app id..."
replace "com.example.starterkit_app" $APP_ID
replace "com.example.starterkit.app" $APP_ID
replace "com.mycompany.starterkit.app" $APP_ID

Write-Host "Renaming project name..."
replace "starterkit_app" $PROJECT_NAME

Write-Host "Setting up secrets..."
Remove-Item -Recurse -Force "$PROJECT_DIR/.secrets" -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path "$PROJECT_DIR/.secrets" | Out-Null
New-Item -ItemType File -Force -Path "$PROJECT_DIR/.secrets/dev.json" | Out-Null
New-Item -ItemType File -Force -Path "$PROJECT_DIR/.secrets/prod.json" | Out-Null
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($DEV_SECRETS)) | Set-Content "$PROJECT_DIR/.secrets/dev.json"
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($PROD_SECRETS)) | Set-Content "$PROJECT_DIR/.secrets/prod.json"

Write-Host "Updating secrets with project values..."
(Get-Content "$PROJECT_DIR/.secrets/dev.json") -replace "com\.example\.starterkit\.app", $APP_ID | Set-Content "$PROJECT_DIR/.secrets/dev.json"
(Get-Content "$PROJECT_DIR/.secrets/prod.json") -replace "com\.example\.starterkit\.app", $APP_ID | Set-Content "$PROJECT_DIR/.secrets/prod.json"
(Get-Content "$PROJECT_DIR/.secrets/dev.json") -replace "Starterkit App", $APP_NAME | Set-Content "$PROJECT_DIR/.secrets/dev.json"
(Get-Content "$PROJECT_DIR/.secrets/prod.json") -replace "Starterkit App", $APP_NAME | Set-Content "$PROJECT_DIR/.secrets/prod.json"

Write-Host "Moving MainActivity.kt..."
$ANDROID_PROJECT_DIR="$PROJECT_DIR/android"
$TEMP_MAIN_ACTIVITY_DIR="$ANDROID_PROJECT_DIR/app/src/main/kotlin"
$NEW_MAIN_ACTIVITY_DIR="$ANDROID_PROJECT_DIR/app/src/main/kotlin/$($APP_ID.Replace('.', '/'))"

$OLD_MAIN_ACTIVITY_DIR1="$ANDROID_PROJECT_DIR/app/src/main/kotlin/com/example/starterkit_app"
if (Test-Path "$OLD_MAIN_ACTIVITY_DIR1/MainActivity.kt") {
    Move-Item "$OLD_MAIN_ACTIVITY_DIR1/MainActivity.kt" "$TEMP_MAIN_ACTIVITY_DIR/MainActivity.kt"
    Remove-Item -Recurse -Force "$TEMP_MAIN_ACTIVITY_DIR/com"
    New-Item -ItemType Directory -Force -Path $NEW_MAIN_ACTIVITY_DIR | Out-Null
    Move-Item "$TEMP_MAIN_ACTIVITY_DIR/MainActivity.kt" "$NEW_MAIN_ACTIVITY_DIR/MainActivity.kt"
}

$OLD_MAIN_ACTIVITY_DIR2="$ANDROID_PROJECT_DIR/app/src/main/kotlin/com/example/starterkit/app"
if (Test-Path "$OLD_MAIN_ACTIVITY_DIR2/MainActivity.kt") {
    Move-Item "$OLD_MAIN_ACTIVITY_DIR2/MainActivity.kt" "$TEMP_MAIN_ACTIVITY_DIR/MainActivity.kt"
    Remove-Item -Recurse -Force "$TEMP_MAIN_ACTIVITY_DIR/com"
    New-Item -ItemType Directory -Force -Path $NEW_MAIN_ACTIVITY_DIR | Out-Null
    Move-Item "$TEMP_MAIN_ACTIVITY_DIR/MainActivity.kt" "$NEW_MAIN_ACTIVITY_DIR/MainActivity.kt"
}

if (-not (Get-Command fvm -ErrorAction SilentlyContinue)) {
    Write-Host "fvm could not be found"
    Write-Host "Please install fvm from https://fvm.app/"
    exit
}

Set-Location $PROJECT_DIR
fvm install
fvm dart format --line-length 120 .
fvm flutter pub get
fvm dart run build_runner build --delete-conflicting-outputs
fvm dart run intl_utils:generate
fvm dart fix --apply
Set-Location $DIR