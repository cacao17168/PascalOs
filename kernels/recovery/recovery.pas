program RecoveryKernel;

uses crt, sysutils;

procedure ScreenUpdate(s:string); { процедура заменяет текущую строку на строку "s" }
begin
    gotoxy(1, wherey);
    clreol;
    write(s);
end;

procedure RootRemove; { процедура аккуратно удаляет все файлы(кроме папки /boot и ее содержимого) }
var g, j: TSearchRec;
begin
    if directoryexists('./root/data') then
    begin
        if findfirst('./root/data/programs/*', FaReadOnly, g) = 0 then
        begin
            repeat
                deletefile('./root/data/programs/' + g.name);
            until findnext(g) > 0;
        end;
        
        findclose(g);
            
        rmdir('./root/data/programs');
        rmdir('./root/data/user');
    end;
    
    if directoryexists('./root/system') then
    begin
        rmdir('./root/system/devices');
        rmdir('./root/system/firmware');
        
        if fileexists('./root/system/modules/video') then
            deletefile('./root/system/modules/video');
            
        if fileexists('./root/system/modules/audio') then
            deletefile('./root/system/modules/audio');
            
        rmdir('./root/system/modules');
    end;
    
    if directoryexists('./root/system') then
        rmdir('./root/system');
        
    if directoryexists('./root/data') then
        rmdir('./root/data');
        
    if findfirst('./root/config/*', FaReadOnly, j) = 0 then
        begin
            repeat
                deletefile('./root/config/' + j.name);
            until findnext(j) > 0;
        end;
        
    findclose(j);
    
    if directoryexists('./root/config') then
        rmdir('./root/config');
end;

procedure UserFilesRemove; { процедура удаления пользовательских файлов }
var s:tsearchrec; y:string;
begin
    if findfirst('./root/data/user/*', fareadonly, s) = 0 then
    begin
        repeat
            y := './root/data/user/' + s.name;
            deletefile(y);
        until findnext(s) > 0;
    end;
    
    findclose(s);
end;

procedure LoaderConfigure;
var g, h:tsearchrec; i:integer; defaultload, loaderpath, kernelexist:string; loaderfile: text;
begin
    filecreate('./root/boot/neoinit/loader.conf');

    repeat
        write('Enter the name of the kernel(with .bin), that you want to boot by default(if you don`t know the kernel`s name, just press enter): '); { пока что универсальные ядра я организовал только так }
        readln(defaultload);
        
        if defaultload = '' then
        begin
            if findfirst('./root/boot/*.bin', FaReadOnly, h) = 0 then
            begin
                defaultload := h.name;
            end
            else
            begin
                writeln('No kernels found');
                exit;
            end;
        end;
        
        findclose(h);
            
        kernelexist := './root/boot/' + defaultload;
        
        if fileexists(kernelexist)=false then { проверка существования файла ядра }
        begin
            writeln('This kernel doesn`t exist!');
            continue;
        end;
        
    until fileexists(kernelexist);
    
    loaderpath := './root/boot/neoinit/loader.conf';
    assign(loaderfile, loaderpath);
    rewrite(loaderfile); { конфиг загрузчика пересоздается, и туда записываются новые строки }
    
    i := 0;
    if findfirst('./root/boot/*.bin', fareadonly, g)=0 then { программа сканирует папку на наличие ядер, если она найдет хотя бы одно, то система уже запустится }
    begin
    repeat
        inc(i); { к счетчику прибавляется 1 единица }
        
        if i > 2 then 
            begin
                writeln('Warning: Maximum kernel count reached. Some kernels will be ignored.'); { если ядер больше чем то кол-во которое поддерживает загрузчик, то выводится это сообщение }
                sleep(500);
                break;
            end;
            
        if g.name=defaultload then { если имя ядра в папке = имя ядра которое ввел пользователь, то к этому ядру приписывается флаг [default-boot] }
            writeln(loaderfile, g.name + '[default-boot]')
        else
            writeln(loaderfile, g.name);
            
        writeln(loaderfile, './root/boot/' + g.name); { следующей строчкой после имени ядра записывается путь к ядру }
    until findnext(g) > 0;
    findclose(g);
    end;
    close(loaderfile);
end;

procedure FileSystemRecovery; { процедура восстановления ФС }
var agree:char;
begin
    write('It will delete ALL your data from filesystem. Are you want to continue?(y/n): ');
    readln(agree);
    if lowercase(agree) = 'y' then
    begin
        RootRemove;
        mkdir('./root/config');
        mkdir('./root/data');
            UserFilesRemove;
            mkdir('./root/data/user');
            mkdir('./root/data/programs');
        mkdir('./root/system');
            mkdir('./root/system/devices');
            mkdir('./root/system/modules');
            mkdir('./root/system/firmware');
    sleep(600);
    end
    else
        writeln('Cancelled');
end;

procedure RecoveryPowerOff;
begin
    Halt(0);
end;

procedure RecoveryReboot;
begin
    Halt(1);
end;

procedure HelpCommand;
begin
    writeln('Welcome to Recovery Kernel!');
    writeln('This Kernel doesn`t have static version, i`ll add more option from time to time');
    writeln('There are some options which can help you with troubles: ');
    writeln;
    writeln('neoinit-update - updates the config file of bootloader');
    writeln('recoverfilesystem - recovers file system if it has been corrupted(use this option carefully, cause it removes all user files from system, and all installed programs)');
    writeln('help - shows this note');
    writeln('poweroff - turns off your pc(just exiting this prog lol)');
    writeln('reboot - You really don`t know what this command do??');
end;

procedure AnimatedProgressBar(TotalSteps: Integer); { специальный прогресс-бар для загрузки рекавери мода }
var
  i: Integer;
begin
  Write('[');
  for i := 1 to 10 do Write('.');
  Write('] 0%');

  for i := 1 to TotalSteps do
  begin
    sleep(500);
    GotoXY(1 + (i * 10 div TotalSteps), WhereY);
    Write('#');
    GotoXY(15, WhereY);
    Write(i * 100 div TotalSteps, '%');
  end;
  Writeln;
end;

procedure RecoveryMode; { основная процедура, ядро рекавери мода }
var command:string;
begin
    clrscr;
    writeln('Loading Recovery Mode...');
    AnimatedProgressBar(10);
    
    while true do
    begin
        write('recoverymode$: ');
        readln(command);
            case command of
                'help':HelpCommand;
                'recoverfilesystem':FileSystemRecovery;
                'neoinit-update':LoaderConfigure;
                'poweroff':RecoveryPowerOff;
                'reboot':RecoveryReboot;
            else writeln('Unknown Command');
            end;
    end;
end;

begin
    RecoveryMode;
end.
