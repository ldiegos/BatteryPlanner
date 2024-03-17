function SeriesRawCreation ($series , $maxCellsPerSerie , $arrCellsMax2Min , $arrCellsMin2Max)
{
    $showLog = $false

    log "SeriesRawCreation -->" $showLog

    $seriepos = 0
    $cellpos = 0

    $halfCells = $arrCellsMax2Min.Count /2

    $CellsPerSeries = New-Object 'int[,]' $series,$maxCellsPerSerie

    # write-host $halfCells
    log "SeriesRawCreation - halfCells: $halfCells" $showLog

    for ($i =0;$i -lt ($halfCells+2);$i++)
    {
        $row = $seriepos % $series

        $column1 = $cellpos
        $column2 = $cellpos+1

        $cellMax = $arrCellsMax2Min[$i]
        # log "SeriesRawCreation - cellMax: $cellMax" $showLog
        $CellsPerSeries[$row , $column1] = $cellMax
        if($maxCellsPerSerie -ne ($cellpos+1) )
        {
            $cellMin = $arrCellsMin2Max[$i]
            # log "SeriesRawCreation - cellMin: $cellMin" $showLog   
            $CellsPerSeries[$row , $column2] = $cellMin
        }
        
        $seriepos++
        if($row -eq $series-1)
        {
            if($maxCellsPerSerie -ne ($cellpos+1) )
            {
                $cellpos+=2 
            }
            else {
                $cellpos++ 
            }
        }

        log "SeriesRawCreation - CellsPerSeries: $CellsPerSeries" $showLog
    }

    log "SeriesRawCreation --<" $showLog

    return ,$CellsPerSeries  #To return arrays without changes.

}

<#
.SYNOPSIS
    For already created series, start from here the final result

#>
function SeriesCreateFromOlder($series , [ref]$maxCellsPerSerie , $oldSeries, $CellsPerSeries)
{
    $showLog = $false

    log "SeriesCreateFromOlder -->" $showLog

    log "SeriesCreateFromOlder - series: $series - maxCellsPerSerie: $($maxCellsPerSerie.Value) - oldSeries: $oldSeries - CellsPerSeries: $CellsPerSeries" $showLog

    # for ($i = 1 ; $i -le $series; $i++)
    # {
    #     log "$i : $($oldSeries.$i)"
    # }

    # log "SeriesCreateFromOlder - $($maxCellsPerSerie.Value)"

    # $maxCellsPerSerie.Value = 0

    # foreach ($data in $oldSeries.1)
    # {
    #     $maxCellsPerSerie.Value++
    # }

    #Test if the old series are greater than the max series calculation
    log "SeriesCreateFromOlder - oldSeries.GetUpperBound(0) = $($oldSeries.GetUpperBound(0))" $showLog    
    log "SeriesCreateFromOlder - oldSeries.Count = $($oldSeries.Count)" $showLog    
    log "SeriesCreateFromOlder - total = $($oldSeries.GetUpperBound(0)+1)" $showLog    
    log "SeriesCreateFromOlder - maxCellsPerSerie = $($maxCellsPerSerie.Value)" $showLog    
    
    if(($oldSeries.Count) -gt $maxCellsPerSerie.Value)
    {
        log "SeriesCreateFromOlder - oldSeries greater than maxCellsPerSerie " $showLog    

        $maxCellsPerSerie.Value = $oldSeries.Count
    }    

    log "SeriesCreateFromOlder - maxCellsPerSerie.Value = $($maxCellsPerSerie.Value)" $showLog    


    $CellsPerSeries = New-Object 'int[,]' $series,$maxCellsPerSerie.Value


    for ($i=0; $i -lt $series; $i++)
    {
        # for($j = 0; $j -lt $maxCellsPerSerie.Value; $j++)
        for($j = 0; $j -lt $oldSeries.Count; $j++)        
        {
            # $CellsPerSeries[$i,$j] = $oldSeries[$j].($i+1)

            if($oldSeries[$j].($i+1) -ne $null)
            {
                $CellsPerSeries[$i,$j] = $oldSeries[$j].($i+1)
            }
        }
    }


    log "SeriesCreateFromOlder - maxCellsPerSerie: $($maxCellsPerSerie.Value)" $showLog
    log "SeriesCreateFromOlder - CellsPerSeries: $CellsPerSeries" $showLog

    log "SeriesCreateFromOlder --<" $showLog

    return ,$CellsPerSeries  #To return arrays without changes.

}

<#
.SYNOPSIS
    Create the series maintaining the average capacity between them.

