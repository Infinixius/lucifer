cd C:/Users/infi/Development/Projects/lucifer/client
Remove-Item "./builds" -Recurse

New-Item -Path 'C:/Users/infi/Development/Projects/lucifer/client/builds/windows' -ItemType Directory
New-Item -Path 'C:/Users/infi/Development/Projects/lucifer/client/builds/macos' -ItemType Directory
New-Item -Path 'C:/Users/infi/Development/Projects/lucifer/client/builds/linux' -ItemType Directory

& "C:\\Program Files (x86`)\\Steam\\steamapps\\common\\Godot Engine\\godot.exe" --no-window --path C:\\Users\\infi\\Development\\Projects\\lucifer\\client --export Windows C:\\Users\\infi\\Development\\Projects\\lucifer\\client\\builds\\windows\\Lucifer.exe
echo "Built for Windows"

& "C:\\Program Files (x86`)\\Steam\\steamapps\\common\\Godot Engine\\godot.exe" --no-window --path C:\\Users\\infi\\Development\\Projects\\lucifer\\client --export Mac C:\\Users\\infi\\Development\\Projects\\lucifer\\client\\builds\\macos\\Lucifer
echo "Built for Mac"

& "C:\\Program Files (x86`)\\Steam\\steamapps\\common\\Godot Engine\\godot.exe" --no-window --path C:\\Users\\infi\\Development\\Projects\\lucifer\\client --export Linux C:\\Users\\infi\\Development\\Projects\\lucifer\\client\\builds\\linux\\Lucifer
echo "Built for Linux"