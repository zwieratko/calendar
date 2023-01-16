
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
Show calendar for one month, quarter of the year or whole year.
With no parameters will show the current month.
With valid parameters will show calendar for required month or year in past or in the future.

.PARAMETER monthSelect
Specifies the required month in 2-digits format in the range 1-12 or in format of full or abbreviated name of month.
Only one specified parameter in range 1-12 will be understood as month, higher value will be understood as year.

.PARAMETER yearSelect
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
    Show not only one month :)
    Show whole year
    Show week numbers
#>

# PARAMS
param(
    [Parameter()]
    [string]
    $monthSelect,

    [Parameter()]
    [ValidateRange(1, 9999)]
    [int]
    $yearSelect,

    [Parameter()]
    [switch]
    $help,

    [Parameter()]
    [switch]
    $quarter,

    [Parameter()]
    [switch]
    $week
)

# VARIABLES
$dayOfWeekNameLong = @()
$dayOfWeekNameShort = @()
$monthNameLong = @()
$monthNameShort = @()
$someMonday = 2             # 2nd January 2023 - Monday
$someSunday = 8             # 8th January 2023 - Sunday
$someMondayMonth = 1        # It is needed for creating the list with name of a days
$someMondayYear = 2023      # It could be any Monday / Sunday

$originalForegroundColor = (get-host).ui.rawui.ForegroundColor
$originalBackgroundColor = (get-host).ui.rawui.BackgroundColor

# It is needed for checking if some day is today
$realDay = (Get-Date).Day
$realMonth = (Get-Date).Month
$realYear = (Get-Date).Year

# It is needed for .ToTitleCase()
$textInfo = (Get-Culture).TextInfo

# Create the list of days name (Monday, Mo)
foreach ($d in ($someMonday..$someSunday)) {
    $dayOfWeekNameLong += (Get-Date -Year $someMondayYear -Month $someMondayMonth -Day $d).ToString("dddd")
    $dayOfWeekNameShort += (Get-Date -Year $someMondayYear -Month $someMondayMonth -Day $d).ToString("ddd")
}

# Create the list of month name (January, Jan)
foreach ($m in (1..12)) {
    $monthNameLong += (Get-Date -Year $someMondayYear -Month $m).ToString("MMMM")
    $monthNameShort += (Get-Date -Year $someMondayYear -month $m).ToString("MMM")
}

function getHelp {
    param (
        $OptionalParameters
    )
    Write-Host "TODO: here will be help for calendar."
    Exit
}

function getQuarter {
    param (
        $OptionalParameters
    )
    Write-Host "TODO: here will be calendar fort the quarter of the year."
    Exit
}

function validateUserInput {
    param (
        $monthSelected,
        $yearSelected
    )
    Write-Host "Fn validate :" $PSBoundParameters.Count, " : ", $PSBoundParameters
    # Validate user input (month)
    if (($null -eq $monthSelect) -or ("" -eq $monthSelect)) {
        $currentMonth = $realMonth
    }
    elseif ($monthSelect -match "^ja.*") {
        $currentMonth = 1
    }
    elseif ($monthSelect -match "^fe.*") {
        $currentMonth = 2
    }
    elseif ($monthSelect -match "^mar.*") {
        $currentMonth = 3
    }
    elseif ($monthSelect -match "^ap.*") {
        $currentMonth = 4
    }
    elseif ($monthSelect -match "^m[aá][jy].*") {
        $currentMonth = 5
    }
    elseif ($monthSelect -match "^j[uú]n.*") {
        $currentMonth = 6
    }
    elseif ($monthSelect -match "^j[uú]l.*") {
        $currentMonth = 7
    }
    elseif ($monthSelect -match "^au.*") {
        $currentMonth = 8
    }
    elseif ($monthSelect -match "^se.*") {
        $currentMonth = 9
    }
    elseif ($monthSelect -match "^o[ck].*") {
        $currentMonth = 10
    }
    elseif ($monthSelect -match "^no.*") {
        $currentMonth = 11
    }
    elseif ($monthSelect -match "^de.*") {
        $currentMonth = 12
    }
    elseif (($monthSelect -match "^[\d\.]+$") -and ([Int16]$monthSelect -ge 1) -and ([Int16]$monthSelect -le 12)) {
        $currentMonth = $monthSelect
    }
    elseif (($monthSelect -match "^[\d\.]+$") -and ([Int16]$monthSelect -gt 12) -and ($yearSelected -eq 0)) {
        <# If there is only one positional params greater than 12, maybe it is year ? #>
        Write-Host "Maybe year?"
        Write-Host "TODO: whole year calendar"
        $currentMonth = $realMonth
        $yearSelect = $monthSelect
    }
    else {
        Write-Warning "Wrong parameters. $monthSelect is not valid month in range 1-12"
        $currentMonth = $realMonth
    }
    Write-Output ([int16]$currentMonth)

    # Validate user input (year)
    if (($null -eq $yearSelect) -or ("" -eq $yearSelect) -or (0 -eq $yearSelect)) {
        $currentYear = $realYear
    }
    elseif (($yearSelect -match "^[\d\.]+$") -and ([Int16]$yearSelect -gt 0.999) -and ([Int16]$yearSelect -le 9999)) {
        $currentYear = $yearSelect
    }
    else {
        Write-Warning "Wrong parameters. $yearSelect is not valid year in range 1-9999."
        $currentYear = $realYear
    }
    Write-Output ([int16]$currentYear)
}