#>
function SeriesAproach2AvgMAh($series , [ref]$maxCellsPerSerie , $arrCellsMax2Min, $CellsPerSeries, [ref]$notUsedCells )
{
    $showLog = $false

    log "SeriesAproach2AvgMAh -->" $showLog

    # $CellsPerSeries = New-Object 'int[,]' $series,$maxCellsPerSerie    

    # Write-Host "SeriesAproach2AvgMAh: series: $series" 
    # Write-Host "SeriesAproach2AvgMAh: arrCellsMax2Min: $arrCellsMax2Min" 
    
    log "SeriesAproach2AvgMAh - CellsPerSeries: $CellsPerSeries" $showLog
    log "SeriesAproach2AvgMAh - arrCellsMax2Min: $arrCellsMax2Min" $showLog
    log "SeriesAproach2AvgMAh - notUsedCells:  $($notUsedCells.Value)" $showLog
    log "SeriesAproach2AvgMAh - maxCellsPerSerie:  $($maxCellsPerSerie.Value)" $showLog

    
    $hashTotalmAhPerSerie = @{}
    $initial = $false
    $serieInitial = 0

    # for ($i=0;$i -lt $series ; $i++)
    # {
    #     $hashTotalmAhPerSerie.Add($i, [int]0)   
    #     # Write-Host "hashTotalmAhPerSerie: $($hashTotalmAhPerSerie.Count)" 
    # }
    # Write-Host "SeriesAproach2AvgMAh: hashTotalmAhPerSerie.Count: $($hashTotalmAhPerSerie.Count)" 

    # ForEach ($item in $hashTotalmAhPerSerie.Keys) {
    #     Write-Output "Key = $item"
    #     Write-Output "Value = $($hashTotalmAhPerSerie[$item])"
    #     Write-Output '----------'
    # }

    if($CellsPerSeries[0,0] -eq 0)
    {
        $initial = $true
    }

    # Get the first cells capacity and asign directly to the total mAh hash if empty
    if($initial)
    {
        log "SeriesAproach2AvgMAh - Initial array is empty" $showLog

        for ($i=0; $i -lt $series; $i++)
        {
            # Write-Output "$arrCellsMax2Min[$i]"
            $hashTotalmAhPerSerie.Add($i, $arrCellsMax2Min[$i])        
            $CellsPerSeries[$i,0] = $arrCellsMax2Min[$i]
        }
    }
    else 
    {
        log "SeriesAproach2AvgMAh - There is already some mAh in the current configuration" $showLog

        #Sum all the values from each serie into the $hashTotalmAhPerSerie
        $hashTotalmAhPerSerie = hashSumAllValuesFromArray $CellsPerSeries $series $maxCellsPerSerie

        log "SeriesAproach2AvgMAh - There is already some mAh in the current configuration" $showLog
    }

    for ($totalPerSerie=0; $totalPerSerie -lt $series; $totalPerSerie++)
    {
        log "SeriesAproach2AvgMAh - hashTotalmAhPerSerie: $totalPerSerie : $($hashTotalmAhPerSerie[$totalPerSerie])" $showLog
    }     

    
    # ForEach ($item in $hashTotalmAhPerSerie.Keys) {
    #     Write-Host "Key = $item"
    #     Write-Host "Value = $($hashTotalmAhPerSerie[$item])"
    #     Write-Host '----------'
    # }

    #Continue with the rest of the cells, where the total capacity is less than the average.
    $serieIndex = 0;
    $avgCapacity = 0
    $positionFound = $false

    if($initial)
    {
        $serieInitial = $series
    }
    else 
    {
        $serieInitial = 0
    }

    # Write-Host "SeriesAproach2AvgMAh: serieInitial : $serieInitial "
    # Write-Host "SeriesAproach2AvgMAh: .Count : $($arrCellsMax2Min.Count) "

    $hashEmptySpaces = @{}
 
    for ($i=($serieInitial); $i -lt $arrCellsMax2Min.Count; $i++)
    {
        log "SeriesAproach2AvgMAh - foreach i: $i" $showLog

        if($arrCellsMax2Min[$i] -ne 0)
        {
            # Write-Host "SeriesAproach2AvgMAh: arrCellsMax2Min: $($arrCellsMax2Min[$i])"

            $hashEmptySpaces = SearchForSeriesWithEmptySpaces $CellsPerSeries $series $maxCellsPerSerie            

            $cellmAh = $arrCellsMax2Min[$i]
            $avgCapacity = hashAvgCapacity($hashTotalmAhPerSerie)
            # Write-Host "SeriesAproach2AvgMAh: avgCapacity: $avgCapacity" 

            $serieIndex = hashMinValue $hashTotalmAhPerSerie $avgCapacity
            # Write-Host "SeriesAproach2AvgMAh: serieIndex: $serieIndex"

            log "SeriesAproach2AvgMAh - serieIndex: $serieIndex" $showLog

            if ( ! $hashEmptySpaces.ContainsKey($serieIndex)) 
            {
                # Write-Host "SeriesAproach2AvgMAh: hashEmptySpaces NOT contains the index: $serieIndex"
                log "SeriesAproach2AvgMAh - hashEmptySpaces NOT contains the index: $serieIndex" $showLog

                $newIndex = 0
                foreach ($space in $hashEmptySpaces.Keys)
                {
                    # Write-Host "SeriesAproach2AvgMAh: serieIndex: $space - $($hashEmptySpaces[$space])"

                    if ( $newIndex -eq 0)
                    {
                        $newIndex = $space
                        # Write-Host "SeriesAproach2AvgMAh: serieIndex: initial $space - $($hashEmptySpaces[$space]) - newIndex = $newIndex"
                    }
                    else
                    {                        
                        if ($hashEmptySpaces[$space] -gt $newIndex)
                        {
                            $newIndex = $space
                            # Write-Host "SeriesAproach2AvgMAh: serieIndex: greater than $space - $($hashEmptySpaces[$space])- newIndex = $newIndex"
                        }
                    }
                }

                $serieIndex = $newIndex
            }
            else
            {            
                log "SeriesAproach2AvgMAh - hashEmptySpaces contains the index: $serieIndex" $showLog       
            }

            # Write-Host "SeriesAproach2AvgMAh: serieIndex: $serieIndex"

            $total = [int]$hashTotalmAhPerSerie[$serieIndex]
            log "SeriesAproach2AvgMAh - current mAh total in serie: $total " $showLog 
            log "SeriesAproach2AvgMAh - new mAh to add: $cellmAh " $showLog             
            $total += [int]$cellmAh
            $hashTotalmAhPerSerie.Set_Item($serieIndex, $total)
            
            log "SeriesAproach2AvgMAh - new mAh total in serie: $total " $showLog           
            
            log "SeriesAproach2AvgMAh - hashTotalmAhPerSerie.Set_Item: $serieIndex - $total " $showLog 
            
            for ($totalPerSerie=0; $totalPerSerie -lt $series; $totalPerSerie++)
            {
                log "SeriesAproach2AvgMAh - hashTotalmAhPerSerie: $totalPerSerie : $($hashTotalmAhPerSerie[$totalPerSerie])" $showLog
            }                 
            
            # Write-Host "SeriesAproach2AvgMAh: CellsPerSeries before: $CellsPerSeries"

            $CellsPerSeries = arrAddValueToMatrixLastPosition $maxCellsPerSerie $CellsPerSeries $serieIndex $cellmAh ([ref]$positionFound)
            # Write-Host "SeriesAproach2AvgMAh: positionFound after: $($positionFound)"
            log "SeriesAproach2AvgMAh: : positionFound after: $($positionFound)" $showLog

            # If the current series are at the end, where no more positions with zero, but we continue having more cells to process then, start resizing the arrays.
            if($positionFound -ne $true)
            {
            
                $notUsedCells.Value += "$($cellmAh),"
                Write-Host "SeriesAproach2AvgMAh: notUsedCells after: $($notUsedCells.Value)"
                log "SeriesAproach2AvgMAh: notUsedCells after: $($notUsedCells.Value)" $showLog                
            }

            # Write-Host "SeriesAproach2AvgMAh: CellsPerSeries after: $CellsPerSeries"

            # Write-Host "------------------------------------------------------------------------------------"
            
            $serieIndex = 0
        } #if($arrCellsMax2Min[$i] -ne 0)                
    } #for ($i=($serieInitial); $i -lt $arrCellsMax2Min.Count; $i++)

    log "SeriesAproach2AvgMAh: arrAddValueToMatrixLastPosition: $CellsPerSeries" $showLog
    log "SeriesAproach2AvgMAh: CellsPerSeries.GetUpperBound(0) $($CellsPerSeries.GetUpperBound(0))" $showLog        

    for ($serie = 0; $serie -lt $series; $serie++)
    {
        for ($column = 0; $column -lt $CellsPerSeries.GetUpperBound(0); $column++)        
        {
            log "SeriesAproach2AvgMAh: arrAddValueToMatrixLastPosition: $($CellsPerSeries[$serie,$column])"  $showLog
        }
    }    

    for ($totalPerSerie=0; $totalPerSerie -lt $series; $totalPerSerie++)
    {
        log "SeriesAproach2AvgMAh - hashTotalmAhPerSerie: $totalPerSerie : $($hashTotalmAhPerSerie[$totalPerSerie])" $showLog
    }   

    log "SeriesAproach2AvgMAh - indexUsedCell: $indexUsedCell" $showLog
    log "SeriesAproach2AvgMAh --<" $showLog

    return ,$CellsPerSeries  #To return arrays without changes.

}

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.EXAMPLE
An example

