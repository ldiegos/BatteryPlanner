param ($cellType, $csvFileFullPath, $csvSeries, $series, $cellsPerPack, $outputPath)

###################################
##### INSTRUCTIONS
###################################
# -cellType : Configuration of the cells that you are using, options: 18650;21700;AGM;lifepo4
# -csvFileFullPath : Full path to the csv file (comman separated values) where all the mAh from each of the cells you want to use. Example "C:\temp\all_batteries.csv"
# -csvSeries : Full path to the series file (tab separated values) with all the series you have already created. Use the previous results from this program. Example "C:\temp\LockSeries.tsv"
# -series : Number of series to create, base on the voltage of the "cellType" the total voltage will be shown. Exmple: For 18650cells = 3.6v, then series = 4 will be 3.6*4 => 14.4v(12v with the power loss)
# -outputPath : Path to store the results of the series in csv(comma separated value) and the same information as source for -csvSeries if needed.
# 
###################################

# .\BatteryPlanner.ps1 -csvfileFullPath "E:\GoogleDrive\My Drive\Aplicaciones\PowerShell\BatteryPlanner\all_batteries.csv"
# .\BatteryPlanner.ps1 -csvfileFullPath "E:\GoogleDrive\My Drive\Aplicaciones\PowerShell\BatteryPlanner\all_batteries.csv" -series 4 -cellsPerPack 6
# .\BatteryPlanner.ps1 -cellType 18650 -csvFileFullPath "E:\GoogleDrive\My Drive\Aplicaciones\PowerShell\BatteryPlanner\Data\all_batteries.csv"  -series 3 -cellsPerPack 6
# .\BatteryPlanner.ps1 -cellType 18650 -csvFileFullPath "E:\GoogleDrive\My Drive\Aplicaciones\PowerShell\BatteryPlanner\Data\all_batteries.csv"  -series 6 -cellsPerPack 6
# .\BatteryPlanner.ps1 -cellType 18650 -csvFileFullPath "E:\GoogleDrive\My Drive\Aplicaciones\PowerShell\BatteryPlanner\Data\all_batteries.csv"  -series 12 -cellsPerPack 6 
# .\BatteryPlanner.ps1 -cellType 18650 -csvFileFullPath "E:\GoogleDrive\My Drive\Aplicaciones\PowerShell\BatteryPlanner\Data\all_batteries.csv" -csvSeries "" -series 4 
# .\BatteryPlanner.ps1 -cellType 18650 -csvFileFullPath "E:\GoogleDrive\My Drive\Aplicaciones\PowerShell\BatteryPlanner\Data\all_batteries.csv" -csvSeries "E:\GoogleDrive\My Drive\Aplicaciones\PowerShell\BatteryPlanner\Data\LockSeries.tsv" -series 4   
# .\BatteryPlanner.ps1 -cellType 18650 -csvFileFullPath "E:\GoogleDrive\My Drive\Aplicaciones\PowerShell\BatteryPlanner\Data\all_batteries.csv" -csvSeries "E:\GoogleDrive\My Drive\Aplicaciones\PowerShell\BatteryPlanner\Data\LockSeries.tsv" -series 4 -cellsPerPack 6
# .\BatteryPlanner.ps1 -cellType 18650 -csvFileFullPath "E:\GoogleDrive\My Drive\Aplicaciones\PowerShell\BatteryPlanner\Data\all_batteries.csv" -csvSeries "E:\GoogleDrive\My Drive\Aplicaciones\PowerShell\BatteryPlanner\Data\LockSeries_3S.tsv" -series 3 -cellsPerPack 6
# .\BatteryPlanner.ps1 -cellType 18650 -csvFileFullPath "E:\GoogleDrive\My Drive\Aplicaciones\PowerShell\BatteryPlanner\Data\all_batteries.csv" -csvSeries "E:\GoogleDrive\My Drive\Aplicaciones\PowerShell\BatteryPlanner\Data\LockSeries_4S.tsv_pruebas" -series 4 -cellsPerPack 6
# .\BatteryPlanner.ps1 -cellType 18650 -csvFileFullPath "E:\GoogleDrive\My Drive\Aplicaciones\PowerShell\BatteryPlanner\Data\all_batteries.csv" -csvSeries "E:\GoogleDrive\My Drive\Aplicaciones\PowerShell\BatteryPlanner\Data\LockSeries_4S_test.tsv" -series 4 -cellsPerPack 6
# .\BatteryPlanner.ps1 -cellType 18650 -csvFileFullPath "E:\GoogleDrive\My Drive\Aplicaciones\PowerShell\BatteryPlanner\Data\all_batteries.csv" -csvSeries "E:\GoogleDrive\My Drive\Aplicaciones\PowerShell\BatteryPlanner\Data\LockSeries_4S_test.tsv" -series 4 -cellsPerPack 8
# .\BatteryPlanner.ps1 -cellType 18650 -csvFileFullPath "E:\GoogleDrive\My Drive\Aplicaciones\PowerShell\BatteryPlanner\Data\AllBatteries1600-1900_20231118.csv" -series 3 -cellsPerPack 6


