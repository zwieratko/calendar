
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
.SYNOPSIS
Simple console calendar.

.DESCRIPTION
Show calendar for one month, quarter of the year or whole year.
With no parameters will show the current month.
With valid parameters will show calendar for required month or year in past or in the future.

.PARAMETER monthSelect
Specifies the required month in 2-digits format in the range 1-12 or in format of full or abbreviated name of month.
Only one specified numeric parameter in range 1-12 will be understood as month, numeric parameter with higher value will be understood as year.
Shorter: '-month' / '-m'

.PARAMETER yearSelect
Specifies the required year in 2-4 digits format in the range 1-9999.
Only one specified numeric parameter with value higher than 12 will be understood as year.
Shorter '-year' / '-y'

.PARAMETER showMeNames
Show all possible names of days in week and months used in calendar.
Shorter: '-show' / '-s'
Additional parameters are ignored.

.PARAMETER quarterYear
Show quarter of the year calendar, three months side by side.
Shorter '-quarter' / '-q'

.PARAMETER wholeYear
Show whole year calendar, three months side by side.
Shorter: '-whole' / '-w'

.PARAMETER numberOfWeek
Show the week number in calendar.
Shorter '-number' / '-n'

.PARAMETER julianDay
Show Julian day instead of classic day in calendar.
Shorter '-julian' / '-j'

.PARAMETER debugVerbosity
Show additional debug information.
Shorter '-debug' / '-d'

.PARAMETER version
Show the version of program.
Shorter '-v'
Additional parameters are ignored.

.PARAMETER helpMe
Show help information for calendar program.
Shorter '-h'
Additional parameters are ignored.

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
    #[ValidateRange(1, 9999)]
    [string]
    $yearSelect,

    [Parameter()]
    [switch]
    $showMeNames,

    [Parameter()]
    [switch]
    $quarterYear,

    [Parameter()]
    [switch]
    $wholeYear,

    [Parameter()]
    [switch]
    $numberOfWeek,

    [Parameter()]
    [switch]
    $julianDay,

    [Parameter()]
    [switch]
    $debugVerbosity,

    [Parameter()]
    [switch]
    $version,

    [Parameter()]
    [switch]
    $helpMe
)

if ($debugVerbosity) {
    Write-Host "Debug verbosity is increased! Sorry."
}

# VARIABLES
$dayOfWeekNameLong = @()
$dayOfWeekNameShort = @()
$monthNameLong = @()
$monthNameShort = @()
$someMonday = 2             # 2nd January 2023 - Monday
$someSunday = 8             # 8th January 2023 - Sunday
$someMondayMonth = 1        # It is needed for creating the list with name of a days
$someMondayYear = 2023      # It could be any Monday / Sunday

if (($IsLinux -eq $true) -or ($IsMacOS -eq $true)) {
    $originalForegroundColor = "Gray"
    if (($IsLinux -eq $true) -and ($debugVerbosity)) {
        Write-Host "Host: looks like Linux"
        #TODO: autodetect foreground color for Linux
    }
    elseif ((($IsMacOS -eq $true) -and ($debugVerbosity))) {
        Write-Host "Host: looks like MacOS"
        #TODO: autodetect foreground color for MacOS
    }
}
else {
    $originalForegroundColor = (get-host).ui.rawui.ForegroundColor
    if ($debugVerbosity) {
        Write-Host "Host: looks like Windows"
    }
}

if (($IsLinux -eq $true) -or ($IsMacOS -eq $true)) {
    $originalBackgroundColor = "Black"
    #TODO: autodetect background color for Linux / MacOS
}
else {
    $originalBackgroundColor = (get-host).ui.rawui.BackgroundColor
}

# It is needed for checking if some day in calendar is today
$realDay = (Get-Date).Day
$realMonth = (Get-Date).Month
$realYear = (Get-Date).Year