.NOTES
General notes
#>
function SearchForSeriesWithEmptySpaces($CellsPerSeries , $series, $maxCellsPerSerie)
{
    $hashEmptySeries =  @{}
    $showLog = $false

    log "SearchForSeriesWithEmptySpaces -->" $showLog

    for ($serie = 0; $serie -lt $series; $serie++)
    {
        for($cell = 0; $cell -lt $maxCellsPerSerie.Value; $cell++)
        {
            if ($CellsPerSeries[$serie, $cell] -eq 0)
            {
                if ( ($hashEmptySeries[$serie] -eq $null) )
                {
                    $hashEmptySeries.Add($serie, 1)    
                    log "SearchForSeriesWithEmptySpaces - add serie: $serie -  total:  1 "  $showLog
                    # log "SearchForSeriesWithEmptySpaces - add"  $showLog
                }
                else 
                {   
                    $total = $hashEmptySeries[$serie]++
                    $total ++
                    $hashEmptySeries.Set_Item($serie, $total)
                    # log "SearchForSeriesWithEmptySpaces - update: serie: $serie -  total: $total "  $showLog
                    # log "SearchForSeriesWithEmptySpaces - update"  $showLog
                }            
            }
        }        
    }

    ForEach ($item in $hashEmptySeries.Keys) {
        log "SearchForSeriesWithEmptySpaces - Key = $item" $showLog
        log "SearchForSeriesWithEmptySpaces - Value = $($hashEmptySeries[$item]) " $showLog
        log "SearchForSeriesWithEmptySpaces - ----------" $showLog
    }

    log "SearchForSeriesWithEmptySpaces --<"  $showLog


    return ,$hashEmptySeries
}

