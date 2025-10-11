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

procedure RootCreate; { Создание корневой папки, где будут находиться ядра и загрузчик }
const PATHS: array[1..9] of string = (
          'root',
          'root/boot',
          'root/boot/neoinit',
          'root/config',
          'root/data',
          'root/data/programs',
          'root/data/user',
          'root/system',
          'root/system/modules'
      );
var i: integer;
begin
    for i := low(PATHS) to high(PATHS) do
    begin
        if not directoryexists(PATHS[i]) then
            mkdir(PATHS[i]);
    end;
end;

function FileCopy(const filename: string; const dest: string): integer;
begin
    executeprocess('/bin/cp', [filename, dest]);
    
    Filecopy := 0;
end;

procedure CopyKernels;
var k: TSearchRec;
begin
    if FindFirst('./kernels/main/*.bin', faReadOnly, k) = 0 then
    begin
        repeat
            executeprocess('/bin/cp', ['./kernels/main/' + k.name, './root/boot']);
        until findnext(k) <> 0;
        
        findclose(k);
    end;
    
    if FindFirst('./kernels/recovery/*.bin', faReadOnly, k) = 0 then
    begin
        repeat
            executeprocess('/bin/cp', ['./kernels/recovery/' + k.name, './root/boot']);
        until findnext(k) <> 0;
        
        findclose(k);
    end;
end;

procedure Clean;
var f: TSearchRec; f1: text;
begin
    if FindFirst('*.pas', faReadOnly, f) = 0 then
    begin
        repeat
            assign(f1, f.name);
            erase(f1);
        until findnext(f) <> 0;
        
        findclose(f);
    end;
    
    if FindFirst('*.o', faReadOnly, f) = 0 then
    begin
        repeat
            assign(f1, f.name);
            erase(f1);
        until findnext(f) <> 0;
        
        findclose(f);
    end;
    
    if FindFirst('*.ppu', faReadOnly, f) = 0 then
    begin
        repeat
            assign(f1, f.name);
            erase(f1);
        until findnext(f) <> 0;
        
        findclose(f);
    end;
end;

procedure Compile; { Основная процедура где запускается компиляция ядра }
begin

  if (fileexists('./bootloader/bootloader.pas')) and (fileexists('./bootloader/osboot.pas')) then { Проверка наличия исходников }
    begin
        RootCreate; { создается корневая фс }
        writeln('Installing system...');
        CopyKernels;
        Filecopy('./bootloader/osboot.pas', './boot.pas');
        Filecopy('./bootloader/bootloader.pas', './bootloader.pas');
        write('->Compiling bootloader...');
        executeprocess('/bin/bash', ['-c', 'fpc boot.pas -oBootloader.bin > /dev/null 2>&1']); { я использовал данную процедуру для симуляции установки загрузчика }
        ScreenUpdate('->Creating dir /boot...'); sleep(1000);
        ScreenUpdate('->Installing NeoInit bootloader...'); sleep(1500);
            BootLoaderGen;
        ScreenUpdate('Installed Successful. Execute in terminal "./Bootloader.bin" to run bootloader.'#10);
        Clean;
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
