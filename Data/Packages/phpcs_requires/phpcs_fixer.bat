@ECHO OFF
SET PHP="D:\\WindowsSoftWare\\php55\php.exe"
SET php_fixer="D:\\WindowsSoftWare\\phpcs_requires\\php-cs-fixer.phar"
%PHP% -d output_buffering=1 -f %php_fixer% -- %1 %2 %3 %4 %5 %6 %7 %8 %9
@ECHO ON