<#
.SYNOPSIS
    Summ all the capacity of the serie.

#>
function SeriesTotalmAhAvg($CellsPerSeries, $series, $maxCellsPerSerie)
{
    $showLog = $false

    log "SeriesTotalmAhAvg -->" $showLog

    $avgCapacity = 0

    $arrTotal = @()

    for ($i = 0; $i -lt $series; $i++)
    {
        $TotalmAh = 0

        for ($j = 0; $j -lt $maxCellsPerSerie;$j++)
        {
            $TotalmAh += [int]$CellsPerSeries[$i,$j]
        }  
        $arrTotal += $TotalmAh
    }
    
    log "SeriesTotalmAhAvg - arrTotal:  $arrTotal"  $showLog
    
    
    $TotalmAh = 0

    for($i =0 ; $i -lt $series; $i++)
    {
        $TotalmAh += $arrTotal[$i]
    }
    
    log "SeriesTotalmAhAvg - TotalmAh:  $TotalmAh"  $showLog


    $avgCapacity = ($TotalmAh / $series)

    log "SeriesTotalmAhAvg --<"  $showLog

    return $avgCapacity

}

<#
.SYNOPSIS
    Delete cells that exceed the number of cells per pack, so there is no orphan cell without a package
    the orphan cells will be added to the notUsedCells
#>
function SeriesCleanPacksPerSerie($series , $maxCellsPerSerie , $cellsPerPack , $packsMaxPerSerie, $CellsPerSeries , [ref]$notUsedCells)
{
    $showLog = $false
    
    log "SeriesCleanPacksPerSerie -->" $showLog
    log "SeriesCleanPacksPerSerie - cellsPerPack: $cellsPerPack"  $showLog
    log "SeriesCleanPacksPerSerie - Packs: $packsMaxPerSerie"  $showLog
    log "SeriesCleanPacksPerSerie - notUsedCells: $($notUsedCells.Value)"  $showLog

    $cells = $($packsMaxPerSerie * $cellsPerPack)
    $cellsNotUsePerSerie = $($maxCellsPerSerie - $cells)

    log "SeriesCleanPacksPerSerie - Total cells per serie = $cells"  $showLog
    log "SeriesCleanPacksPerSerie - Total cells not used per serie = $cellsNotUsePerSerie"  $showLog

    for ($serie = 0 ; $serie -lt $series; $serie++)
    {
        for($cell = 0; $cell -lt $cellsNotUsePerSerie; $cell++)
        {
            $lastCell = ($maxCellsPerSerie - 1) - $cell
            log "SeriesCleanPacksPerSerie - lastCell = $lastCell"  $showLog
            $notUsedCells.Value += "$($CellsPerSeries[$serie, $lastCell]),"
            log "SeriesCleanPacksPerSerie - notUsedCells.Value = $($notUsedCells.Value)"  $showLog
            $CellsPerSeries[$serie, $lastCell] = 0
        }
    }

    log "SeriesCleanPacksPerSerie --<"  $showLog

    return ,$CellsPerSeries  #To return arrays without changes.
}