# It is needed for .ToTitleCase()
$textInfo = (Get-Culture).TextInfo
if ($debugVerbosity) {
    Write-Host "Locale: ", $textInfo.CultureName
}

# Create the list of days name (Monday, Mo)
$params = @{
    Year  = $someMondayYear
    Month = $someMondayMonth
}
foreach ($d in ($someMonday..$someSunday)) {
    $dayOfWeekNameLong += (Get-Date @params -Day $d).ToString("dddd")
    $dayOfWeekNameShort += ((Get-Date @params -Day $d).ToString("ddd")).Substring(0, 2)
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
    $usageText = @"
Cal - simple console calendar

Usage:
    cal
    cal [[-m] month] [[-y] year]
    cal [-nj] [[-m] month] [[-y] year]
    cal -q [1|2|3|4] [[-y] year]
    cal -w [[-y] year]
    cal [-s | -v | -h]

"@
    $optionsText = @"
Options:
    -m | -monthSelect       First positional parameter. 
                            Specifies the required month in 2 digits format in the range 1-12.
                            Or in format of full name or abbreviated name of month.
                            Only one specified numeric parameter in range 1-12 will be understood as month.
                            Only one numeric parameter with value higher than 12 will be understood as year.
                            For example: "12", "-m 12", "-m jan", "-m January"

    -y | -yearSelect        Second positional parameter.
                            Specifies the required year in 2-4 digits format in the range 1-9999.
                            Only one numeric parameter with value higher than 12 will be understood as year.
                            For example: "2024", "-y 2024"

    -q | -quarterYear       Show quarter of the year calendar, three months side by side.
                            Specifies the required quarter in 1 digits format in the range 1-4.
                            Without spoecified numeric value display the current quarter of the current year.
                            For example: "-q", "-q 1"

    -w | -wholeYear         Show whole year calendar, three months side by side.
                            Specifies the required year in 2-4 digits format in the range 1-9999.
                            Without specified numeric value display the current year.
                            For example: "2024", "-w", "-w 2024"

    -n | -numberOfWeek      Show the week number in calendar. No need additional value.

    -j | -julianDay         Show Julian day instead of classic day in calendar. No need additional value.

    -s | -showMeNames       Show all possible names of days and months used in calendar.

    -v | -version           Show the actuall version of Calendar program.

    -h | -helpMe            Show this help information for Calendar program.
"@
    Write-Host $usageText
    Write-Host $optionsText
    Exit
}

function getNames {
    param (
        $OptionalParameters
    )
    Write-Host "Names of days and months used in program."
    Write-Host "Full names of days:"
    Write-Host $dayOfWeekNameLong
    Write-Host "Abbreviated names of days:"
    Write-Host $dayOfWeekNameShort
    Write-Host "Full names of months:"
    Write-Host $monthNameLong
    Write-Host "Abbreviated names of months:"
    Write-Host $monthNameShort
    Exit
}

