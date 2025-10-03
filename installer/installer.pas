program Installer;

uses crt, sysutils, process;

procedure ScreenUpdate(const s:string); { функция заменяет текущую строку на строку "s" }
begin
    gotoxy(1, wherey);
    clreol;
    write(s);
end;

procedure BootLoaderGen; { Создание файла загрузчика }
begin
    if fileexists('./root/boot/neoinit/loader') then
        write('Loader already exists!')
    else
        filecreate('./root/boot/neoinit/loader');
end;

procedure RootCreate; { Создание корневой папки и папки /boot, где будут находиться ядра и загрузчик }
begin
    if directoryexists('root')=false then
        mkdir('root');
    if directoryexists('./root/boot')=false then
        mkdir('./root/boot');
    if directoryexists('./root/boot/neoinit')=false then
        mkdir('./root/boot/neoinit');
    if directoryexists('./root/config')=false then
        mkdir('./root/config');
    if directoryexists('./root/system')=false then
        mkdir('./root/system');
    {if directoryexists('./root/boot/modules')=false then
        mkdir('./root/boot/modules');}
    //данная папка в ближайшее время не понадобится
end;

procedure Compile; { Основная процедура где запускается компиляция ядра }
begin

  if (fileexists('bootloader.pas')) and (fileexists('osboot.pas')) then { Проверка наличия исходников }
    begin
        RootCreate; { создается корневая фс }
        writeln('Installing system...');
        executeprocess('/bin/bash', ['-c', 'make > /dev/null 2>&1']); { это bash вставка, я ее использовал чтобы перенаправить вывод make(который мне не нужен) в файл /dev/null(в makefile вызывается fpc, у которого есть свой вывод по типу "Target OS: linux", и тд и тп) }
        write('->Compiling kernel...');
        ScreenUpdate('->Creating dir /boot...'); sleep(1000);
        ScreenUpdate('->Installing NeoInit bootloader...'); sleep(1500);
            BootLoaderGen;
        ScreenUpdate('Installed Successful. Execute in terminal "BootLoader.bin" to run your system.'#10);
    end
  else
  begin
    writeln('You don`t have necessary source codes!');
    halt(1); { вывод ошибки если не найдены исходники }
  end;
end;

begin
    clrscr;
    Compile;
end.
