function wattage ($voltage, $amphere)
{
    $watts = 0

    $watts = $voltage * $amphere

    return $watts
}

function kiloWatts ($watts)
{
    return ($watts/1000)
}

function totalVolts($nominalVolts , $series )
{
    return  ($nominalVolts * $series)
}

function mAh2Ah($mAh)
{
    return  ($mAh / 1000)
}

function Ah2mAh($Ah)
{
    return  ($Ah * 1000)
}
