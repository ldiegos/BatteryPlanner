function log()
{
    param(
        [Parameter(Mandatory=$true)][string]$string,
        [Parameter(Mandatory=$false)][bool]$LogHost
    )

    if ($LogHost)
    {
        write-host $string
    }
    $TimeStamp = (Get-date -Format dd-MM-yyyy) + "|" + (get-date -format HHMMsstt) 
    $TimeStamp + " " + $string | out-file -Filepath $logfile -append -Force
}
