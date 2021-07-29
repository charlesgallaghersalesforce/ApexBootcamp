# ApexBootcamp
*Deploy base project to Playground*

1. *Create a brand new Playground and reset your password to secure access*
2. *Pull code from git repository (git should already be installed in your computer at this point)*
    1. Open Terminal if you are on a Mac, a Command Prompt in Windows
    2. Navigate to the folder where you want to create your project using the cd command 
    3. Execute the following command:
        1. git clone _https://github.com/charlesgallaghersalesforce/ApexBootcamp_ (https://github.com/charlesgallaghersalesforce/ApexBootcamp)
    4. Open VSCode and open the folder ApexBootcamp
3. *Authorize Playground in VSCode*
    1. Open the Command Pallet using: Mac: Cmd + Shift + P or Windows: Ctrl + Shift + P
    2. Run the command SFDX: Authorize an Org, select Production, and give a name to identify the connection to your playground
    3. Login with your Playground credentials and allow access to VSCode
4. *Deploy project to your Playground*
    1. In VSCode, open the file package.xml inside the manifest folder
    2. Right click on the file and choose SFDX: Deploy Source in Manifest to Org. If you get an error about not having a default org, open the Command Palette and run SFDX: Set a Default Org and choose the connection to your playground
