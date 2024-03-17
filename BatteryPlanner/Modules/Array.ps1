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
            log "resizeBidimensionalArray - i : $i - j : $j - originalArray[$i,$j] - $($originalArray[$i,$j])" $showLog 

            if($originalArray[$i,$j] -ne $null)
            {
                $newArray[$i,$j] = $originalArray[$i,$j]
            }
            else 
            {
                $newArray[$i,$j] = 0
            }
        }
    }

    log "resizeBidimensionalArray - newArray : $newArray" $showLog 


    log "resizeBidimensionalArray --<" $showLog 

    return ,$newArray #To return arrays without changes.
}

# function resizeBidimensionalArray ($lines, $columns, $originalArray)
# {
#     $showLog = $false

#     log "resizeBidimensionalArray -->" $showLog 
#     log "resizeBidimensionalArray - lines: $lines - columns: $columns - originalArray: $originalArray" $showLog 

#     $newArray = New-Object 'int[,]' $lines, $columns

#     for ($i=0; $i -lt $lines; $i++)
#     {
#         # for($j = 0; $j -lt $maxCellsPerSerie.Value; $j++)
#         for($j = 0; $j -lt $columns; $j++)        
#         {
#             # $CellsPerSeries[$i,$j] = $oldSeries[$j].($i+1)
    
#             if($originalArray[$j].($i+1) -ne $null)
#             {
#                 $newArray[$i,$j] = $originalArray[$j].($i+1)
#             }
#         }
#     }

#     log "resizeBidimensionalArray --<" $showLog 

#     return $newArray
# }