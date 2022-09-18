@rem
@rem Copyright 2020 the original author jacky.eastmoon
@rem All commad module need 3 method :
@rem [command]        : Command script
@rem [command]-args   : Command script options setting function
@rem [command]-help   : Command description
@rem Basically, CLI will not use "--options" to execute function, "--help, -h" is an exception.
@rem But, if need exception, it will need to thinking is common or individual, and need to change BREADCRUMB variable in [command]-args function.
@rem NOTE, batch call [command]-args it could call correct one or call [command] and "-args" is parameter.
@rem

:: ------------------- batch setting -------------------
@rem setting batch file
@rem ref : https://www.tutorialspoint.com/batch_script/batch_script_if_else_statement.htm
@rem ref : https://poychang.github.io/note-batch/

@echo off
setlocal
setlocal enabledelayedexpansion

:: ------------------- declare CLI file variable -------------------
@rem retrieve project name
@rem Ref : https://www.robvanderwoude.com/ntfor.php
@rem Directory = %~dp0
@rem Object Name With Quotations=%0
@rem Object Name Without Quotes=%~0
@rem Bat File Drive = %~d0
@rem Full File Name = %~n0%~x0
@rem File Name Without Extension = %~n0
@rem File Extension = %~x0

set CLI_DIRECTORY=%~dp0
set CLI_FILE=%~n0%~x0
set CLI_FILENAME=%~n0
set CLI_FILEEXTENSION=%~x0

:: ------------------- declare CLI variable -------------------

set BREADCRUMB=cli
set COMMAND=
set COMMAND_BC_AGRS=
set COMMAND_AC_AGRS=

:: ------------------- declare variable -------------------

for %%a in ("%cd%") do (
    set PROJECT_NAME=%%~na
)
set PROJECT_ENV=dev

:: ------------------- execute script -------------------

call :main %*
goto end

:: ------------------- declare function -------------------

:main (
    set COMMAND=
    set COMMAND_BC_AGRS=
    set COMMAND_AC_AGRS=
    call :argv-parser %*
    call :main-args-parser %COMMAND_BC_AGRS%
    IF defined COMMAND (
        set BREADCRUMB=%BREADCRUMB%-%COMMAND%
        findstr /bi /c:":!BREADCRUMB!" %CLI_FILE% >nul 2>&1
        IF errorlevel 1 (
            goto cli-help
        ) else (
            call :main %COMMAND_AC_AGRS%
        )
    ) else (
        call :%BREADCRUMB%
    )
    goto end
)
:main-args-parser (
    for /f "tokens=1*" %%p in ("%*") do (
        for /f "tokens=1,2 delims==" %%i in ("%%p") do (
            call :%BREADCRUMB%-args %%i %%j
            call :common-args %%i %%j
        )
        call :main-args-parser %%q
    )
    goto end
)
:common-args (
    set COMMON_ARGS_KEY=%1
    set COMMON_ARGS_VALUE=%2
    if "%COMMON_ARGS_KEY%"=="-h" (set BREADCRUMB=%BREADCRUMB%-help)
    if "%COMMON_ARGS_KEY%"=="--help" (set BREADCRUMB=%BREADCRUMB%-help)
    goto end
)
:argv-parser (
    for /f "tokens=1*" %%p in ("%*") do (
        IF NOT defined COMMAND (
            echo %%p | findstr /r "\-" >nul 2>&1
            if errorlevel 1 (
                set COMMAND=%%p
            ) else (
                set COMMAND_BC_AGRS=!COMMAND_BC_AGRS! %%p
            )
        ) else (
            set COMMAND_AC_AGRS=!COMMAND_AC_AGRS! %%p
        )
        call :argv-parser %%q
    )
    goto end
)

:: ------------------- Main method -------------------

:cli (
    goto cli-help
)

:cli-args (
    set COMMON_ARGS_KEY=%1
    set COMMON_ARGS_VALUE=%2
    goto end
)

:cli-help (
    echo This is a Command Line Interface with project %PROJECT_NAME%
    echo If not input any command, at default will show HELP
    echo.
    echo Options:
    echo      --help, -h        Show more information with CLI.
    echo.
    echo Command:
    echo      perl              Startup development mode with Nginx + FastCGI + Perl.
    echo      python            Startup development mode with Nginx + FastCGI + Python.
    echo.
    echo Run 'cli [COMMAND] --help' for more information on a command.
    goto end
)

