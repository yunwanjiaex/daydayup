for /f "tokens=2 delims=:(" %%i in ('powercfg /duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61') do set guid=%%i
set guid=%guid: =%
powercfg /setactive %guid%
powercfg /h off