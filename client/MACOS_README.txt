Instructions for playing Lucifer on Mac
---------------------------------------

By default, Lucifer will not run on a Mac because of signing issues. You might get two different errors depending on the executable, so follow the relevant steps:

If you get this error: '"Lucifer" is damaged and can't be opened. You should move it to the Bin.', follow the steps for Error A.

If you get this erorr: '"Lucifer" can't be opened because Apple cannot check it for malicious software.', follow the steps for Error B.

Error A steps:

1. Open the terminal, and navigate to the folder containing Lucifer.app

2. Run the following command: xattr -dr com.apple.quarantine "Lucifer.app"


Error B steps:

1. Open System Preferences, and head to Security & Privacy

2. Click General, and then click Open Anyway at the bottom.

