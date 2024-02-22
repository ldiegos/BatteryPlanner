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

function printPrintSeriesInColumns($series, $maxCellsPerSerie,$CellsPerSeries)
{
    $printHeader = ""
    $printSeries = ""

    for ($serie = 0; $serie -lt $series; $serie ++)
    {
        $printHeader += [string]"$($serie + 1)`t"
    }

    log "$printHeader" $true

    for ($j = 0; $j -lt $maxCellsPerSerie;$j++)
    {
        for ($i = 0; $i -lt $series; $i++)
        {       
            $printSeries += [string]"$($CellsPerSeries[$i,$j])`t"
        }
        if( ($j +1 )-ne $maxCellsPerSerie )
        {
            $printSeries += "`n"
        }
        
    }  

    log "$printSeries" $true
    Write-Host "--------------"


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