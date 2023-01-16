<#
.SYNOPSIS
Simple console calendar.

.DESCRIPTION
Show calendar for current month if no passed parameters.
With valid parameters show calendar for required month or year in past or in the future.

.PARAMETER userMonth
Specifies the required month in 2-digits format in the range 1-12 (TODO:or in format of full or abbreviated name of month).

.PARAMETER userYear
Specifies the required year in 4-digits format in the range 1-9999.

.EXAMPLE
PS> cal

     január 2023
po ut st št pi so ne
                  01
02 03 04 05 06 07 08
09 10 11 12 13 14 15
16 17 18 19 20 21 22
23 24 25 26 27 28 29
30 31

.EXAMPLE
PS> cal 5

      máj 2023
po ut st št pi so ne
01 02 03 04 05 06 07
08 09 10 11 12 13 14
15 16 17 18 19 20 21
22 23 24 25 26 27 28
29 30 31

.EXAMPLE
PS> cal 5 2028

      máj 2028
po ut st št pi so ne
01 02 03 04 05 06 07
08 09 10 11 12 13 14
15 16 17 18 19 20 21
22 23 24 25 26 27 28
29 30 31

#
# Author: Radovan Snirc
# Date: 2023-01-05
# Version 0.01.001
#
#>

param($userMonth, $userYear)

$dayOfWeekNameLong=@()
$dayOfWeekNameShort=@()
$someMonday=2
$someSunday=8
$someMondayMonth=1
$someMondayYear=2023
$realDay=(Get-Date).Day
$realMonth=(Get-Date).Month
$realYear=(Get-Date).Year

# Create the list of days name
foreach ($i in ($someMonday..$someSunday)){
    $dayOfWeekNameLong+=(Get-Date -Year $someMondayYear -Month $someMondayMonth -Day $i).ToString("dddd")
    $dayOfWeekNameShort+=(Get-Date -Year $someMondayYear -Month $someMondayMonth -Day $i).ToString("ddd")
}

# Validate user input (month)
if ($null -eq $userMonth) {
    $currentMonth=(Get-Date).Month
} elseif (($userMonth -match "^[\d\.]+$") -and ($userMonth -ge 1) -and ($userMonth -le 12)) {
    [Int16]$currentMonth=$userMonth[0]
} else {
    Write-Warning "Wrong parameters. $userMonth is not valid month in range 1-12"
    $currentMonth=(Get-Date).Month
}

# Validate user input (year)
if ($null -eq $userYear) {
    $currentYear=(Get-Date).Year
} elseif (($userYear -match "^[\d\.]+$") -and ($userYear -gt 0.999) -and ($userYear -le 9999)) {
    [Int16]$currentYear=$userYear[0]
} else {
    Write-Warning "Wrong parameters. $userYear is not valid year in range 1-9999."
    $currentYear=(Get-Date).Year
}

$currentDay=(Get-Date).Day
$currentMonthYear=Get-Date -year $currentYear -month $currentMonth -day $currentDay -Format "MMMM yyyy"

$dayInMonth=0
$originalForegroundColor=(get-host).ui.rawui.ForegroundColor
$originalBackgroundColor=(get-host).ui.rawui.BackgroundColor

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
            $fgColor=$originalForegroundColor
            $bgColor=$originalBackgroundColor
        } else {
            break
        }
        if ($b -eq 6) {$fgColor="White"}
        if (($dayInMonth -eq $realDay) -and ($currentMonth -eq $realMonth) -and ($currentYear -eq $realYear)) {
            $fgColor=$originalBackgroundColor
            $bgColor=$originalForegroundColor
        }
        if ($dayInMonth -eq 0) {
            Write-Host -NoNewline "   "
        } else {
            Write-Host -BackgroundColor $bgColor -ForegroundColor $fgColor -NoNewline ('{0:d2} ' -f $dayInMonth)
        }
        $bgColor=$originalBackgroundColor
        $fgColor=$originalForegroundColor
    }
    Write-Host
}
Write-Host
