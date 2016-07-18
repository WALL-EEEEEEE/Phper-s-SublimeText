@ECHO OFF
SET PHP="D:\\WindowsSoftWare\\php53\php.exe"
SET BEAUTIFY="D:\\WindowsSoftWare\\phpcs_requires\phpcbf.phar"
%PHP% -d output_buffering=1 -f %BEAUTIFY% -- %1 %2 %3 %4 %5 %6 %7 %8 %9
@ECHO ON