function showCurrentMonth {
    param (
        $currentMonth,
        $currentYear
    )
    $currentDay = $realDay
    $currentMonthYear = Get-Date -year $currentYear -month $currentMonth -day $currentDay -Format "MMMM yyyy"
    $dayNrInMonth = 0

    $numberOfDaysInCurrentMonth = [DateTime]::DaysInMonth($currentYear, $currentMonth)
    $firstDayInCurrentMonth = (Get-Date -year $currentYear -month $currentMonth -day 01).ToString("dddd")
    $startDayInMonth = (1..($dayOfWeekNameLong.Count)) | Where-Object { $dayOfWeekNameLong[$_] -eq $firstDayInCurrentMonth }

    $topLineWithNameOfDay = [string]::Join(" ", $dayOfWeekNameShort)
    $weekLineWidth = $topLineWithNameOfDay.Length
    $currentMonthYearWidth = $currentMonthYear.Length
    $spaceToCenter = [System.Math]::Ceiling($currentMonthYearWidth + (($weekLineWidth - $currentMonthYearWidth) / 2))
    #"{0}{1,4}{2,6}" -f $currentMonthYearWidth, $weekLineWidth, $spaceToCenter

    Write-Host "Fn main :" $PSBoundParameters.Count, " : ", $PSBoundParameters
    # FUNCTION
    #Write-Host (Get-Date -year $currentYear -month $currentMonth -day $currentDay -Format "ddd yyyy-dd-MM HH:mm")
    Write-Host ("a")
    Write-Host $textInfo.ToTitleCase($currentMonthYear.PadLeft($spaceToCenter, " "))
    Write-Host $textInfo.ToTitleCase($topLineWithNameOfDay)
    foreach ($weekLine in (1..6)) {
        foreach ($weekColumn in (0..6)) {
            if ($weekLine -eq 1 -and $weekColumn -lt $startDayInMonth) {
                $dayNrInMonth = 0
                #$fgColor=(get-host).ui.rawui.BackgroundColor
            }
            elseif ($dayNrInMonth -lt $numberOfDaysInCurrentMonth) {
                $dayNrInMonth++
                $fgColor = $originalForegroundColor
                $bgColor = $originalBackgroundColor
            }
            else {
                break
            }
            if ($weekColumn -eq 6) { $fgColor = "White" }
            if (($dayNrInMonth -eq $realDay) -and ($currentMonth -eq $realMonth) -and ($currentYear -eq $realYear)) {
                $fgColor = $originalBackgroundColor
                $bgColor = $originalForegroundColor
            }
            if ($dayNrInMonth -eq 0) {
                Write-Host -NoNewline "   "
            }
            else {
                Write-Host -BackgroundColor $bgColor -ForegroundColor $fgColor -NoNewline ('{0:d2} ' -f $dayNrInMonth)
            }
            $bgColor = $originalBackgroundColor
            $fgColor = $originalForegroundColor
        }
        Write-Host("b")
        if ($dayNrInMonth -ge $numberOfDaysInCurrentMonth) {
            break
        }
    }
    Write-Host("c")
}


# Main
Write-Host "Main: ", $PSBoundParameters.Count, " : ", $PSBoundParameters

switch ($PSBoundParameters.Keys) {
    'help' {
        getHelp
    }
    'quarter' {
        getQuarter
    }
    'week' {
        $showWeekNumbers = $true
    }
    Default {
        #Write-Host ":)"
        $showWeekNumbers = $false
    }
}

$validInput = validateUserInput -monthSelected $monthSelect -yearSelected $yearSelect
showCurrentMonth -currentMonth $validInput[0] -currentYear $validInput[1]
$showWeekNumbers