:: ------------------- Common Command method -------------------

:create-docker-network (
    docker network ls > .tmp
    docker run -ti --rm -v %CLI_DIRECTORY%\.tmp:/.tmp bash -l -c "cat /.tmp | grep %PROJECT_NAME%-network | wc -l" > .flag
    set /p is_create=<.flag
    if "%is_create%" == "0" (
        docker network create %PROJECT_NAME%-network
    ) else (
        echo "Netwwork %PROJECT_NAME%-network is exist."
    )
    if exist .tmp (
        del .tmp
    )
    if exist .flag (
        del .flag
    )
    goto end
)
:remove-container (
    docker rm -f restful-cgi-%PROJECT_NAME%
    goto end
)

:: ------------------- Command "perl" method -------------------

:cli-perl (
    echo ^> Startup development mode with Nginx
    docker build --rm^
        -t nginx:pl-%PROJECT_NAME%^
        .\conf\perl
    call :remove-container
    call :create-docker-network
    if NOT "%COMMAND_ACTION%"=="down" (
        docker run -d ^
            -p 80:80 ^
            -v %cd%\src/perl/cgi:/usr/share/nginx/html/cgi-bin ^
            -v %cd%\src/perl/html:/usr/share/nginx/html ^
            -w /usr/share/nginx/html/cgi-bin ^
            --network %PROJECT_NAME%-network ^
            --hostname cgi-service ^
            --name restful-cgi-%PROJECT_NAME% ^
            nginx:pl-%PROJECT_NAME%
    )
    if "%COMMAND_ACTION%"=="into" (
        docker exec -ti restful-cgi-%PROJECT_NAME% bash
    )

    goto end
)

:cli-perl-args (
    set COMMON_ARGS_KEY=%1
    set COMMON_ARGS_VALUE=%2
    if "%COMMON_ARGS_KEY%"=="--into" (set COMMAND_ACTION=into)
    if "%COMMON_ARGS_KEY%"=="--down" (set COMMAND_ACTION=down)
    goto end
)

:cli-perl-help (
    echo This is a Command Line Interface with project %PROJECT_NAME%
    echo Startup development mode with Nginx + FastCGI + Perl
    echo.
    echo Options:
    echo      --help, -h        Show more information with UP Command.
    echo      --into            Going to container.
    echo      --down            Close down container.
    goto end
)

:: ------------------- Command "python" method -------------------

:cli-python (
    echo ^> Startup development mode with Nginx
    docker build --rm^
        -t nginx:py-%PROJECT_NAME%^
        .\conf\python
    call :remove-container
    call :create-docker-network
    if NOT "%COMMAND_ACTION%"=="down" (
        docker run -d ^
            -p 80:80 ^
            -v %cd%\src/python/cgi:/usr/share/nginx/html/cgi-bin ^
            -v %cd%\src/python/html:/usr/share/nginx/html ^
            -w /usr/share/nginx/html/cgi-bin ^
            --network %PROJECT_NAME%-network ^
            --hostname cgi-service ^
            --name restful-cgi-%PROJECT_NAME% ^
            nginx:py-%PROJECT_NAME%
    )
    if "%COMMAND_ACTION%"=="into" (
        docker exec -ti restful-cgi-%PROJECT_NAME% bash
    )

    goto end
)

:cli-python-args (
    set COMMON_ARGS_KEY=%1
    set COMMON_ARGS_VALUE=%2
    if "%COMMON_ARGS_KEY%"=="--into" (set COMMAND_ACTION=into)
    if "%COMMON_ARGS_KEY%"=="--down" (set COMMAND_ACTION=down)
    goto end
)

:cli-python-help (
    echo This is a Command Line Interface with project %PROJECT_NAME%
    echo Startup development mode with Nginx + FastCGI + Python
    echo.
    echo Options:
    echo      --help, -h        Show more information with UP Command.
    echo      --into            Going to container.
    echo      --down            Close down container.
    goto end
)

:: ------------------- End method-------------------

:end (
    endlocal
)
