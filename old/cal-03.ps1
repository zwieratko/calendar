$dayOfWeekNameLong=@()
$dayOfWeekNameShort=@()
$someMonday=2
$someSunday=8
$someMondayMonth=1
$someMondayYear=2023

foreach ($i in ($someMonday..$someSunday)){
    $dayOfWeekNameLong+=(Get-Date -Year $someMondayYear -Month $someMondayMonth -Day $i).ToString("dddd")
    $dayOfWeekNameShort+=(Get-Date -Year $someMondayYear -Month $someMondayMonth -Day $i).ToString("ddd")
}

$currentYear=(Get-Date).Year
$currentMonth=(Get-Date).Month
$currentDay=(Get-Date).Day
$currentMonthYear=Get-Date -year $currentYear -month $currentMonth -day $currentDay -Format "MMMM yyyy"

$dayInMonth=0
$originalColor=(get-host).ui.rawui.ForegroundColor

$numberOfDaysInCurrentMonth=[DateTime]::DaysInMonth($currentYear, $currentMonth)
$firstDayInCurrentMonth=(Get-Date -year $currentYear -month $currentMonth -day 01).ToString("dddd")
$startValue=(1..($dayOfWeekNameLong.Count)) | Where-Object {$dayOfWeekNameLong[$_] -eq $firstDayInCurrentMonth}

$topLineWithNameOfDay=[string]::Join(" ", $dayOfWeekNameShort)
$weekLineWidth=$topLineWithNameOfDay.Length
$currentMonthYearWidth=$currentMonthYear.Length
$spaceToCenter=[System.Math]::Ceiling($currentMonthYearWidth+(($weekLineWidth-$currentMonthYearWidth)/2))
#"{0}{1,4}{2,6}" -f $currentMonthYearWidth, $weekLineWidth, $spaceToCenter

#Write-Host (Get-Date -year $currentYear -month $currentMonth -day $currentDay -Format "ddd yyyy-dd-MM HH:mm")
Write-Host
Write-Host $currentMonthYear.PadLeft($spaceToCenter, " ")
Write-Host $topLineWithNameOfDay
foreach($a in (1..6)) {
    foreach($b in (0..6)){
        if ($a -eq 1 -and $b -lt $startValue) {
            $dayInMonth=0
            #$fgColor=(get-host).ui.rawui.BackgroundColor
        } elseif ($dayInMonth -lt $numberOfDaysInCurrentMonth) {
            $dayInMonth++
            $fgColor=$originalColor
        } else {
            break
        }
        if ($b -eq 6) {$fgColor="White"}
        if ($dayInMonth -eq $currentDay) {$fgColor="Red"}
        if ($dayInMonth -eq 0) {
            Write-Host -NoNewline "   "
        } else {
            Write-Host -ForegroundColor $fgColor -NoNewline ('{0:d2} ' -f $dayInMonth)
        }
        $fgColor=$originalColor
    }
    Write-Host
}
Write-Host