function getQuarter {
    param (
        [Parameter()]
        [string]
        $currentQuarter,

        [Parameter()]
        [string]
        $currentYear,

        [Parameter()]
        [bool]
        $enableWeekNr,

        [Parameter()]
        [bool]
        $enableJulianDay,

        [Parameter()]
        [bool]
        $enableDebugVerbosity
    )

    if ($enableDebugVerbosity) {
        Write-Host "Fn getQuarter :" $PSBoundParameters.Count, " : ", $PSBoundParameters
    }
    #Write-Host "TODO: here will be calendar for quarter of the year."
    switch -Regex ($currentQuarter) {
        "^1$" { 
            $currentMonth = 1
            $endMonth = 3
        }
        "^2$" {
            $currentMonth = 4
            $endMonth = 6
        }
        "^3$" {
            $currentMonth = 7
            $endMonth = 9
        }
        "^4$" {
            $currentMonth = 10
            $endMonth = 12
        }
        Default {
            switch ($realMonth) {
                { $_ -in (1, 2, 3) } {
                    $currentMonth = 1
                    $endMonth = 3
                }
                { $_ -in (4, 5, 6) } {
                    $currentMonth = 4
                    $endMonth = 6
                }
                { $_ -in (7, 8, 9) } {
                    $currentMonth = 7
                    $endMonth = 9
                }
                { $_ -in (10, 11, 12) } {
                    $currentMonth = 10
                    $endMonth = 12
                }
                Default {}
            }
            if ($currentQuarter -notmatch "^$") {
                Write-Warning "Wrong parameters. $currentQuarter is not valid quarter in range 1-4."
                Write-Warning "Replaced by current quarter of the year."
            }
        }
    }
    if (($currentYear -match "^[\d\.]+$") -and ([Int32]$currentYear -gt 0.999) -and ([Int32]$currentYear -le 9999)) {
        $currentYear = $currentYear
    }
    elseif ($currentYear -eq "") {
        $currentYear = $realYear
    }
    else {
        Write-Warning "Wrong parameters. $currentYear is not valid year in range 1-9999."
        Write-Warning "Replaced by current year."
        $currentYear = $realYear
        
    }
    $params = @{
        "currentMonth"         = $currentMonth
        "endMonth"             = $endMonth
        "currentYear"          = $currentYear
        "enableWeekNr"         = $numberOfWeek
        "enableJulianDay"      = $julianDay
        "enableQuarterYear"    = $true
        "enableDebugVerbosity" = $debugVerbosity
    }
    printCalendar @params
    Exit
}

function getWhole {
    param (
        [Parameter()]
        [string]
        $currentMonth,

        [Parameter()]
        [string]
        $currentYear,

        [Parameter()]
        [bool]
        $enableWeekNr,

        [Parameter()]
        [bool]
        $enableJulianDay,

        [Parameter()]
        [bool]
        $enableDebugVerbosity
    )

    if ($enableDebugVerbosity) {
        Write-Host "Fn getWhole :" $PSBoundParameters.Count, " : ", $PSBoundParameters
    }
    if (($currentYear -match "^[\d\.]+$") -and ([Int32]$currentYear -gt 0.999) -and ([Int32]$currentYear -le 9999)) {
        $currentYear = $currentYear
    }
    elseif (($currentMonth -match "^[\d\.]+$") -and ([Int32]$currentMonth -gt 0.999) -and ([Int32]$currentMonth -le 9999)) {
        $currentYear = $currentMonth
    }
    elseif ($currentYear -eq "" -and $currentMonth -eq "") {
        $currentYear = $realYear
    }
    # Write-Host "TODO: here will be calendar for whole year: ", $currentYear
    $params = @{
        "currentMonth"         = 1
        "endMonth"             = 3
        "currentYear"          = $currentYear
        "enableWeekNr"         = $numberOfWeek
        "enableJulianDay"      = $julianDay
        "enableQuarterYear"    = $true
        "enableDebugVerbosity" = $debugVerbosity
    }
    foreach ($quarter in (1, 4, 7, 10)) {
        $params.currentMonth = $quarter
        $params.endMonth = $quarter + 2
        printCalendar @params
    }
    Exit
}

function getVersion {
    param (
        $OptionalParameters
    )
    Write-Host "cal - simple console calendar"
    Write-Host "Version: 0.001.001"
    Exit
}

