# Install software needed to build R on Windows (Msys2, InnoSetup, MikTex). 
# The installers are downloaded automatically unless they are made available
# in "C:\installers" already (but only specific versions are supported, see
# below).

Set-PSDebug -Trace 1
cd C:\

# Needed on Windows Server 2016 (and probably other older Windows systems)
# to download files via https.
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (-not(Test-Path("temp"))) {
  mkdir temp
}

# Install Inno Setup

# https://jrsoftware.org/download.php/is.exe?site=2
if (-not(Test-Path("C:\Program Files (x86)\InnoSetup"))) {
  cd temp
  if (Test-Path("..\installers\innosetup-6.2.0.exe")) {
    cp "..\installers\innosetup-6.2.0.exe" innosetup.exe
  } elseif (-not(Test-Path("innosetup.exe"))) {
    Invoke-WebRequest -Uri https://jrsoftware.org/download.php/is.exe?site=2 -OutFile innosetup.exe -UseBasicParsing
  }
  Start-Process -Wait -FilePath ".\innosetup.exe" -ArgumentList "/VERYSILENT /ALLUSERS /NOICONS /DIR=`"C:\Program Files (x86)\InnoSetup`""
  cd ..
}

# Install MikTeX
#
# This uses MiKTeX basic installer, version 21.6 (which is not the latest as
# of this writing, but 21.8 is crashing on "texify --version").  Installs it
# per-user only avoid problems with per-user and system-wide installations
# going out of sync. Updates the package database, but does not upgrade the
# packages, in order not to install the crashing version.
#
# This installer does not work in a docker container servercore image, because
# it uses DLLs/features not present there. But it works in the full server
# image.

# https://miktex.org/download/ctan/systems/win32/miktex/setup/windows-x64/basic-miktex-21.6-x64.exe

if (-not(Test-Path("$env:LOCALAPPDATA\Programs\MiKTeX\miktex\bin\x64\"))) {
  cd temp
  if (Test-Path("..\installers\basic-miktex-21.6-x64.exe")) {
    cp "..\installers\basic-miktex-21.6-x64.exe" basic-miktex.exe
  } elseif (-not(Test-Path("basic-miktex.exe"))) {
    Invoke-WebRequest -Uri https://miktex.org/download/ctan/systems/win32/miktex/setup/windows-x64/basic-miktex-21.6-x64.exe -OutFile basic-miktex.exe -UseBasicParsing
  }

  Start-Process -Wait -FilePath ".\basic-miktex.exe" `
    -ArgumentList "--unattended --package-set=basic --private --user-config=`"$env:APPDATA\MiKTeX`" --user-data=`"$env:LOCALAPPDATA\MiKTeX`" --user-install=`"$env:LOCALAPPDATA\Programs\MiKTeX`""
  
  Start-Process -Wait -FilePath "$env:LOCALAPPDATA\Programs\MiKTeX\miktex\bin\x64\initexmf.exe" -ArgumentList "--enable-installer"
  Start-Process -Wait -FilePath "$env:LOCALAPPDATA\Programs\MiKTeX\miktex\bin\x64\initexmf.exe" -ArgumentList "--set-config-value=[MPM]AutoInstall=t"
  Start-Process -Wait -FilePath "$env:LOCALAPPDATA\Programs\MiKTeX\miktex\bin\x64\mpm.exe" -ArgumentList "--verbose --update-db"
  Start-Process -Wait -FilePath "$env:LOCALAPPDATA\Programs\MiKTeX\miktex\bin\x64\mpm.exe" -ArgumentList "--install=inconsolata"
  cd ..
}

# Install Msys2

# https://github.com/msys2/msys2-installer/releases/download/2020-11-09/msys2-base-x86_64-20201109.sfx.exe

if (-not(Test-Path("C:\msys64"))) {
  cd temp
  if (Test-Path("..\installers\msys2-base-x86_64-20210604.sfx.exe")) {
    cp "..\installers\msys2-base-x86_64-20210604.sfx.exe" msys2-base.exe
  } elseif (-not(Test-Path("msys2-base.exe"))) {
    Invoke-WebRequest -Uri https://github.com/msys2/msys2-installer/releases/download/2021-06-04/msys2-base-x86_64-20210604.sfx.exe -OutFile msys2-base.exe -UseBasicParsing
  }
  cd ..

  Start-Process -Wait -FilePath ".\temp\msys2-base.exe"

  # from https://www.msys2.org/docs/ci/
    # Run for the first time
  Start-Process -Wait -FilePath "C:\msys64\usr\bin\bash" -ArgumentList "-lc ' '"

    # Update MSYS2
  Start-Process -Wait -FilePath "C:\msys64\usr\bin\bash" -ArgumentList "-lc 'pacman --noconfirm -Syuu'"  # Core update (in case any core packages are outdated)
  Start-Process -Wait -FilePath "C:\msys64\usr\bin\bash" -ArgumentList "-lc 'pacman --noconfirm -Syuu'"  # Normal update

    # Install Msys2 packages needed for building R
  Start-Process -Wait -FilePath "C:\msys64\usr\bin\bash" -ArgumentList "-lc 'pacman --noconfirm -y -S unzip diffutils make winpty rsync texinfo tar texinfo-tex zip subversion bison moreutils xz patch'"
}
