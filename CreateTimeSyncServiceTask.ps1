#ServerName to install task
$ServerName = 'ICAT01'
# The name of the scheduled task
$TaskName = "Time Syncronization Service"
# The description of the task
# The Task Action command
$TaskCommand = "C:\Windows\System32\w32tm.exe"
# The Task Action command argument
$TaskArg = "/resync"
 
# The time when the task starts, for demonstration purposes we run it 1 minute after we created the task
$TaskStartTime = [datetime]::Now.AddMinutes(1) 
 
# attach the Task Scheduler com object
$service = new-object -ComObject("Schedule.Service")
# connect to the local machine. 
# http://msdn.microsoft.com/en-us/library/windows/desktop/aa381833(v=vs.85).aspx
$service.Connect($ServerName)
$rootFolder = $service.GetFolder("\Microsoft\Windows\Time Synchronization")
 
$TaskDefinition = $service.NewTask(0) 
$TaskDefinition.Settings.Enabled = $true
$TaskDefinition.Settings.AllowDemandStart = $true
$TaskDefinition.Principal.RunLevel = 1
 
$triggers = $TaskDefinition.Triggers
#http://msdn.microsoft.com/en-us/library/windows/desktop/aa383915(v=vs.85).aspx
$trigger = $triggers.Create(1) # Creates a "One time" trigger
$trigger.Repetition.Interval = "PT5M"
$trigger.StartBoundary = $TaskStartTime.ToString("yyyy-MM-dd'T'HH:mm:ss")
$trigger.Enabled = $true
 
# http://msdn.microsoft.com/en-us/library/windows/desktop/aa381841(v=vs.85).aspx
$Action = $TaskDefinition.Actions.Create(0)
$action.Path = "$TaskCommand"
$action.Arguments = "$TaskArg"
 
#http://msdn.microsoft.com/en-us/library/windows/desktop/aa381365(v=vs.85).aspx
$rootFolder.RegisterTaskDefinition("$TaskName",$TaskDefinition,6,"System",$null,5)