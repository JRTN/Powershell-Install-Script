# Powershell-Install-Script

## Folder Structure

    > script
    |
    -- Install-Script.ps1
    > util
    |
    -- > backend
        |
        -- Installation-Framework.ps1
        |
        -- Installation-Functions.ps1
    > xmlconfig
    |
    -- configfiles.xml
    
## File Descriptions   

Install-Script.ps1 – This contains the actual script body. Reads the xml files and calls the appropriate functions from Installation-Functions.ps1 as defined by the xml
Installation-Functions.ps1 – Wraps Installation-Framework.ps1 in PowerShell-style functions
Installation-Framework.ps1 – Contains classes and methods for performing install tasks. These should not be called directly and instead wrapped in Installation-Functions.ps1
Configuration Files – Contains install task definitions defined in xml

## Defining Configuration Files

### File structure

Configuration files are written in xml and are of the basic format:

        <config name="config_name">
            <task name="task_name">
                <step name="step1_name">
                    ... step information goes here
                </step>
                <step name="step2_name">
                    ... step information goes here
                </step>
            </task>
        </config>
        
Each configuration has a root named 'config', which is made up of tasks, using the tag 'task'. Then, each task is made up of steps, using the tag 'step'.
Each of the tags config, task, and step should have a name variable for logging purposes. A config can consist of any number of tasks, and a task can consist of any number of steps. 
Configs should only contain tasks, and tasks should only contain steps.

### Defining Steps

Steps should be of the format

        <step name="step1_name">
            <type>type_name_here</type>
            <field1>value</field1>
            <field2>value</field2>
            <field3>value</field3>
        </step>
        
Replacing the "field[X]" tags with the appropriate tags, explained below.

There are several types of steps which can be used to define your installations, and each of these has certain tags which must be filled out.

**file_move**

Moves a file from one location to another, relocating the original.

Required tags:
- target - The file which will be moved
- destination - the location to which the file will be moved

Example:
    
    <step name="move_file">
        <type>file_move</type>
        <target>C:\Users\johrus2\Desktop\test.txt</target>
        <destination>C:\Users\johrus2\Documents</destination>
    </step>
    

**file_copy**

Copies a file from one location to another, leaving the original in place.

Required tags:
- target - The file which will be copied
- destination - The location to which the file will be copied

Example:
    
    <step name="copy_file">
        <type>file_copy</type>
        <target>C:\Users\johrus2\Desktop\test.txt</target>
        <destination>C:\Users\johrus2\Documents</destination>
    </step>
    

**file_expand**

Extracts a zipped file using the inbuilt windows extraction tool

Required tags:
- target - The file which will be expanded
- destination - The location in which the expanded files will be placed

Example:
    
    <step name="expand_file">
        <type>file_expand</type>
        <target>C:\Users\johrus2\Desktop\test.zip</target>
        <destination>C:\Users\johrus2\Documents</destination>
    </step>
    

**file_append**

Appends text to the end of a plaintext file without overwriting the original contents. Creates the file if it does not exist.

Required tags:
- target - The file to which content will be appended
- content - The content which will be appended to the file

Example:
    
    <step name="append_file">
        <type>file_append</type>
        <target>C:\Users\johrus2\Desktop\test.txt</target>
        <content>Content to append</content>
    </step>
    

**file_write**

Writes text to a plaintext file, overwriting the original contents. Creates the file if it does not exist.

Required tags:
- target - The file to which content will be written
- content - The content which will be written to the file

Example:
    
    <step name="write_file">
        <type>file_write</type>
        <target>C:\Users\johrus2\Desktop\test.txt</target>
        <content>Content to write</content>
    </step>
    

**file_link**

Creates a link file to a given location

Required tags:
- target - The link file which will be created
- destination - The location to which the link file will point

Example:
    
    <step name="create_link">
        <type>file_link</type>
        <target>C:\Users\johrus2\Desktop\test.lnk</target>
        <content>C:\Users\johrus2\Documents</content>
    </step>
    

**file_delete**

Deletes a file

Required tags:
- target - The file which will be deleted
    
    <step name="delete_file">
        <type>file_delete</type>
        <target>C:\Users\johrus2\Desktop\test.txt</target>
    </step>
    

**file_register**

Registers a given dll file

Required tags:
- target - The file which will be registered
    
    <step name="register_file">
        <type>file_register</type>
        <target>C:\Users\johrus2\Desktop\test.dll</target>
    </step>
    

**folder_create**

Creates a folder in the given location

Required tags:
- target - The full path of the folder to be created

Example:
    
    <step name="create_folder">
        <type>folder_create</type>
        <target>C:\Users\johrus2\Desktop\NewFolder</target>
    </step>
    

**folder_delete**

Deletes a folder

Required tags:
- target - The path of the folder to be deleted
    
    <step name="delete_folder">
        <type>folder_delete</type>
        <target>C:\Users\johrus2\Desktop\DeadFolder</target>
    </step>
    

**folder_move**

Moves a folder, relocating the original

Required tags:
- target - The folder to be moved
- destination - The location to which the folder will be moved

Example:
    
    <step name="move_folder">
        <type>folder_move</type>
        <target>C:\Users\johrus2\Desktop\OldFolder</target>
        <destination>C:\Users\johrus2\Documents</destination>
    </step>
    

**folder_copy**

Copies a folder, leaving the original in place

Required tags:
- target - The folder to be copied
- destination - The location to which the folder will be copied

Example:
    
    <step name="copy_folder">
        <type>folder_copy</type>
        <target>C:\Users\johrus2\Desktop\OldFolder</target>
        <destination>C:\Users\johrus2\Documents</destination>
    </step>
    