function validateUserInput {
    param (
        [Parameter()]
        [string]
        $monthSelected,

        [Parameter()]
        [string]
        $yearSelected,

        [Parameter()]
        [bool]
        $enableDebugVerbosity
    )

    if ($enableDebugVerbosity) {
        Write-Host "Fn validate :" $PSBoundParameters.Count, " : ", $PSBoundParameters
    }
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
    elseif (($monthSelect -match "^[\d\.]+$") -and ([Int32]$monthSelect -ge 1) -and ([Int32]$monthSelect -le 12)) {
        $currentMonth = $monthSelect
    }
    elseif (($monthSelect -match "^[\d\.]+$") -and ([Int32]$monthSelect -gt 12) -and ($yearSelected -eq "")) {
        <# If there is only one positional params greater than 12, maybe it is year ? #>
        Write-Host "Maybe year?"
        if ([int32]$monthSelect -le 9999) {
            # [Int16]$validYear = $monthSelect
            getWhole -currentYear $monthSelect -enableDebugVerbosity $enableDebugVerbosity
        }
        else {
            $yearSelect = $monthSelect
            $currentMonth = $realMonth
        }
        # $currentMonth = $realMonth
        # $yearSelect = $monthSelect
    }
    else {
        Write-Warning "Wrong parameters. $monthSelect is not valid month in range 1-12"
        Write-Warning "Replaced by current month."
        $currentMonth = $realMonth
    }
    Write-Output ([int16]$currentMonth)

    # Validate user input (year)
    if (($null -eq $yearSelect) -or ("" -eq $yearSelect)) {
        $currentYear = $realYear
    }
    elseif (($yearSelect -match "^[\d\.]+$") -and ([Int32]$yearSelect -gt 0.999) -and ([Int32]$yearSelect -le 9999)) {
        $currentYear = $yearSelect
    }
    else {
        Write-Warning "Wrong parameters. $yearSelect is not valid year in range 1-9999."
        Write-Warning "Replaced by current year."
        $currentYear = $realYear
    }
    Write-Output ([int16]$currentYear)
}