$showLog = $false
$showSummary = $true


$path = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
Write-Host "Current path: {$path}"
$directorypath = $path
Write-Host "Parent directory: {$directorypath}"

# Global path for generic powerShells
# $pathGlobal = (Resolve-Path $path\..\..\).Path
# $directorypathGlobal = Join-Path $pathGlobal 'NNIPS.PowerShell.Global'
# Write-Host "Global directory: {$directorypathGlobal}"

$directorypathConfig = Join-Path $directorypath '\Config\'
$directoryPathLog = Join-Path $directorypath '\Log\'

$logfile = Join-Path $directoryPathLog "$(get-date -format `"yyyyMMdd`").log"

#########################################################
##### Import functions
#########################################################
$ModAverageCapacity = Join-Path $directorypath 'Modules\AverageCapacity.ps1'
$ModSeries = Join-Path $directorypath 'Modules\Series.ps1'
$ModVAW = Join-Path $directorypath 'Modules\VAW.ps1' #Voltage methdos, amphere methods and watage methods.
$ModPrint = Join-Path $directorypath 'Modules\Print.ps1' #Print output methods
$ModLog = Join-Path $directorypath 'Modules\Log.ps1' #Print output methods

# $AzDatabaseServerMethods = Join-Path $directorypathGlobal '\Azure\Database\AzDatabaseServerMethods.ps1'
# $AzureKeyVaultMethods = Join-Path $directorypathGlobal '\Azure\KeyVault\AzKeyVaultMethods.ps1'
# $AzureStorageContainerMethods = Join-Path $directorypathGlobal '\Azure\StorageAccount\AzStorageContainer.ps1'
# . $AzDatabaseServerMethods
# . $AzureKeyVaultMethods
# . $AzureStorageContainerMethods

. $ModAverageCapacity
. $ModSeries
. $ModVAW
. $ModPrint
. $ModLog


log "Config directory: {$directorypathConfig}" $showLog 
log "Log directory: {$directoryPathLog}" $showLog 


if($cellType -eq $null)
{
    $cellType = Read-Host -Prompt "Enter the cell type: 18650|21700|lifepo4|AGM: "
    if($cellType -eq $null)
    {
        $cellType = "18650"
    }
}

if($csvFileFullPath -eq $null)
{
    [string]$csvFileFullPath = Read-Host -Prompt "Enter full path to the cells capacity csv file: E:\GoogleDrive\My Drive\Aplicaciones\PowerShell\BatteryPlanner\all_batteries.csv"
}

if( ($csvSeries -eq $null) )
{
    [string]$csvSeries = Read-Host -Prompt "Enter full path to the current series in csv(tab) file: Press ENTER if you don't have any or use something like: E:\GoogleDrive\My Drive\Aplicaciones\PowerShell\BatteryPlanner\Data\LockSeries.csv"
}

if($series -eq $null)
{
    [int]$series = Read-Host -Prompt "Enter the numer of series: example: 4|7|14 But any number is allowed: "
    if($series -eq $null)
    {
        $series = [int]4
    }
}

switch ( $cellType )
{
    "18650" {  $ConfigPath = "Config\18650.json" }
    "21700" { $ConfigPath = "Config\21700.json"  }
    "AGM" { $ConfigPath = "Config\AGM.json"  }
    "lifepo4" { $ConfigPath = "Config\lifepo4.json"  }
    Default {

        write-host "No battery config file found. Exiting!!!"

        exit 0

    } 
}

$celltypeConfiguration = Get-Content -Path $ConfigPath | ConvertFrom-Json

$list = Get-Content -Path $csvFileFullPath
# Write-Host "$list"

$mAhArray = $list.Split(",")
# Write-Host "$mAhArray"
$list = ""
# $mAhArray
# Write-Host "CSV as is: $mAhArray"
# Write-Host "---------------------------------------------------------------------------------------------------------------------"
$mAhArray = $mAhArray | Sort-Object -Descending
# Write-Host "Sorted capacity: $mAhArray"
# Write-Host "---------------------------------------------------------------------------------------------------------------------"

# $mAhArray.Count
# $mAhArray.Length
# $mAhArray.GetUpperBound(0)
# $maxCellsPerSerie = [int]($mAhArray.Count / $series)
$maxCellsPerSerie = [Math]::Floor([decimal]($mAhArray.Count / $series)) 
$totalCellsToUse = [int] $maxCellsPerSerie * $series

# # Write-Host "TotalCells: "$mAhArray.GetUpperBound(0)
# Write-Host "*********************************************************************************************************************"
# Write-Host "DATA: "
# Write-Host "*********************************************************************************************************************"
# Write-Host "Cell type: $cellType"
# # Write-Host "celltypeConfiguration.name : $($celltypeConfiguration.name)"
# Write-Host "cell nominal voltage : $($celltypeConfiguration.nominalVoltage)"
# Write-Host "cell minimun voltage : $($celltypeConfiguration.minimumVoltage)"
# Write-Host "cell maximun voltage : $($celltypeConfiguration.maximumVoltage)"
# Write-Host "cell minimun discharge voltage : $($celltypeConfiguration.limitVoltageDischarge)"
# Write-Host "cell maximun charge voltage : $($celltypeConfiguration.limitVoltageCharge)"
# Write-Host "Series already created: $csvSeries"
# Write-Host "Number of series: $series"
# Write-Host "Number of cells per pack: $cellsPerPack"
# Write-Host "Total cells in csv: "$mAhArray.Count
# Write-Host "Cells in each serie(TotalCells/series): $maxCellsPerSerie"
# Write-Host "Total cells to use: $totalCellsToUse"

log "*********************************************************************************************************************" $showSummary 
log "DATA: " $showSummary 
log "*********************************************************************************************************************" $showSummary 
log "Cell type: $cellType"  $showSummary 
# log "celltypeConfiguration.name : $($celltypeConfiguration.name)" $showLog 
log "cell nominal voltage : $($celltypeConfiguration.nominalVoltage)" $showSummary 
log "cell minimun voltage : $($celltypeConfiguration.minimumVoltage)" $showSummary 
log "cell maximun voltage : $($celltypeConfiguration.maximumVoltage)" $showSummary 
log "cell minimun discharge voltage : $($celltypeConfiguration.limitVoltageDischarge)" $showSummary 
log "cell maximun charge voltage : $($celltypeConfiguration.limitVoltageCharge)" $showSummary 
log "File with all cells: $csvFileFullPath" $showSummary 
log "Series already created: $csvSeries" $showSummary 
log "Number of series: $series" $showSummary 
log "Number of cells per pack: $cellsPerPack" $showSummary 
log "Total cells in csv: $($mAhArray.Count)" $showSummary 
log "Cells in each serie(TotalCells/series): $maxCellsPerSerie" $showSummary 
log "Total cells to use: $totalCellsToUse" $showSummary 

if($cellsPerPack -gt 1)
{
    $packsMaxPerSerie = [Math]::Floor(($maxCellsPerSerie / $cellsPerPack))
    log "Packs max in each serie: $packsMaxPerSerie" $showLog 
}
else 
{

    log "Packs max in each serie: < ignored because is less or equal to 1 >" $showLog 
    $packsMaxPerSerie = 0
}

Write-Host "*********************************************************************************************************************"

################################################################
# Clean not used cells.
################################################################
$arrCleanCellsToUse = @()
$lastUsedBatteryIndex =0
$notUsedCells = ""

for($i=0; $i-lt $totalCellsToUse; $i++)
{
    $arrCleanCellsToUse += $mAhArray[$i]
    $lastUsedBatteryIndex++
}

log "notUsedCells1: $notUsedCells" $showLog 

# Write-Host "lastUsedBatteryIndex: $lastUsedBatteryIndex"

################################################################
# Store not used cells
################################################################
if( ($csvSeries -eq $null) -or ($csvSeries -eq "") ) 
{
    for($i=$lastUsedBatteryIndex;$i -lt $mAhArray.Count; $i++)
    {
        $notUsedCells += [string]$mAhArray[$i] + ","
    }

    log "notUsedCells2: $notUsedCells" $showLog 
}

################################################################
# Sort descending and ascending
################################################################
$arrCellsMax2Min = $arrCleanCellsToUse | Sort-Object -Descending
# $arrCellsMin2Max = $arrCleanCellsToUse | Sort-Object
# Write-Host "arrCellsMax2Min: $arrCellsMax2Min"
# Write-Host "arrCellsMin2Max: $arrCellsMin2Max"

################################################################
# Create series
################################################################
$CellsPerSeries = New-Object 'int[,]' $series,$maxCellsPerSerie
# $CellsPerSeries = SeriesRawCreation $series $maxCellsPerSerie $arrCellsMax2Min $arrCellsMin2Max

if ($csvSeries -ne "")
{
    # $header3 = @("Column_1","Column_2","Column_3","Column_4")
    # $oldSeries = Import-Csv $csvSeries -header $header3 -Delimiter "`t"
    log "csvSeries: $csvSeries" $showLog 
    $oldSeries = Import-Csv $csvSeries -Delimiter "`t"
    for ($i = 1; $i -le $series; $i++)
    {
        log "oldSeries: $i - $($oldSeries.$i)" $showLog 
    }

    $CellsPerSeries = SeriesCreateFromOlder $series ([ref]$maxCellsPerSerie) $oldSeries $CellsPerSeries
    $arrCellsMax2Min = arrDeleteValuesFromArray $arrCellsMax2Min $series $maxCellsPerSerie $CellsPerSeries
    $arrCellsMax2Min = $arrCellsMax2Min | Sort-Object -Descending
    log "arrCellsMax2Min - $arrCellsMax2Min" $showLog 
}

