@echo off
setlocal enabledelayedexpansion
rem 保存当前路径
set currentPath=%~dp0
rem 保存当前驱动器盘符
set currentDriver=%~d0
rem 直接使用批处理文件的相对路径
%currentDriver%
cd "%currentPath%"

echo currentPath=%currentPath%

rem *****************************************************************************************************
rem * mysql5.7.21下测试通过：https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.21-winx64.zip
rem * 1. 从当前目录初始化数据库
rem * 2. 设置默认密码为root123
rem *****************************************************************************************************

rem 指定mysql的基础安装路径
set mysql_basedir=%currentPath%

rem *****************************************************************************************************
rem * 把参数mysql_basedir末尾的斜杠去掉 begin
rem *****************************************************************************************************
set /a n = 0
set str=%mysql_basedir%
:next_str_cal
if not "x%str%"=="x" (
	set /a n=n+1
	set curChar=%str:~0,1%
	set "str=%str:~1%"
	goto next_str_cal
)

set newstr=%mysql_basedir%
echo newstr=%newstr%
set new_basedir=
set /a i = 0
if not "x%curChar%"=="x\" (
	set new_basedir=%mysql_basedir%
)
if "x%curChar%"=="x\" (
	:next_str_cat
	if not "x%newstr%"=="x" (
		set /a i=i+1
		set cur_Char=%newstr:~0,1%
		set "newstr=%newstr:~1%"
		if %i% LSS %n% (
			set new_basedir=%new_basedir%%cur_Char%
		)
		goto next_str_cat
	)
)
set mysql_basedir=%new_basedir%
echo mysql_basedir=%mysql_basedir%
rem *****************************************************************************************************
rem * 把参数mysql_basedir末尾的斜杠去掉 end
rem *****************************************************************************************************


rem 指定mysql的bin目录
set mysql_bin=%mysql_basedir%\bin
rem 指定存放数据的目录(注意必须是一个不存在的空目录)
set mysql_data=%mysql_basedir%\data
rem 指定自动生成的mysql配置文件
set mysql_ini_file=%currentPath%my.ini
set mysql_cnf_file=%mysql_basedir%\my.cnf
set mysql_install_bat=%currentPath%\Install.bat
set mysql_uninstall_bat=%currentPath%\UnInstall.bat
set mysql_start_bat=%currentPath%\start.bat
set mysql_stop_bat=%currentPath%\stop.bat
set mysql_reset_root_password_bat=%currentPath%\reset_root_password.bat


rem ** 这里根据需要覆盖参数 **
set mysql_data=%currentPath%data

if not exist "%mysql_bin%\mysqld.exe" (
	echo 请确认参数mysql_basedir，没找到%mysql_bin%\mysqld.exe
	goto success_exit
)

if not exist "%mysql_bin%\mysql.exe" (
	echo 请确认参数mysql_basedir，没找到%mysql_bin%\mysql.exe
	goto success_exit
)

rem 显示当前mysql版本号
"%mysql_bin%\mysql.exe" --version

if exist "%mysql_data%" (
	echo 请确认参数mysql_data=%mysql_data%，必须是一个不存在的空目录，当前检测到目录已经存在！
	goto success_set
)

rem --initialize-insecure 是root没密码的初始化
rem --initialize 生成的root不清楚密码是什么样的
echo "%mysql_bin%\mysqld.exe" --initialize-insecure --user=mysql --basedir="%mysql_basedir%" --datadir="%mysql_data%"
"%mysql_bin%\mysqld.exe" --initialize-insecure --user=mysql --basedir="%mysql_basedir%" --datadir="%mysql_data%"
if %errorlevel% neq 0 (
	echo 初始化数据目录"%mysql_data%"错误！
	goto success_exit
)

rem SET PASSWORD FOR 'some_user'@'some_host' = PASSWORD('password');
rem SET PASSWORD FOR 'root'@'%' = PASSWORD('root123');
rem 启动时增加--skip-grant-tables参数就会跳过密码验证，可以操作数据，但不能重置密码
rem 修改密码用：mysqladmin -u root -h 127.0.0.1 password "root123"
echo "%mysql_bin%\mysqld.exe" --defaults-file="%mysql_ini_file%" --console

