@ECHO OFF

cd /D "%~dp0"

echo "Installing Velociraptor service..."
msiexec /i win-velociraptor.msi /qn

echo "Copying Velociraptor config file..."
copy Velociraptor.config.yaml "%SYSTEMDRIVE%\Program Files\Velociraptor"

echo "Starting Velociraptor service..."
net stop Velociraptor && net start Velociraptor