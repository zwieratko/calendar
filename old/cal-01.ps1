$topLine="Týž.","|","Po","Ut","St","Št","Pi","So","Ne"
$topLineString=[string]::Join(" ", $topLine)
$topLine.Count
$endOfLine=$topLineString.length

$weekPosition=1
$dayNameShort="Ne","Po","Ut","St","Št","Pi","So"
$dayPosition=31,8,12,16,20,24,28
$dayPosition[6]
$sundayPosition=26

$firstDayInCurrentMonth=[int](get-date -year (get-date).year -month (get-date).month -day 01).dayofweek
[int]$dayOfMonth=0

Write-Host $topLine
$temp=0
foreach ($line in (1..6)) {
    foreach ($positionOnLine in (1..$endOfLine)) {
        if ($positionOnLine -lt $endOfLine) {
            if ($line -eq 1 -and $positionOnLine -in $dayPosition) {$x++}
            if ($positionOnLine -in $dayPosition) {
                Write-Host -NoNewline ('{0:d2}' -f $temp++)
            }
            else {
                Write-Host -NoNewline " "
            }
        }
        else {
            Write-Host " "
        }
    }
}
