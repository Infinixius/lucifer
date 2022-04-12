cd C:/Users/infi/Development/Projects/lucifer/server
Remove-Item "./builds" -Recurse
npm run build

Remove-Item "C:/Users/infi/Development/Projects/lucifer/client/builds/windows/lan" -Recurse
Remove-Item "C:/Users/infi/Development/Projects/lucifer/client/builds/macos/lan" -Recurse
Remove-Item "C:/Users/infi/Development/Projects/lucifer/client/builds/linux/lan" -Recurse

New-Item -Path 'C:/Users/infi/Development/Projects/lucifer/client/builds/windows/lan' -ItemType Directory
New-Item -Path 'C:/Users/infi/Development/Projects/lucifer/client/builds/macos/lan' -ItemType Directory
New-Item -Path 'C:/Users/infi/Development/Projects/lucifer/client/builds/linux/lan' -ItemType Directory

Move-Item ./builds/lucifer-ylp-win.exe C:/Users/infi/Development/Projects/lucifer/client/builds/windows/lan
Move-Item ./builds/lucifer-ylp-macos C:/Users/infi/Development/Projects/lucifer/client/builds/macos/lan
Move-Item ./builds/lucifer-ylp-linux C:/Users/infi/Development/Projects/lucifer/client/builds/linux/lan