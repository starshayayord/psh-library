cls
function HttpGetCred {
param (
[string]$url
)
	$webclient = new-object System.Net.WebClient
	$webclient.Credentials = new-object System.Net.NetworkCredential('login', 'password')
	return [xml]$webclient.DownloadString($url)
}
$AgentCPUHash = @{}
$webpage = HttpGetCred -url 'https://tcurl.com/app/rest/agents?locator=connected:true,authorized:true'
[int[]]$IDs = $webpage.agents.agent.id
foreach ($id in $IDs)
{
	$webpage = HttpGetCred -url "https://tcat.skbkontur.ru/app/rest/agents/id:$id"
	[string]$AgentName = $webpage.agent.name
	[int]$AgentCPU = $webpage.agent.properties.property | ? {$_.name -eq 'system.teamcity.agent.cpuBenchmark'} | select -ExpandProperty Value
	$AgentCPUHash.Add($AgentName, $AgentCPU)
}
$AgentCPUHash.GetEnumerator() | sort -Property Value