**executable**

Runs an executable with the given arguments, if any

Required tags:
- target - The executable file to be run

Optional tags:
- arguments - The command line arguments to be passed to the executable

Example with command line arguments for a silent install of VLC:
    
    <step name="VLC Installer">
        <type>executable</type>
        <target>C:\Documents\vlcinstaller.exe</target>
        <arguments>
            /S
            /L=1033
        </arguments>
    </step>
    

Example without command line arguments, which runs the executable as if you double clicked it:
    
    <step name="VLC Installer">
        <type>executable</type>
        <target>C:\Documents\vlcinstaller.exe</target>
    </step>
    

**msi**

Runs an msi with file using msiexec with the given arguments, if any

Required tags:
- target - The msi file to be run

Optional tags:
- arguments - The command line arguments to be passed to msiexec

Example with arguments for a silent install:
    

    <step name="Edge Installer">
        <type>msi</type>
        <target>C:\Documents\MicrosoftEdgeSetup.msi</target>
        <arguments>
            /quiet
            /norestart
        </arguments>
    </step>
    

Example without arguments:
    

    <step name="Edge Installer">
        <type>msi</type>
        <target>C:\Documents\MicrosoftEdgeSetup.msi</target>
    </step>
    
NOTE: msiexec parameters are standardized and can be found here: https://docs.microsoft.com/en-us/windows/win32/msi/standard-installer-command-line-options

**message**

Displays a message to the user

Required tags:
- message - The message to be displayed

Example:
    
    
    <step name="send_message">
        <type>message</type>
        <message>Hello World!</message>
    </step>
    
### Variables and Wildcards in steps

I've added support for use of Powershell environment variables and wildcards for all tags in steps except 'type', as these are predefined.

Information on environment variables in Powershell can be found here:

https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_environment_variables?view=powershell-7.1
    
Information on wildcards in Powershell can be found here:

https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_wildcards?view=powershell-7.1

So, you can do some cool stuff like the following:

    <step name="Message step">
        <type>message</type>
        <message>
            Your computer name is:
            $env:COMPUTERNAME
        </message>
    </step>
    
    <step name="Unzip File">
        <type>file_expand</type>
        <target>$env:TEMP\win32_11gR2_client.zip</target>
        <destination>$env:TEMP\OracleInstallFiles</destination>
    </step>
    
    
    <step name="Copy Font Files">
        <type>file_copy</type>
        <target>\\fileshare\public\Fonts\*</target>
        <destination>C:\Windows\Fonts</destination>
    </step>
    

A note on file paths in arguments

When using file paths that contain spaces in argument strings, you should always enclose them in quotation marks ("").
An example of this is the following


    <step name="Notepad++ Installer">
        <type>executable</type>
        <target>\\fileshare\John\Software\InstallNotepad++.exe</target>
        <arguments>
            /S
            /D="C:\Program Files\Notepad++"
        </arguments>
    </step>


Note the quotation marks around the file path "C:\Program Files\Notepad++"

This is only true for the arguments tag. File paths as the lone value of any other tag do not need quotation marks, however they will work with them as well.
Both of the following will work:


    <target>C:\Documents\My Folder</target>
    <target>"C:\Documents\My Folder"</target>


### Configuration File Examples

Putting everything we've learned together, we can now write a very basic configuration file. The below config prints a message for the user and copies a file to the desktop from documents.
    
    <config name="Simple Config">
        <task name="Send a message">
            <step name="Message step">
                <type>message</type>
                <message>
                    Copying file from documents to the desktop
                </message>
            </step>
        </task>
        <task name="Copy file">
            <step name="Copy step">
                <type>file_copy</type>
                <target>C:\Documents\MyFile.txt<target>
                <destination>C:\Desktop</destination>
            </step>
        </task>
    </config>
    
This is a config that installs Oracle 11g 32 bit for a more complicated example
    
    <config name="Install Oracle 11g">
        <task name="Oracle 11g">
            <step name="Copy Zipped File">
                <type>file_copy</type>
                <target>\\fileshare\software\Oracle\11g\win32_11gR2_client.zip</target>
                <destination>$env:TEMP</destination>
            </step>
            <step name="Unzip File">
                <type>file_expand</type>
                <target>$env:TEMP\win32_11gR2_client.zip</target>
                <destination>$env:TEMP\OracleInstallFiles</destination>
            </step>
            <step name="Oracle 11g Installer">
                <type>executable</type>
                <target>$env:TEMP\OracleInstallFiles\client\setup.exe</target>
                <arguments>
                    -silent
                    -nowait
                    ORACLE_HOSTNAME=$env:COMPUTERNAME.domain.com
                    INVENTORY_LOCATION="C:\Program Files (x86)\Oracle\Inventory"
                    SELECTED_LANGUAGES=en
                    ORACLE_HOME=C:\Oracle\product\11.2.0\client_1
                    ORACLE_BASE=C:\Oracle
                    oracle.install.client.installType=Runtime
                    oracle.install.client.oramtsPortNumber=49152
                </arguments>
            </step>
            <step name="Copy OID Files">
                <type>file_copy</type>
                <target>\\fileshare\software\Oracle\OID Files\*.ora</target>
                <destination>C:\Oracle\product\11.2.0\client_1\network\admin</destination>
            </step>
            <step name="Delete Zip File">
                <type>file_delete</type>
                <target>$env:TEMP\win32_11gR2_client.zip</target>
            </step>
            <step name="Delete unzipped contents">
                <type>folder_delete</type>
                <target>$env:TEMP\OracleInstallFiles</target>
            </step>
        </task>
    </config>
    