:success_set

rem ***************************************************************************
rem 处理ini路径参数ini_mysql_basedir
set replaceValue=
set curChar=
set newStrValue=%mysql_basedir%
:next_mysql_basedir
if not "%newStrValue%"=="" (
	set curChar=%newStrValue:~0,1%
	if "%curChar%"=="\" ( 
		set replaceValue=%replaceValue%\\
	)
	if not "%curChar%"=="\" (
		set replaceValue=%replaceValue%%curChar%
	)
    set newStrValue=%newStrValue:~1%
    goto next_mysql_basedir
)
if "%curChar%"=="\" ( 
	set curChar=\\
)
if not "%curChar%"=="\" (
	set replaceValue=%replaceValue%%curChar%
)
set ini_mysql_basedir=%replaceValue%
echo ini_mysql_basedir=%replaceValue%

rem ***************************************************************************
rem 处理ini路径参数ini_mysql_data
set replaceValue=
set curChar=
set newStrValue=%mysql_data%
:next_mysql_data
if not "%newStrValue%"=="" (
	set curChar=%newStrValue:~0,1%
	if "%curChar%"=="\" ( 
		set replaceValue=%replaceValue%\\
	)
	if not "%curChar%"=="\" (
		set replaceValue=%replaceValue%%curChar%
	)
    set newStrValue=%newStrValue:~1%
    goto next_mysql_data
)
if "%curChar%"=="\" ( 
	set curChar=\\
)
if not "%curChar%"=="\" (
	set replaceValue=%replaceValue%%curChar%
)
set ini_mysql_data=%replaceValue%
echo ini_mysql_data=%replaceValue%


rem 生成配置文件my.cnf
echo [client] > "%mysql_cnf_file%"
echo port=3306 >> "%mysql_cnf_file%"
echo character-sets-dir=%ini_mysql_basedir%\\share\\charsets >> "%mysql_cnf_file%"
echo default-character-set=utf8 >> "%mysql_cnf_file%"

rem 生成配置文件my.ini
echo [client] > "%mysql_ini_file%"
echo default-character-set=utf8 >> "%mysql_ini_file%"
echo [mysqld] >> "%mysql_ini_file%"
echo # set basedir to your installation path >> "%mysql_ini_file%"
echo basedir=%ini_mysql_basedir% >> "%mysql_ini_file%"
echo # set datadir to the location of your data directory >> "%mysql_ini_file%"
echo datadir=%ini_mysql_data% >> "%mysql_ini_file%"
echo character-set-server=utf8 >> "%mysql_ini_file%"

rem 生成注册安装windows服务批处理Install.bat
echo "%mysql_bin%\mysqld.exe" --install mysql > "%mysql_install_bat%"

rem 生成卸载服务批处理
echo net stop mysql > "%mysql_uninstall_bat%"
echo "%mysql_bin%\mysqld.exe" --remove >> "%mysql_uninstall_bat%"

rem 生成启动服务批处理
echo net start mysql > "%mysql_start_bat%"

rem 生成停止服务批处理
echo net stop mysql > "%mysql_stop_bat%"

rem 生成重置密码批处理
echo "%mysql_bin%\mysqladmin.exe" -u root -h 127.0.0.1 password "root123" > "%mysql_reset_root_password_bat%"


echo 命令行启动："%mysql_bin%\mysqld.exe" --defaults-file="%mysql_ini_file%" --console
echo 修改root密码："%mysql_bin%\mysqladmin.exe" -u root -h 127.0.0.1 password "root123"
echo 命令行连接："%mysql_bin%\mysql.exe" -uroot -proot123 -h 127.0.0.1
echo 安装服务：install.bat
echo 卸载服务：uninstall.bat
echo 启动服务：start.bat
echo 停止服务：stop.bat
echo 重置root密码：reset_root_password.bat

call "%mysql_install_bat%"
call "%mysql_start_bat%"
call "%mysql_reset_root_password_bat%"

ping 127.0.0.1 -n 3 > nil

:success_exit

@echo off

echo show variables like "%char%"; | "%mysql_bin%\mysql.exe" -uroot -proot123 -h 127.0.0.1