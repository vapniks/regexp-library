# Written by Joe Bloggs [2017-08-26 Sat]

# This file contains a collection of handy regular expressions assigned to arrays.
# It should be sourced into zsh to work properly.
# It can be useful for grepping, and awk & sed scripts for example, either sourced in a script or on the command line.
#
# Basic regular expressions are stored in the RXC_BRE array, extended regular expressions are stored in RXC_ERE,
# and perl compatible regular expressions are stored in RXC_PCRE.
# The array keys describe their associated regular expression values, e.g. RXC_ERE[csvfield]
# (use tab completion after [ to see all the keys).

# NOTES:

# grep supports BRE, ERE & PCRE, whereas awk & sed only support BRE & ERE however you can use the programming
# features of awk & sed to get the same results as PCRE. You can also run perl in sed mode with "perl -pe" which
# allows you to use sed command syntax but with perl regexps
# To learn more about PCRE see the perlre manpage.

# The only difference between BRE & ERE is that in BRE the following chars need to be prefixed with a backslash
# to give them special meaning: ?, +, (, ), {, }, and |

# Each regular expression is parenthesized, but may include useful subgroups. See the comments before each regexp.

# You can find more regular expressions here: http://regexlib.com/

# For testing purposes make sure the testregexp function is defined or is available in the same directory as this
# file, and source this file after setting TESTREGEXP to a non-empty string, like this:
# > TESTREGEXP=t source regex-collection.sh

# If parsing text files containing strange non-ascii chars some of these regexps might not match as intended.
# You can convert to ascii using "iconv -t ASCII//IGNORE" or "iconv -t ASCII//TRANSLIT" on the command line.
#

# LICENSE:

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; see the file COPYING.
# If not, see <http://www.gnu.org/licenses/>.

# TODO: finish writing tests and fix regexps

if [[ -r "$(dirname $0)/testregexp" ]]; then
    source "$(dirname $0)/testregexp"
fi

typeset -A RXC_BRE RXC_ERE RXC_PCRE
# quoted general purpose csv field, not including delimiters
# BRE & ERE versions don't check delimiters, PCRE version does
RXC_ERE[quotedcsvfield]="(?:\"[^\"]*\"|\'[^\']*\')"
RXC_BRE[quotedcsvfield]="\(\?:\"[^\"]*\"\|\'[^\']*\'\)"
RXC_PCRE[quotedcsvfield]="(?:(?:^|,)\K(?:\"[^\"]*\"|\'[^\']*\')(?=(?:,|$)))"
# unquoted general purpose csv field, not including delimiters
# BRE & ERE versions don't check delimiters, PCRE version does
RXC_ERE[unquotedcsvfield]="(?:[^\"'][^,]*|)"
RXC_BRE[unquotedcsvfield]="\(\?:[^\"'][^,]*\|\)"
RXC_PCRE[unquotedcsvfield]="(?:(?:^|,)\K(?:[^,\"\'][^,]*|)(?=(?:,|$)))"
# general purpose csv field, either quoted or unquoted, not including delimiters
# BRE & ERE versions don't check delimiters, PCRE version does
# e.g. find lines of data.csv where No. of csv fields isn't 10: grep -v -x -P "^${RXC_PCRE[csvfield]}{10}$" data.csv
# or: grep -v -x -E "^${RXC_ERE[csvfieldwithdelim]}{10}$" data.csv
RXC_ERE[csvfield]="(${RXC_ERE[quotedcsvfield]}|${RXC_ERE[unquotedcsvfield]})"
RXC_BRE[csvfield]="\(${RXC_ERE[quotedcsvfield]}\|${RXC_ERE[unquotedcsvfield]}\)"
RXC_ERE[csvfieldwithdelim]="((?:^|,)${RXC_ERE[csvfield]})"
RXC_BRE[csvfieldwithdelim]="\(\(\?:^\|,\)${RXC_ERE[csvfield]}\)"
RXC_PCRE[csvfield]="(${RXC_PCRE[quotedcsvfield]}|${RXC_PCRE[unquotedcsvfield]})"
if [[ -n ${TESTREGEXP} ]]; then
    echo testing CSVFIELD regexps
    testregexp "^${RXC_ERE[csvfield]}$" "'1,2,3'" "fsad" "\"foo\"" "\"as'cd'df\"" ""
    testregexp -n "^${RXC_ERE[csvfield]}$" "1,2,3" "\"a\"b\"" "'as'df'"
    testregexp -p "^${RXC_PCRE[csvfield]}$" "'1,2,3'" "fsad" "\"foo\"" "\"as'cd'df\"" ""
    testregexp -p -n "^${RXC_PCRE[csvfield]}$" "1,2,3" "\"a\"b\"" "'as'df'"