# if ($packsMaxPerSerie -gt 1 )
# {
#     Write-Host "$maxCellsPerSerie - $packsMaxPerSerie - Result: $($maxCellsPerSerie / $packsMaxPerSerie)"
# }


$CellsPerSeries = SeriesAproach2AvgMAh $series $maxCellsPerSerie $arrCellsMax2Min $CellsPerSeries ([ref]$notUsedCells)

log "notUsedCells3: $notUsedCells" $showLog 

# printPrintSeriesInColumns $series $maxCellsPerSerie $CellsPerSeries
# printPrintTotalmAhInColumns  $series $maxCellsPerSerie $CellsPerSeries


if($cellsPerPack -gt 1)
{
    $CellsPerSeries = SeriesCleanPacksPerSerie $series $maxCellsPerSerie $cellsPerPack $packsMaxPerSerie $CellsPerSeries ([ref]$notUsedCells)
}

log "notUsedCells4: $notUsedCells" $showLog 
# Write-Host "CellsPerSeries: $CellsPerSeries"

################################################################
# Print the series information
################################################################

$TotalmAh = [int]0

log "*********************************************************************************************************************"  $showSummary 
log "SUMMARY: "  $showSummary 
log "*********************************************************************************************************************"  $showSummary 
log "Number of series: $series"  $showSummary 
log "Number of cells per pack: $cellsPerPack"  $showSummary 
log "Cells in each serie(TotalCells/series): $maxCellsPerSerie"  $showSummary 
# printPrintSeriesInLines $series $maxCellsPerSerie $CellsPerSeries
printPrintSeriesInColumns $series $maxCellsPerSerie $CellsPerSeries
printPrintTotalmAhInColumns  $series $maxCellsPerSerie $CellsPerSeries
log "Cells not used: $notUsedCells"  $showSummary 

