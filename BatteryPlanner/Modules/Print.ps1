function printPrintSeriesInLines($series, $maxCellsPerSerie,$CellsPerSeries)
{
    for ($i = 0; $i -lt $series; $i++)
    {
        for ($j = 0; $j -lt $maxCellsPerSerie;$j++)
        {
            $TotalmAh += [int]$CellsPerSeries[$i,$j]
            $groupCell += [string]$CellsPerSeries[$i,$j] + ","
        }  

        Write-Host "Serie[$i]: $groupCell - TotalmAh: $TotalmAh"
        $groupCell = ""
        $TotalmAh = 0
    }
}

function printPrintSeriesInColumns($series, $maxCellsPerSerie, $CellsPerSeries, $cellsPerPack , [ref]$packsMaxPerSerie )
{
    $printHeader = ""
    $printSeries = ""

    $showLog = $false

    log "printPrintSeriesInColumns- ->"  $showLog   

    log "printPrintSeriesInColumns- series: $series - maxCellsPerSerie: $maxCellsPerSerie - cellsPerPack: $cellsPerPack" $showLog    

    for ($serie = 0; $serie -lt $series; $serie ++)
    {
        $printHeader += [string]"$($serie + 1)`t"
    }

    log "$printHeader" $true

    $count2line = 0

    for ($j = 0; $j -lt $maxCellsPerSerie;$j++)
    {
        for ($i = 0; $i -lt $series; $i++)
        {       
            $printSeries += [string]"$($CellsPerSeries[$i,$j])`t"

            # log "printPrintSeriesInColumns- $count2line = $cellsPerPack -and $i = $series"  $showLog   

            if( ( ($j+1) % $cellsPerPack -eq 0) -and ($i -eq $series-1) )
            {                
                $count2line++                
                $printSeries += [string]"`n $count2line -"
            }

        }
        if( ($j +1 )-ne $maxCellsPerSerie )
        {
            $printSeries += "`n"
        }

    }  

    $packsMaxPerSerie.Value = $count2line    

    log "$printSeries" $true
    log "printPrintSeriesInColumns- -<"  $showLog
}

function printPrintTotalmAhInColumns($series, $maxCellsPerSerie,$CellsPerSeries)
{
    $arrTotalmAh = @()
    # $printTotal = ""   
    
    for ($serie = 0; $serie -lt $series ; $serie ++)
    {
        $arrTotalmAh += $CellsPerSeries[$serie,0]
    }
    for ($j = 1; $j -lt $maxCellsPerSerie;$j++)
    {
        for ($i = 0; $i -lt $series; $i++)
        {       
            $arrTotalmAh[$i] += $CellsPerSeries[$i,$j]
        }
    }    
    for ($i = 0; $i -lt $series ; $i ++)
    {
        $printTotal += [string]"$($arrTotalmAh[$i])`t"
    }
    Write-Host "$printTotal"

}