fi
# datestamp in the form DD/MM/YYYY & DD-MM-YYYY (contains 1 subgroup)
RXC_ERE[date/]="([0-9]{2}\/[0-9]{2}\/(19|20)[0-9]{2})"
RXC_ERE[date-]="([0-9]{2}-[0-9]{2}-(19|20)[0-9]{2})"
RXC_BRE[date/]="\([0-9]\{2\}\/[0-9]\{2\}\/\(19\|20\)[0-9]\{2\}\)"
RXC_BRE[date-]="\([0-9]\{2\}-[0-9]\{2\}-\(19\|20\)[0-9]\{2\}\)"
# datestamp in the form "DD/MM/YYYY HH:MM" and "DD-MM-YYYY HH:MM" (contains 1 subgroup)
RXC_ERE[datetime/]="([0-9]{2}\/[0-9]{2}\/(19|20)[0-9]{2} [012][0-9]:[012345][0-9])"
RXC_BRE[datetime/]="\([0-9]\{2\}\/[0-9]\{2\}\/\(19\|20\)[0-9]\{2\} [012][0-9]:[012345][0-9]\)"
RXC_ERE[datetime-]="([0-9]{2}-[0-9]{2}-(19|20)[0-9]{2} [012][0-9]:[012345][0-9])"
RXC_BRE[datetime-]="\([0-9]\{2\}-[0-9]\{2\}-\(19\|20\)[0-9]\{2\} [012][0-9]:[012345][0-9]\)"
# timestamp in the form HH:MM:SS
RXC_ERE[timehms]="([012][0-9]:[012345][0-9]:[012345][0-9])"
RXC_BRE[timehms]="\([012][0-9]:[012345][0-9]:[012345][0-9]\)"
# timestamp in the form HH:MM
RXC_ERE[timehm]="([012][0-9]:[012345][0-9])"
RXC_BRE[timehm]="\([012][0-9]:[012345][0-9]\)"
# hour of day (1 or 2 digits)
RXC_ERE[hour]="([012]?[0-9])"
RXC_BRE[hour]="\([012]\?[0-9]\)"
# minute of day (1 or 2 digits)
RXC_ERE[minute]="([012345]?[0-9])"
RXC_BRE[minute]="\([012345]\?[0-9]\)"
# part of day, morning, afternoon, evening or night
RXC_ERE[daypart]="([Mm]orning|[Aa]fternoon|[Ee]vening|[Nn]ight)"
RXC_BRE[daypart]="\([Mm]orning\|[Aa]fternoon\|[Ee]vening\|[Nn]ight\)"
RXC_PCRE[daypart]="((?i)morning|afternoon|evening|night)"
# weekday
RXC_ERE[weekday]="([Mm]onday|MONDAY|[Tt]uesday|TUESDAY|[Ww]ednesday|WEDNESDAY|[Tt]hursday|THURSDAY|[Ff]riday|FRIDAY)"
RXC_BRE[weekday]="\([Mm]onday\|MONDAY\|[Tt]uesday\|TUESDAY\|[Ww]ednesday\|WEDNESDAY\|[Tt]hursday\|THURSDAY\|[Ff]riday\|FRIDAY\)"
RXC_PCRE[weekday]="((?i)?mon(:?day)?|tue(:?sday)?|wed(:?nesday)?|thurs(:?day)?|fri(:?day)?|sat(:?urday)?|sun(:?day)?)"
# month
RXC_ERE[month]="([Jj]anuary)|JANUARY|[Ff]ebruary|FEBRUARY|[Mm]arch|MARCH|[Aa]pril|APRIL|[Mm]ay|MAY|[Jj]une|JUNE|[Jj]uly|JULY|[Aa]ugust|AUGUST|[Ss]eptember|SEPTEMBER|[Oo]ctober|OCTOBER|[Nn]ovember|NOVEMBER)"
RXC_BRE[month]="\([Jj]anuary\)\|JANUARY\|[Ff]ebruary\|FEBRUARY\|[Mm]arch\|MARCH\|[Aa]pril\|APRIL\|[Mm]ay\|MAY\|[Jj]une\|JUNE\|[Jj]uly\|JULY\|[Aa]ugust\|AUGUST\|[Ss]eptember\|SEPTEMBER\|[Oo]ctober\|OCTOBER\|[Nn]ovember\|NOVEMBER\)"
RXC_PCRE[month]="((?i)jan(?:uary)?|feb(?:ruary)?|mar(?:ch)?|apr(?:il)?|may|jun(?:e)?|jul(?:y)?|aug(?:ust)?|sept(?:ember)?|oct(:?ober)?|nov(?:ember)?|dec(:?ember)?)"
# year between 1900 and 2099
RXC_ERE[year]="(19[0-9]{2}|20[0-9]{2})"
RXC_BRE[year]="\(19[0-9]\{2\}\|20[0-9]\{2\}\)"
# database table storage row key with 18 digits
RXC_ERE[databaserowkey]="([0-9]{18})"
RXC_BRE[databaserowkey]="\([0-9]\{18\}\)"
# arbitrary size decimal number
RXC_ERE[number]="([0-9]+\.?[0-9]*)"
RXC_BRE[number]="\([0-9]+\.\?[0-9]*\)"
# arbitrary size integer
RXC_ERE[integer]="([0-9]+)"
RXC_BRE[integer]="\([0-9]+\)"
# letters only (no punctuation or whitespace)
RXC_ERE[letters]="([[:alpha]]+)"
RXC_BRE[letters]="\([[:alpha]]+\)"
# letters and numbers (no punctuation or whitespace)
RXC_ERE[alnum]="([[:alnum:]]+)"
RXC_BRE[alnum]="\([[:alnum:]]+\)"
# UK postcode
RXC_ERE[ukpostcode]="([a-zA-Z]{1,2}[0-9][0-9A-Za-z]{0,1} ?[0-9]?[A-Za-z]{2})"
RXC_BRE[ukpostcode]="\([a-zA-Z]\{1,2\}[0-9][0-9A-Za-z]\{0,1\} \?[0-9]\?[A-Za-z]\{2\}\)"
# ONS/GSS Output Area code (see here: https://en.wikipedia.org/wiki/ONS_coding_system)
RXC_ERE[ons_code]="(E|J|K|L|M|N|S|W|)[0-9]{8}"
RXC_BRE[ons_code]="\(E\|J\|K\|L\|M\|N\|S\|W\|\)[0-9]\{8\}"
RXC_ERE[ons_oa]="E00[0-9]{6}"
RXC_BRE[ons_oa]="E00[0-9]\{6\}"
RXC_ERE[ons_lsoa]="(E|W)01[0-9]{6}"
RXC_BRE[ons_lsoa]="\(E\|W\)01[0-9]\{6\}"
RXC_ERE[ons_soa]="(E|W)0(0|1|2|3)[0-9]{6}"
RXC_BRE[ons_soa]="\(E\|W\)0\(0\|1\|2\|3\)[0-9]\{6\}"
# NUTS (Nomenclature of Territorial Units for Statistics) area codes
RXC_ERE[nuts]="[A-Z][A-Z][1-9A-Z]{1,3}"
RXC_BRE[nuts]="[A-Z][A-Z][1-9A-Z]\{1,3\}"
RXC_ERE[nuts1]="[A-Z][A-Z][1-9A-Z]"
RXC_BRE[nuts1]="[A-Z][A-Z][1-9A-Z]"
RXC_ERE[nuts2]="[A-Z][A-Z][1-9A-Z][1-9A-Z]"
RXC_BRE[nuts2]="[A-Z][A-Z][1-9A-Z][1-9A-Z]"
RXC_ERE[nuts3]="[A-Z][A-Z][1-9A-Z][1-9A-Z][0-9A-Z]"
RXC_BRE[nuts3]="[A-Z][A-Z][1-9A-Z][1-9A-Z][0-9A-Z]"
# FIPS (Federal Information Processing Standards) codes
RXC_ERE[fips104]="[A-Z][A-Z][0-9][0-9]"
RXC_BRE[fips104]="[A-Z][A-Z][0-9][0-9]"
# email address
RXC_ERE[email]="(\w[[:alnum:]._-]*\w@\w[[:alnum:].-]*\w\.\w{2,3})"
RXC_BRE[email]="\(\w[[:alnum:]._-]*\w@\w[[:alnum:].-]*\w\.\w\{2,3\}\)"
# UK phone number (contains 1 subgroup - the area code)
RXC_ERE[ukphone]="(\s*\(?0[0-9]{3,5}\)?\s*[0-9]{3,4}\s*[0-9]{3,4}\s*)"
RXC_BRE[ukphone]="\(\s*(\?0[0-9]\{3,5\})\?\s*[0-9]\{3,4\}\s*[0-9]\{3,4\}\s*\)"
# international phone number: optional country code followed by area code surrounded with '-' or '(' and ')',
# or just an area code optionally starting with 0, followed by phone numder. The number itself may contain spaces and '-'
# (contains 2 subgroups)
RXC_ERE[intlphone]="((\+[1-9][0-9]*(\([0-9]*\)|-[0-9]*-))?[0]?[1-9][0-9\ -]*)"
RXC_BRE[intlphone]="\(\(+[1-9][0-9]*\(([0-9]*)\|-[0-9]*-\)\)\?[0]\?[1-9][0-9\ -]*\)"
# 3-14 char password starting with a letter 
RXC_ERE[password]="([a-zA-Z]\w{3,14})"
RXC_BRE[password]="\([a-zA-Z]\w\{3,14\}\)"
# Network port (0-65535)
RXC_ERE[port]="([0-9]{1,4}|[0-6][0-9]{4})"
RXC_BRE[port]="\([0-9]\{1,4\}\|[0-6][0-9]\{4\}\)"
RXC_ERE[port_exact]="([1-9][0-9]{0,3}|[1-5][0-9]{4}|6([0-4][0-9]{3}|5([0-4][0-9]{2}|5[0-2][0-9]|53[0-5])))"
RXC_BRE[port_exact]="\([1-9][0-9]\{0,3\}\|[1-5][0-9]\{4\}\|6\([0-4][0-9]\{3\}\|5\([0-4][0-9]\{2\}\|5[0-2][0-9]\|53[0-5]\)\)\)"
# Well-known/system port (1-1023)
RXC_ERE[system_port]="([0-9]{3}|10[0-9]{2})"
RXC_BRE[system_port]="\([0-9]\{3\}\|10[0-9]\{2\}\)"
# Registered port (1024-49151)
RXC_ERE[registered_port]="([0-9]{4}|[0-4][0-9]{4})"
RXC_BRE[registered_port]="\([0-9]\{4\}\|[0-4][0-9]\{4\}\)"
# Dynamic/private port (49152-65535)
RXC_ERE[dynamic_port]="([4-6][0-9]{4})"
RXC_BRE[dynamic_port]="\([4-6][0-9]\{4\}\)"
# Network subnet
RXC_ERE[subnet_prefix_len]="([0-9]|[0-2][0-9]|3[0-2])"
RXC_BRE[subnet_prefix_len]="\([0-9]\|[0-2][0-9]\|3[0-2]\)"
# MAC address (contains 2 subgroups)
RXC_ERE[mac]="(([0-9a-fA-F][0-9a-fA-F]:){5}([0-9a-fA-F][0-9a-fA-F]))"
RXC_BRE[mac]="\(\([0-9a-fA-F][0-9a-fA-F]:\)\{5\}\([0-9a-fA-F][0-9a-fA-F]\)\)"
# IPv4 address with optional port or subnet (contains 3 subgroups - 1st octet, final 3 octets & optional :port/subnet)
RXC_ERE[ipv4]="((25[0-5]|2[0-4][0-9]|1?[0-9]{1,2})(\.(25[0-5]|2[0-4][0-9]|1?[0-9]{1,2})){3}(:${RXC_ERE[port]}|\/${RXC_ERE[subnet_prefix_len]})?)"
RXC_BRE[ipv4]="\(\(25[0-5]\|2[0-4][0-9]\|1\?[0-9]\{1,2\}\)\(\.\(25[0-5]\|2[0-4][0-9]\|1\?[0-9]\{1,2\}\)\)\{3\}\(:${RXC_BRE[port]}\|\/${RXC_BRE[subnet_prefix_len]}\)\?\)"
# IPv6 address (compressed or uncompressed) with optional port or subnet
# (contains 3 subgroups - 1st octet, final 3 octets & optional :port/subnet)
RXC_ERE[ipv6]="(([0-9a-fA-F]{0,4}:){2,7}(:|[0-9a-fA-F]{1,4})(:${RXC_ERE[port]}|\/${RXC_ERE[subnet_prefix_len]})?)"
RXC_BRE[ipv6]="\(\([0-9a-fA-F]\{0,4\}:\)\{2,7\}\(:\|[0-9a-fA-F]\{1,4\}\)\(:${RXC_BRE[port]}\|\/${RXC_BRE[subnet_prefix_len]}\)\?\)"
# Version 3/4 UUID 
RXC_ERE[uuid]="([A-Fa-f0-9]{8}-[A-Fa-f0-9]{4}-[34][A-Fa-f0-9]{3}-[89ab][A-Fa-f0-9]{3}-[A-Fa-f0-9]{12})"
RXC_BRE[uuid]="\([A-Fa-f0-9]\{8\}-[A-Fa-f0-9]\{4\}-[34][A-Fa-f0-9]\{3\}-[89ab][A-Fa-f0-9]\{3\}-[A-Fa-f0-9]\{12\}\)"
# domain names
RXC_ERE[domain_name]="([a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,})"
RXC_BRE[domain_name]="\([a-zA-Z0-9\-\.]+\.[a-zA-Z]\{2,\}\)"
# Any valid http/https/ftp URL (contains 3 subgroups - the protocol, domain name, and optional query at the end of the URL)
RXC_ERE[url]="((https?|ftp):\/\/${RXC_ERE[domain_name]}(\/\S*)?)"
RXC_BRE[url]="\(\(https\?\|ftp\):\/\/${RXC_ERE[domain_name]}\(\/\S*\)\?\)"
# An FTP URL (contains 2 subgroups - the domain name and optional query at the end of the URL)
RXC_ERE[ftp]="(ftp:\/\/${RXC_ERE[domain_name]}(\/\S*)?)"
RXC_BRE[ftp]="\(ftp:\/\/${RXC_ERE[domain_name]}\(\/\S*\)\?\)"
# An HTTP URL (contains 2 subgroups - the domain name and optional query at the end of the URL)
RXC_ERE[http]="(http:\/\/${RXC_ERE[domain_name]}(\/\S*)?)"
RXC_BRE[http]="\(http:\/\/${RXC_ERE[domain_name]}\(\/\S*\)\?\)"
# An HTTPS URL (contains 2 subgroups - the domain name and optional query at the end of the URL)
RXC_ERE[https]="(https:\/\/${RXC_ERE[domain_name]}(\/\S*)?)"
RXC_BRE[https]="\(https:\/\/${RXC_ERE[domain_name]}\(\/\S*\)\?\)"
# Output from 'ls -l', with the following subgroups:
# \1 = file permissions, \2 = number of files, \3 = GID, \4 = UID, \5 = size, \6 = date, \7 = filename
RXC_ERE[ll]="([rwdx-]{10})\s+([0-9]+)\s+([a-z]+) ([a-z]+)\s+([0-9.KMG]+) ([a-zA-Z]+\s+[0-9]+\s+[0-9:]+) (.+)$"
RXC_BRE[ll]="\([rwdx-]\{10\}\)\s+\([0-9]+\)\s+\([a-z]+\) \([a-z]+\)\s+\([0-9.KMG]+\) \([a-zA-Z]+\s+[0-9]+\s+[0-9:]+\) \(.+\)$"