$avgmAh = SeriesTotalmAhAvg $CellsPerSeries $series $maxCellsPerSerie

# $batteryVolts = totalVolts $nominalVolts $series
$volts = [decimal]$celltypeConfiguration.maximumVoltage
$batteryVolts = totalVolts $volts  $series
$ah = mAh2Ah($avgmAh)
$watts = wattage $batteryVolts $ah


log "`r"  $showSummary 
log "THEORICAL BATTERY RESULT: "  $showSummary 
log "Cell voltage: $volts v"  $showSummary 
log "Battery voltage: $batteryVolts v" $showSummary 
log "Battery amps per hour: $ah Ah"  $showSummary 
log "Battery watt per hour: $watts Watts/hour => $(kiloWatts $watts ) KiloWatts/hour"  $showSummary 
log "-----------------------------"  $showSummary 

$volts_min = [decimal]$celltypeConfiguration.limitVoltageDischarge
$batteryVolts_mim = totalVolts $volts_min  $series
$ah_min = mAh2Ah($avgmAh)
$watts_min = wattage $volts_min $ah_min

$volts_max = [decimal]$celltypeConfiguration.limitVoltageCharge
$batteryVolts_max = totalVolts $volts_max  $series
$ah_max = mAh2Ah($avgmAh)
$watts_max = wattage $volts_max $ah_max

