$dayOfWeekNameLong=(
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
)

$dayOfWeekNameShort=(
    "Mo","Tu","We","Th","Fr","Sa","Su"
)

$currentYear=(Get-Date).Year
$currentMonth=(Get-Date).Month
$currentDay=(Get-Date).Day

$dayInMonth=0
$originalColor=(get-host).ui.rawui.ForegroundColor
$numberOfDaysInCurrentMonth=[DateTime]::DaysInMonth($currentYear, $currentMonth)
$firstDayInCurrentMonth=(Get-Date -year $currentYear -month $currentMonth -day 01).dayofweek
$startValue=(1..($dayOfWeekNameLong.Count)) | Where-Object {$dayOfWeekNameLong[$_] -eq $firstDayInCurrentMonth}

Write-Host (Get-Date -year $currentYear -month $currentMonth -day $currentDay -Format "ddd yyyy-dd-MM HH:mm")
Write-Host (Get-Date -year $currentYear -month $currentMonth -day $currentDay -Format "MMMM yyyy")
$topLineWithNameOfDay=[string]::Join(" ", $dayOfWeekNameShort)
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
