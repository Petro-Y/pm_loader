::set inbox and outbox URLs....
@echo off
set base=http://replace.org.ua/pun_pm/
set cookies=cookies.txt
::::::::::::

for /f %%i in ('"echo %date%_%time%|sed -e y/:/_/ -e s/,.*// -e s/[^^0-9_.]/0/g"') do set dirname=pm_%%i
md %dirname% & cd %dirname%
set box=inbox
call :download
set box=outbox
call :download
pause
goto :eof

::for each of them:
:download
	echo Downloading: %box%...
	md %box%
	md %box%\page
	set page=1
:loadnext
	set /a nextpage=page + 1
	wget --load-cookies="%cookies%" %base%%box%/page/%page%/ -O - >%box%\page\%page%.html
	set onemore=no
	for /f %%i in ('sed -e "\#%base%%box%/page/%nextpage%/#!d" %box%\page\%page%.html') do set onemore=yes
	set page=%nextpage%
	if %onemore%==yes goto loadnext
	::goto :eof
	::for each downloaded in/outbox list page:
	for %%p in (%box%\page\*) do (
		for /f %%i in ('sed -e "\#%base%%box%/[0-9][0-9]*/#!d" -e "s#^.*%base%%box%/\([0-9][0-9]*\)/.*$#\1#" %%p') do (
			wget --load-cookies="%cookies%" %base%%box%/%%i/ -O - >%box%\%%i.html
			)
		)
	::correct refs in list pages....
	for %%p in (%box%\page\*) do (
		move %%p %%p.tmp
		sed -e "s#%base%\([a-z0-9/]*\)/\([""]\)#../../\1.html\2#g" <%%p.tmp>%%p 
		)
	::correct refs in messages.....
	