$volts_used =  $volts_max - $volts_min
$ah_used = $ah_max - $ah_min
$watt_used = $watts_max - $watts_min

log "REALISTIC BATTERY RESULT: "  $showSummary 
log "Battery voltage: $batteryVolts v"  $showSummary 
log "Limit discharge: $($celltypeConfiguration.limitVoltageDischarge) v"  $showSummary 
log "Limit charge: $($celltypeConfiguration.limitVoltageCharge) v" $showSummary 
log "Volts to use: $volts_used v"  $showSummary 
log "Battery amps per hour: $ah_used Ah"  $showSummary 
log "Battery watt per hour: $watt_used Watts/hour => $(kiloWatts $watt_used ) KiloWatts/hour" $showSummary 


exit 0
# SeriesTotalmAhAvg $CellsPerSeries $series $maxCellsPerSerie
# arrAvgCapacity($CellsPerSeries)

################################################################
# End program
################################################################



# ################################################################
# # Order from max capacity to less capacity
# ################################################################
# Write-Host "Sort capacity-->"
# # Write-Host "$CellsPerSeries"
# $sorted =@()
# # $newCellsPerSeries = New-Object 'int[,]' $series,$maxCellsPerSerie

# for ($i = 0; $i -lt $series; $i++)
# {
#     # Write-Host "Sort capacity: i: $i"
#     for ($j = 0; $j -lt $maxCellsPerSerie;$j++)
#     {
#         # Write-Host "Sort capacity: j: $j"
#         $sorted += [int]$CellsPerSeries[$i,$j]
#     }

#     Write-Host "Sort capacity Unsorted-$sorted"

#     $sorted = $sorted | Sort-Object -Descending

#     Write-Host "Sort capacity sorted-$sorted"


#     # Write-Host "sorted: $sorted"

#     for ($j = 0; $j -lt $maxCellsPerSerie;$j++)
#     {
#         $CellsPerSeries[$i,$j] = $sorted[$j]
#     }

#     $sorted=@()
# }

################################################################
# Check if there is any serie with less cells.
################################################################
# Write-Host "Check series with less cells-->"

$emptyPosition = $false

for($i = 0; $i -lt $series; $i++)
{
    for($j = 0; $j -lt $maxCellsPerSerie; $j++)
    {
        if ($CellsPerSeries[$i, $j] -eq 0)
        {
            $emptyPosition = $true
        }
    }
}
# Write-Host "emptyPosition: $emptyPosition "