function printCalendar {
    param (
        [Parameter()]
        [Int16]
        $currentMonth,

        [Parameter()]
        [Int16]
        $endMonth,

        [Parameter()]
        [Int16]
        $currentYear,

        [Parameter()]
        [bool]
        $enableWeekNr,

        [Parameter()]
        [bool]
        $enableJulianDay,

        [Parameter()]
        [bool]
        $enableQuarterYear,

        [Parameter()]
        [bool]
        $enableWholeYear,

        [Parameter()]
        [bool]
        $enableDebugVerbosity
    )

    if ($enableDebugVerbosity) {
        Write-Host "Fn main :" $PSBoundParameters.Count, " : ", $PSBoundParameters
    }

    $currentDay = $realDay
    if (($enableQuarterYear -eq $false) -and ($enableWholeYear -eq $false)) {
        $endMonth = $currentMonth
        $calendarTitle = Get-Date -year $currentYear -month $currentMonth -day $currentDay -Format "MMMM yyyy"
        $startWeekLine = 0
    }
    elseif ($enableQuarterYear) {
        $quaterNr = $endMonth / 3
        $calendarTitle = "Quarter $quaterNr of the year $currentYear. `n"
        $startWeekLine = -1
    }
    $totalMonths = $endMonth - $currentMonth + 1
    $finishedMonths = 0
    
    #$dayNrInMonth = 0
    #$numberOfDaysInCurrentMonth = [DateTime]::DaysInMonth($currentYear, $currentMonth)
    #$firstDayInCurrentMonth = (Get-Date -year $currentYear -month $currentMonth -day 01).ToString("dddd")
    #$startDayInMonth = (1..($dayOfWeekNameLong.Count)) | Where-Object { $dayOfWeekNameLong[$_] -eq $firstDayInCurrentMonth }
    $dayNrInMonth = [byte[]]::new(13)
    $numberOfDaysInCurrentMonth = [byte[]]::new(13)
    $startDayInMonth = [byte[]]::new(13)
    foreach ($monthNr in ($currentMonth..$endMonth)) {
        $numberOfDaysInCurrentMonth[$monthNr] = [DateTime]::DaysInMonth($currentYear, $monthNr)
        $firstDayInCurrentMonth = (Get-Date -year $currentYear -month $monthNr -day 01).ToString("dddd")
        $startDayInMonth[$monthNr] = (1..($dayOfWeekNameLong.Count)) | Where-Object { $dayOfWeekNameLong[$_] -eq $firstDayInCurrentMonth }
    }

    #$topLineWithNameOfDay = [string]::Join(" ", $dayOfWeekNameShort)
    foreach ($iterDay in (0..6)) {
        $topLineWithNameOfDay += $dayOfWeekNameShort[$iterDay]
        #if ($iterDay -lt 7) {
        if ($enableJulianDay) {
            $topLineWithNameOfDay += "  "
            $dayWithoutDate = "    "
            $paddingSpaces = 3
        }
        else {
            $topLineWithNameOfDay += " "
            $dayWithoutDate = "   "
            $paddingSpaces = 2
        }
        #}
    }
    $spaceToCenter = 0
    $weekLineWidth = $topLineWithNameOfDay.Length * $totalMonths
    $calendarTitleWidth = $calendarTitle.Length
    $spaceToCenter = [System.Math]::Ceiling($calendarTitleWidth + (($weekLineWidth - $calendarTitleWidth) / 2))
    if ($enableWeekNr -eq $true) {
        $spaceToCenter += 3
        $topLineWithNameOfDay = "   " + $topLineWithNameOfDay
        $weekLineWidth = $topLineWithNameOfDay.Length * $totalMonths
    }
    #"{0}{1,4}{2,6}" -f $calendarTitleWidth, $weekLineWidth, $spaceToCenter

    #Write-Host (Get-Date -year $currentYear -month $currentMonth -day $currentDay -Format "ddd yyyy-dd-MM HH:mm")
    Write-Host
    Write-Host $textInfo.ToTitleCase($calendarTitle.PadLeft($spaceToCenter, " "))
    #Write-Host $textInfo.ToTitleCase($topLineWithNameOfDay)
    foreach ($weekLine in ($startWeekLine..9)) {
        foreach ($monthNr in ($currentMonth..$endMonth)) {
            if (($weekLine -eq -1) -and (($enableQuarterYear) -or ($enableWholeYear))) {
                $monthNameWidth = $monthNameLong[$monthNr - 1].length
                $leftP = [System.Math]::Ceiling($monthNameWidth + (($weekLineWidth - $monthNameWidth) / 2)) / 3
                $rightP = $weekLineWidth / 3
                Write-host -NoNewline ($textInfo.ToTitleCase($monthNameLong[$monthNr - 1])).PadLeft($leftP, " ").PadRight($rightP, " ")
            }
            elseif ($weekLine -eq 0) {
                Write-Host -NoNewline $textInfo.ToTitleCase($topLineWithNameOfDay)
            }
            else {
                foreach ($weekColumn in (0..6)) {
                    if ($weekLine -eq 1 -and $weekColumn -lt $startDayInMonth[$monthNr]) {
                        $dayNrInMonth[$monthNr] = 0
                        #$fgColor=(get-host).ui.rawui.BackgroundColor
                    }
                    elseif ($dayNrInMonth[$monthNr] -lt $numberOfDaysInCurrentMonth[$monthNr]) {
                        $dayNrInMonth[$monthNr]++
                        $fgColor = $originalForegroundColor
                        $bgColor = $originalBackgroundColor
                    }
                    else {
                        #break
                        $dayNrInMonth[$monthNr] = 99
                    }
                    if ($dayNrInMonth[$monthNr] -eq $numberOfDaysInCurrentMonth[$monthNr]) {
                        $finishedMonths += 1
                    }
                    # Printing the week number
                    if (($enableWeekNr -eq $true) -and ($weekColumn -eq 0)) {
                        if ($dayNrInMonth[$monthNr] -eq 0) {
                            $dayNrForWeekNr = 1
                        }
                        else {
                            $dayNrForWeekNr = $dayNrInMonth[$monthNr]
                        }
                        if ($dayNrInMonth[$monthNr] -le 31) {
                            [int16]$weekNumber = (Get-Date -Year $currentYear -Month $monthNr -Day $dayNrForWeekNr -UFormat %V)
                            Write-Host -NoNewline ('{0:d2}|' -f $weekNumber)
                        }
                        else {
                            Write-Host -NoNewline "   "
                        }
                    }
                    # Is it Sunday ?
                    if ($weekColumn -eq 6) { $fgColor = "White" }
                    # Is it today ?
                    if (($dayNrInMonth[$monthNr] -eq $realDay) -and ($monthNr -eq $realMonth) -and ($currentYear -eq $realYear)) {
                        $fgColor = $originalBackgroundColor
                        $bgColor = $originalForegroundColor
                    }
                    # Printing the day number
                    if (($dayNrInMonth[$monthNr] -eq 0) -or ($dayNrInMonth[$monthNr] -eq 99)) {
                        Write-Host -NoNewline $dayWithoutDate
                    }
                    else {
                        if ($enableJulianDay -eq $true) {
                            $writtenNumberOfDay = (Get-Date -Year $currentYear -Month $monthNr -Day $dayNrInMonth[$monthNr]).DayOfYear
                        }
                        else {
                            $writtenNumberOfDay = $dayNrInMonth[$monthNr]
                        }
                        $params = @{
                            "BackgroundColor" = $bgColor
                            "ForegroundColor" = $fgColor
                            "NoNewline"       = $true
                        }
                        Write-Host @params ("{0:d$paddingSpaces} " -f $writtenNumberOfDay)
                    }
                    $bgColor = $originalBackgroundColor
                    $fgColor = $originalForegroundColor
                }
            }
            Write-Host -NoNewline "  "
        }
        Write-Host #$finishedMonths
        if ($finishedMonths -eq $totalMonths) {
            break
        }
    }
    Write-Host
    if ($debugVerbosity) {
        Write-Host "dayNrInMonth:", $dayNrInMonth
        Write-Host "numberOfDaysInCurrentMonth:", $numberOfDaysInCurrentMonth
        Write-Host "startDayInMonth", $startDayInMonth
    }
}


