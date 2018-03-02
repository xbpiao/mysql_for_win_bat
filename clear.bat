@echo off
setlocal enabledelayedexpansion
rem 保存当前路径
set currentPath=%~dp0
rem 保存当前驱动器盘符
set currentDriver=%~d0
rem 直接使用批处理文件的相对路径
%currentDriver%
cd "%currentPath%"

rem 指定mysql的基础安装路径
set mysql_basedir=%currentPath%
rem 指定mysql的bin目录
set mysql_bin=%mysql_basedir%\bin

if not exist "%mysql_bin%\mysqld.exe" (
	echo 请确认参数mysql_basedir，没找到%mysql_bin%\mysqld.exe
	goto success_exit
)

if not exist "%mysql_bin%\mysql.exe" (
	echo 请确认参数mysql_basedir，没找到%mysql_bin%\mysql.exe
	goto success_exit
)

rem 清除数据
if exist "%currentPath%\UnInstall.bat" (
	call "%currentPath%\UnInstall.bat"
	del /q "%currentPath%\UnInstall.bat"
)

if exist "%currentPath%\Install.bat" (
	del /q "%currentPath%\Install.bat"
)

if exist "%currentPath%\start.bat" (
	del /q "%currentPath%\start.bat"
)

if exist "%currentPath%\stop.bat" (
	del /q "%currentPath%\stop.bat"
)

if exist "%currentPath%\reset_root_password.bat" (
	del /q "%currentPath%\reset_root_password.bat"
)

if exist "%currentPath%\my.ini" (
	del /q "%currentPath%\my.ini"
)

if exist "%currentPath%\my.cnf" (
	del /q "%currentPath%\my.cnf"
)

if exist "%currentPath%data" (
	del /q /s "%currentPath%data"
	rd /q /s "%currentPath%data"
)

:success_exit

@echo off