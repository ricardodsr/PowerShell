# Find commands
Get-Command about_* # alias: gcm
Get-Command -Verb Add
Get-Alias ps
Get-Alias -Definition Get-Process

Get-Help ps | less # alias: help
ps | Get-Member # alias: gm

Show-Command Get-WinEvent # Display GUI to fill in the parameters

Update-Help # Run as admin



###################################################If you are uncertain about your environment########################################################
Get-ExecutionPolicy -List
Set-ExecutionPolicy AllSigned
# Execution policies include:
# - Restricted: Scripts won't run.
# - RemoteSigned: Downloaded scripts run only if signed by a trusted publisher. 
# - AllSigned: Scripts need to be signed by a trusted publisher.
# - Unrestricted: Run all scripts.
help about_Execution_Policies # for more info

# Current PowerShell version:
$PSVersionTable

# Calling external commands, executables, 
# and functions with the call operator.
# Exe paths with arguments passed or containing spaces can create issues.
C:\Program Files\dotnet\dotnet.exe
# The term 'C:\Program' is not recognized as a name of a cmdlet,
# function, script file, or executable program.
# Check the spelling of the name, or if a path was included, 
# verify that the path is correct and try again

"C:\Program Files\dotnet\dotnet.exe"
C:\Program Files\dotnet\dotnet.exe    # returns string rather than execute

&"C:\Program Files\dotnet\dotnet.exe --help"   # fail
&"C:\Program Files\dotnet\dotnet.exe" --help   # success
# Alternatively, you can use dot-sourcing here
."C:\Program Files\dotnet\dotnet.exe" --help   # success

# the call operator (&) is similar to Invoke-Expression, 
# but IEX runs in current scope.
# One usage of '&' would be to invoke a scriptblock inside of your script.
# Notice the variables are scoped
$i = 2
$scriptBlock = { $i=5; Write-Output $i }
& $scriptBlock # => 5
$i # => 2

invoke-expression ' $i=5; Write-Output $i ' # => 5
$i # => 5

# Alternatively, to preserve changes to public variables
# you can use "Dot-Sourcing". This will run in the current scope.
$x=1
&{$x=2};$x # => 1

.{$x=2};$x # => 2


# Remoting into computers is easy.
Enter-PSSession -ComputerName RemoteComputer

# Once remoted in, you can run commands as if you're local.
RemoteComputer\PS> Get-Process powershell

<#
Handles  NPM(K)    PM(K)      WS(K)     CPU(s)     Id  SI ProcessName                                             
-------  ------    -----      -----     ------     --  -- -----------                                             
   1096      44   156324     179068      29.92  11772   1 powershell                                              
    545      25    49512      49852             25348   0 powershell 
#>
RemoteComputer\PS> Exit-PSSession

<#
 Powershell is an incredible tool for Windows management and Automation.
 Let's take the following scenario:
 You have 10 servers.
 You need to check whether a service is running on all of them.
 You can RDP and log in, or PSSession to all of them, but why?
 Check out the following
#>

$serverList = @(
    'server1',
    'server2',
    'server3',
    'server4',
    'server5',
    'server6',
    'server7',
    'server8',
    'server9',
    'server10'
)

[scriptblock]$script = {
    Get-Service -DisplayName 'Task Scheduler'
}

foreach ($server in $serverList) {
    $cmdSplat = @{
        ComputerName  = $server
        JobName       = 'checkService'
        ScriptBlock   = $script
        AsJob         = $true
        ErrorAction   = 'SilentlyContinue'
    }
    Invoke-Command @cmdSplat | Out-Null
}

<#
 Here we've invoked jobs across many servers.
 We can now Receive-Job and see if they're all running.
 Now scale this up 100x as many servers :)
#>