# Main
if ($debugVerbosity) {
    Write-Host "Main: ", $PSBoundParameters.Count, " : ", $PSBoundParameters
}

switch ($PSBoundParameters.Keys) {
    'showMeNames' {
        getNames
    }
    'quarterYear' {
        $params = @{
            "currentQuarter"       = $monthSelect
            "currentYear"          = $yearSelect
            "enableWeekNr"         = $numberOfWeek
            "enableJulianDay"      = $julianDay
            "enableDebugVerbosity" = $debugVerbosity
        }
        getQuarter @params
    }
    'wholeYear' {
        $params = @{
            currentMonth         = $monthSelect
            currentYear          = $yearSelect
            enableWeekNr         = $numberOfWeek
            enableJulianDay      = $julianDay
            enableDebugVerbosity = $debugVerbosity
        }
        getWhole @params
    }
    'version' {
        getVersion
    }
    'helpMe' {
        getHelp
    }
    'numberOfWeek' {
        #Write-host "Switch -w"
        #$showWeekNumbers = $true
    }
    Default {
        #Write-Host ":)"
        # $showWeekNumbers = $false
    }
}

# if ($numberOfWeek.IsPresent) {
#     $showWeekNumbers = $true
# }

$params = @{
    "monthSelected"        = $monthSelect
    "yearSelected"         = $yearSelect
    "enableDebugVerbosity" = $debugVerbosity
}
$validInput = validateUserInput @params

$params = @{
    "currentMonth"         = $validInput[0]
    "currentYear"          = $validInput[1]
    "enableWeekNr"         = $numberOfWeek
    "enableJulianDay"      = $julianDay
    "enableDebugVerbosity" = $debugVerbosity
}
printCalendar @params
