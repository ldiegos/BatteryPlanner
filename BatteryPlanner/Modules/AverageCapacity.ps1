function arrAvgCapacity($arrSeriesTotalCapacity)
{
    $mahTotal = 0;
    foreach($i in $arrSeriesTotalCapacity){
        $mahTotal += $i
    }
    log "arrAvgCapacity: $mahTotal"
    # return [math]::ceiling($mahTotal / $arrSeriesTotalCapacity.Length);
    return  [int]($mahTotal / $arrSeriesTotalCapacity.Length);
}

function arrAddValueToMatrixLastPosition($maxCellsPerSerie , $CellsPerSeries , $serieIndex , $cellmAh , [ref]$lastPositionFound)
{
    log "arrAddValueToMatrixLastPosition -->" 
    # Write-Host "arrAddValueToMatrixLastPosition - serieIndex: $serieIndex" 

    $lastPositionFound.Value = $false

    for($j= 0; $j -lt $maxCellsPerSerie.Value; $j++)
    {
        if ( ($CellsPerSeries[$serieIndex, $j] -eq 0) -and ($lastPositionFound.Value -ne $true) )
        {
            $CellsPerSeries[$serieIndex, $j] =  $cellmAh
            log "arrAddValueToMatrixLastPosition -$serieIndex - $j - $cellmAh" 
            $lastPositionFound.Value = $true
        }
    }

    log "arrAddValueToMatrixLastPosition -lastPositionFound: $($lastPositionFound.Value)" 
    log "arrAddValueToMatrixLastPosition --<" 

    return ,$CellsPerSeries
}

function arrDeleteValuesFromArray($arrCellsMax2Min , $series , $maxCellsPerSerie , $CellsPerSeries)
{
    $showLog = $false

    # Write-Host "arrDeleteValuesFromArray -->" 
    log "arrDeleteValuesFromArray -->" $showLog

    $found = $false
    $hashControl = @{}

    for( $k = 0 ; $k -le $arrCellsMax2Min.Count; $k++)
    {    
        # log "arrDeleteValuesFromArray - $k " $showLog
        log "arrDeleteValuesFromArray - $arrCellsMax2Min[$k] " $showLog

        for($i= 0; $i -lt $series; $i++)
        {
            # log "arrDeleteValuesFromArray - $k - $i " $showLog            
            for($j= 0; $j -lt $maxCellsPerSerie; $j++)
            {
                # log "arrDeleteValuesFromArray - $k - $i - $j " $showLog 
                # log "arrDeleteValuesFromArray - $k - $i - $j - $CellsPerSeries[$i, $j] = $arrCellsMax2Min[$k] " $showLog 

                # if ( ($CellsPerSeries[$i, $j] -eq $arrCellsMax2Min[$k]) -and ($found -ne $true) )
                if ( ($CellsPerSeries[$i, $j] -eq $arrCellsMax2Min[$k]) )
                {
                    $key = "$i-$j"

                    # log "arrDeleteValuesFromArray - $k - $i - $j -> $key" $showLog                     

                    if(!$hashControl.ContainsKey($key))
                    {
                        log "arrDeleteValuesFromArray - $k - $i - $j -> $key IS NOT CONTAIN" $showLog
                        
                        $hashControl.Add($key,0)
                        $arrCellsMax2Min[$k]=0
                    }                      
                    # $found = $true
                }
            }
        }
        # $found = $false
    }

    log "arrDeleteValuesFromArray - $arrCellsMax2Min" $showLog
    log "arrDeleteValuesFromArray --<" $showLog

    return ,$arrCellsMax2Min  #To return arrays without changes.
}

function hashAvgCapacity($hash)
{
    log "hashAvgCapacity-->" 

    $mahTotal = 0;
    foreach($i in $hash.Keys){
        $mahTotal += $hash[$i]
    }

    $avg = [int]($mahTotal / $hash.Count);
    # return [math]::ceiling($mahTotal / $arrSeriesTotalCapacity.Length);
    # log "hashAvgCapacity: mahTotal: $mahTotal ; hash.Count: $($hash.Count) ; avg: $avg"  

    log "hashAvgCapacity--<" 
    return  [int]($avg);
}

function hashMinValue($hash, $avg)
{
    log "hashMinValue -->"
    # Write-Host "avg: $avg"
    $hashSubstract = @{}
    $indexMin =0
    $subsValue = 0
    
    foreach($i in $hash.Keys)
    {
        $rest =  $hash[$i] - $avg
        $hashSubstract.Add($i,$rest)
    }
    
    # foreach($key in $hashSubstract.Keys)
    # {
    #     Write-Host "hashSubstract: $($hashSubstract[$key])"
    # }


    foreach($key in $hashSubstract.Keys)
    {
        # Write-Host "hashMinValue - Checking key: $key"
        # Write-Host "subsValue: $subsValue"

        if($subsValue -eq 0)
        {
            $subsValue = $hashSubstract[$key]            
            $indexMin = $key
        }
        if($hashSubstract[$key] -lt $subsValue)
        {
            $indexMin = $key
            $subsValue = $hashSubstract[$key]
        }

        # Write-Host "hashMinValue - hashSubstract: $($hashSubstract[$key]) "
        # Write-Host "hashMinValue - indexMin: $indexMin"
        # Write-Host "hashMinValue - subsValue: $subsValue"

    }

    # Write-Host "indexMin: $indexMin"
    log "hashMinValue --<" 
    return  [int]$indexMin
}

function hashSumAllValuesFromArray($CellsPerSeries , $series, $maxCellsPerSerie)
{
    $showLog = $false

    log "hashSumAllValuesFromArray -->" $showlog
    log "hashSumAllValuesFromArray - series: $series - maxCellsPerSerie: $($maxCellsPerSerie.Value) - CellsPerSeries : $CellsPerSeries" $showlog

    $hashTotalmAhPerSerie = @{}
    $total = 0
    $cellmAh = 0

    for($i= 0; $i -lt $series; $i++)
    {
        # Write-Host "hashSumAllValuesFromArray - $($CellsPerSeries[$i,0])"

        $hashTotalmAhPerSerie.Add($i, $($CellsPerSeries[$i,0]))

        for($j=1; $j -lt $maxCellsPerSerie.Value; $j++)
        {
            log "hashSumAllValuesFromArray - CellsPerSeries[$i,$j]: $($CellsPerSeries[$i,$j])" $showlog            

            $cellmAh = [int]$($CellsPerSeries[$i,$j])
            log "hashSumAllValuesFromArray - cellmAh: $cellmAh" $showlog
            $total = $hashTotalmAhPerSerie[$i].Value
            log "hashSumAllValuesFromArray - total: $total" $showlog
            # Write-Host "SeriesAproach2AvgMAh: total: $total"
            # Write-Host "SeriesAproach2AvgMAh: cell mAh: $cellmAh"        
            $total += [int]$cellmAh
            # Write-Host "SeriesAproach2AvgMAh: total: $total"
            log "hashSumAllValuesFromArray - $i - $j - $total" $showlog
            $hashTotalmAhPerSerie.Set_Item($i, $total)
        }
    }    

    # ForEach ($item in $hashTotalmAhPerSerie.Keys) {
    #     # Write-Host "Key = $item"
    #     # Write-Host "Value = $($hashTotalmAhPerSerie[$item])"
    #     # Write-Host '----------'
    #     log "hashSumAllValuesFromArray - $($hashTotalmAhPerSerie[$item])" $showlog
    # }

    log "hashSumAllValuesFromArray --<" $showlog

    return ,$hashTotalmAhPerSerie
}