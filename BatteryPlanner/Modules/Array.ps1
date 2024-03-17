function resizeBidimensionalArray ($lines, $columns, $originalArray)
{
    $showLog = $false

    log "resizeBidimensionalArray -->" $showLog 
    log "resizeBidimensionalArray - lines: $lines - columns: $columns - originalArray: $originalArray" $showLog 

    $newArray = New-Object 'int[,]' $lines, $columns

    for ($i=0; $i -lt $lines; $i++)
    {
        for($j = 0; $j -lt $columns; $j++)        
        {
            # log "resizeBidimensionalArray - i : $i - j : $j" $showLog 

            if($originalArray[$i,$j] -ne $null)
            {
                $newArray[$i,$j] = $originalArray[$i,$j]
            }
        }
    }

    log "resizeBidimensionalArray --<" $showLog 

    return $newArray
}