if($emptyPosition -eq $true)
{
    # Write-Host "Cleaning last positions: $maxCellsPerSerie"
    # for($i = 0; $i -lt $series; $i++)
    # {    
    #     for($j = $maxCellsPerSerie ; $j -gt 0; $j-- )
    #     {
    #         if($CellsPerSeries[$i, $j] -gt 0)
    #         {
    #             $notUsedCells += [string]$CellsPerSeries[$i, $j ] + ","
    #             $CellsPerSeries[$i, $j] = 0
    #         }
    #     }
    # }
}

# exit 0

# for ($i =0;$i -lt $totalCellsToUse;$i++)
# {
#     $cell = $mAhArray[$i]

#     $index = $seriepos % $series
#     $cellIndex = $cellpos % $maxCellsPerSerie
#     # Write-Host "Index: $index"
#     # Write-Host "cellIndex: $cellIndex"
#     # Write-Host "cell: $cell"


#     # $arrTemp = $CellsPerSeries[$index].split(",")
#     # if($arrTemp.Count -lt $maxCellsPerSerie)
#     # {
#     #     $CellsPerSeries[$index][$cellIndex] = $cell
#     # }

#     $CellsPerSeries[$index , $cellIndex] = $cell
#     # $arrTemp = @()
#     $seriepos++
#     if($index -eq $series-1)
#     {
#         $cellpos++
#     }
# }


$halfCells = $totalCellsToUse /2

write-host $halfCells

for ($i =0;$i -lt $halfCells;$i++)
{
    $row = $seriepos % $series
    $column =

    Write-Host "index: $row"
    Write-Host "column: $column"

    $column1 = $cellpos
    $column2 = $cellpos+1
    Write-Host "column1: $column1"
    Write-Host "column2: $column2"

    $cellMax = $mAhArray[$i]
    Write-Host "cellMax: $cellMax"
    $newCellsPerSeries[$row , $column1] = $cellMax
    if($cellpos -lt ($maxCellsPerSerie-1))
    {
        $cellMin = $mAhArray[$mAhArray.GetUpperBound(0)-$i]
        Write-Host "cellMin: $cellMin"
        $newCellsPerSeries[$row , $column2] = $cellMin
    }

    Write-Host "newCellsPerSeries: $newCellsPerSeries"

    $seriepos++
    if($row -eq $series-1)
    {
        $cellpos+=2
    }
}

write-host $newCellsPerSeries



# foreach ($cell in $mAhArray) {
#     $index = $seriepos % $series
#     $cellIndex = $cellpos % $maxCellsPerSerie
#     Write-Host "Index: $index"
#     Write-Host "cellIndex: $cellIndex"
#     Write-Host "cell: $cell"


#     # $arrTemp = $CellsPerSeries[$index].split(",")
#     # if($arrTemp.Count -lt $maxCellsPerSerie)
#     # {
#     #     $CellsPerSeries[$index][$cellIndex] = $cell
#     # }

#     $CellsPerSeries[$index , $cellIndex] = $cell
#     # $arrTemp = @()
#     $seriepos++
#     if($index -eq $series-1)
#     {
#         $cellpos++
#     }
# }

# foreach($row in $CellsPerSeries)
# {
#     Write-Host $row[0]
# }

$TotalmAh = 0

for ($i = 0; $i -lt $series; $i++)
{
    for ($j = 0; $j -lt $maxCellsPerSerie;$j++)
    {
        $TotalmAh += $newCellsPerSeries[$i,$j]
        $groupCell += [string]$newCellsPerSeries[$i,$j] + ","
    }

    Write-Host "Serie[$i]: $groupCell - TotalmAh: $TotalmAh"
    $groupCell = ""
    $TotalmAh = 0
}

$arrSeriesTotalCapacity = @(35569,35556,35555,35543,35544)
avgCapacity $arrSeriesTotalCapacity

# $CellsPerSeries[0,0]

# $CellsPerSeries[0]

# Write-Host "CellsPerSeries: $CellsPerSeries"

# $CellsPerSeries | ForEach-Object {$_ -join "`t"}

# foreach ($b in $CellsPerSeries) {"$b"}

# Write-Host "kk"

# $CellsPerSeries|ForEach-Object{"$_"}

# Write-Host "00"
# $CellsPerSeries | ForEach-Object {$_ -join "`t"}


# $a= ,@(1,2,3)
# $a+=,@(4,5,6)
# $a|%{"$_"}
