
<#PSScriptInfo

.VERSION 0.001.001

.GUID 568a6011-3309-4352-b100-ef97cc3b06f6

.AUTHOR zwieratko1@gmail.com

.COMPANYNAME

.COPYRIGHT

.TAGS

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES

.PRIVATEDATA

#>


<#
.DESCRIPTION 
 Simple console calendar 


.SYNOPSIS
Simple console calendar.

.DESCRIPTION
Show calendar for current month.

With valid parameters show calendar for required month or year in past or in the future.

.PARAMETER userMonth
Specifies the required month in 2-digits format in the range 1-12 or in format of full or abbreviated name of month.

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

.NOTES
Author: Radovan Snirc
Version 0.01.001
Date: 2023-01-05
TODO:
    Validate month via abbreviated name
    Show more like one month
    Show whole year
#>


# PARAMS
param(
    $userMonth,
    $userYear
)

# VARIABLES
$dayOfWeekNameLong=@()
$dayOfWeekNameShort=@()
$someMonday=2             # 2nd January 2023 - Monday
$someSunday=8             # 8th January 2023 - Sunday
$someMondayMonth=1        # It is needed for creating the list with name of a days
$someMondayYear=2023      # It could be any Monday / Sunday

$monthNameLong=@()
$monthNameShort=@()

# It is needed for checking if some day is today
$realDay=(Get-Date).Day
$realMonth=(Get-Date).Month
$realYear=(Get-Date).Year

# It is needed for .ToTitleCase()
$textInfo=(Get-Culture).TextInfo

# Create the list of days name (Monday, Mo)
foreach ($d in ($someMonday..$someSunday)){
    $dayOfWeekNameLong+=(Get-Date -Year $someMondayYear -Month $someMondayMonth -Day $d).ToString("dddd")
    $dayOfWeekNameShort+=(Get-Date -Year $someMondayYear -Month $someMondayMonth -Day $d).ToString("ddd")
}

# Create the list of month name (January, Jan)
foreach ($m in (1..12)) {
    $monthNameLong+=(Get-Date -Year $someMondayYear -Month $m).ToString("MMMM")
    $monthNameShort+=(Get-Date -Year $someMondayYear -month $m).ToString("MMM")
}

# Validate user input (month)
if ($null -eq $userMonth) {
    $currentMonth=$realMonth
} elseif ($userMonth -match "^ja.*") {
    $currentMonth=1
} elseif ($userMonth -match "^fe.*") {
    $currentMonth=2
} elseif ($userMonth -match "^mar.*") {
    $currentMonth=3
} elseif ($userMonth -match "^ap.*") {
    $currentMonth=4
} elseif ($userMonth -match "^m[aá][jy].*") {
    $currentMonth=5
} elseif ($userMonth -match "^j[uú]n.*") {
    $currentMonth=6
} elseif ($userMonth -match "^j[uú]l.*") {
    $currentMonth=7
} elseif ($userMonth -match "^au.*") {
    $currentMonth=8
} elseif ($userMonth -match "^se.*") {
    $currentMonth=9
} elseif ($userMonth -match "^o[ck].*") {
    $currentMonth=10
} elseif ($userMonth -match "^no.*") {
    $currentMonth=11
} elseif ($userMonth -match "^de.*") {
    $currentMonth=12
} elseif (($userMonth -match "^[\d\.]+$") -and ($userMonth -ge 1) -and ($userMonth -le 12)) {
    [Int16]$currentMonth=$userMonth[0]
} else {
    Write-Warning "Wrong parameters. $userMonth is not valid month in range 1-12"
    $currentMonth=$realMonth
}

# Validate user input (year)
if ($null -eq $userYear) {
    $currentYear=$realYear
} elseif (($userYear -match "^[\d\.]+$") -and ($userYear -gt 0.999) -and ($userYear -le 9999)) {
    [Int16]$currentYear=$userYear[0]
} else {
    Write-Warning "Wrong parameters. $userYear is not valid year in range 1-9999."
    $currentYear=$realYear
}

$currentDay=$realDay

$currentMonthYear=Get-Date -year $currentYear -month $currentMonth -day $currentDay -Format "MMMM yyyy"

$dayNrInMonth=0
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

# FUNCTION
#Write-Host (Get-Date -year $currentYear -month $currentMonth -day $currentDay -Format "ddd yyyy-dd-MM HH:mm")
Write-Host
Write-Host $textInfo.ToTitleCase($currentMonthYear.PadLeft($spaceToCenter, " "))
Write-Host $textInfo.ToTitleCase($topLineWithNameOfDay)
foreach($a in (1..6)) {
    foreach($b in (0..6)){
        if ($a -eq 1 -and $b -lt $startValue) {
            $dayNrInMonth=0
            #$fgColor=(get-host).ui.rawui.BackgroundColor
        } elseif ($dayNrInMonth -lt $numberOfDaysInCurrentMonth) {
            $dayNrInMonth++
            $fgColor=$originalForegroundColor
            $bgColor=$originalBackgroundColor
        } else {
            break
        }
        if ($b -eq 6) {$fgColor="White"}
        if (($dayNrInMonth -eq $realDay) -and ($currentMonth -eq $realMonth) -and ($currentYear -eq $realYear)) {
            $fgColor=$originalBackgroundColor
            $bgColor=$originalForegroundColor
        }
        if ($dayNrInMonth -eq 0) {
            Write-Host -NoNewline "   "
        } else {
            Write-Host -BackgroundColor $bgColor -ForegroundColor $fgColor -NoNewline ('{0:d2} ' -f $dayNrInMonth)
        }
        $bgColor=$originalBackgroundColor
        $fgColor=$originalForegroundColor
    }
    Write-Host
}
Write-Host
