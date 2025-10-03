program OfficialKernel;

uses crt, sysutils, repository, fs, usersystem, rebootflag;

var  com, args: string;
     power, video, audio: boolean;
     //Глобальные переменные
     currentDir: string;

procedure OsLoader; { Процедура "загрузки" системы }
begin
  TextColor(white);

  clrscr;
  
  video := false;
  audio := false;
  
  writeln('>Loading Operating System...');
  sleep(200);
  
  writeln('->Loading drivers...');
  sleep(300);
  
  video := FileExists('./root/system/modules/video');
    
  audio := FileExists('./root/system/modules/audio');
    
  if video = true then writeln('-->Video driver has found')
    else if (video = false) and (audio = true) then
        writeln('-->No proprietary video driver has found. Kernel driver will load');
  sleep(300);
  
  if audio = true then writeln('-->Audio driver has found')
    else if (video = true) and (audio = false) then
        writeln('-->No proprietary audio driver has found. Kernel driver will load');
        
  if (video = false) and (audio = false) then
    writeln('-->No proprietary drivers found. Kernel drivers will load.');
  sleep(1000);
  
  writeln('->Starting services...');
  sleep(200);
  
  writeln('-->Starting user process...');
  sleep(1000);
  
  writeln('-->Preparing system environment...');
  sleep(500);
  
  FileSystemChecking;
end;

procedure Login; { Процедура авторизации }
var logname, passwd, hashedpasswd: string; i, j: integer; correct: boolean;
begin
  correct := false;
  
  j := 0;
  
  while (j < 3) and (not correct) do
  begin
  
  write('Login: ');
  readln(logname);
  
  write('Password: ');
  readln(passwd);
  
  hashedpasswd := simplehash(passwd);
  
  for i := low(users) to high(users) do
  begin
    if (users[i].usname <> '') and (logname = users[i].usname) and (hashedpasswd = users[i].passwd) then
    begin
        correct := true;
        break;
    end;
  end;
  
  if correct then
    break;
   
  inc(j);
  if j < 3 then
  begin
    writeln('Logname or password is incorrect. Please, try again');
    sleep(300);
  end
  else
  begin
    writeln('Max attempts count reached, turning off...');
    sleep(300);
    power := false;
    exit;
  end;
  
  end;
end;

procedure ConsoleWrite; { вывод приглашения командной строки }
begin
    write(currentDir, ' > ');
end;

procedure MainCommand; { Процедура самой главной команды }
begin
  writeln('Pascal Operating System 3.3');
  writeln(' ');
  writeln('ls - shows dir content');
  writeln('clear - clears screen');
  writeln('poweroff - turns off your PC');
  writeln('reboot - full reboot');
  writeln('ipm - installing program manager, type "ipm help" for more info');
  writeln('cfile <filename> - making file in dir "/data/user/"');
  writeln('rmfile <filename> - removes file from dir "/data/user/"');
  writeln('readfile <filename> - writing to screen the content of <filename>');
  writeln('writefile <filename> - helps you to write smth to <filename>');
end;

procedure C3; { Процедура команды "hello"(небольшая пасхалка от разработчика) }
begin
  writeln('Hello!');
end;

procedure C5; { Процедура команды "clear" }
begin
  clrscr;
end;

procedure OsPowerOff; { Процедура команды "poweroff" }
begin
    writeln('Shutting down...');
    SetFlag('false');
    sleep(400);
    power := false;
end;

procedure ReBoot;
begin
    SetFlag('true');
    power := false;
end;

procedure UnknownCommand; { Процедура неизвестной команды }
begin
  writeln('Unknown command. Type "help" for more info');
end;

procedure Ls(args: string); { универсальная версия команды "list" }
var dir: string; listcd: string; ls1: TSearchRec;
begin
    if args = '' then
        listcd := ''
    else
        listcd := args;
        
    if listcd = '' then
        dir := './root' + currentDir
    else if listcd[0] = '/' then
        dir := './root' + listcd
    else 
        dir := './root' + currentDir + '/' + listcd;
    
    if directoryexists(dir) then
    begin
        if findfirst(dir + '/*', faanyfile, ls1) = 0 then
        begin
            repeat
                if (ls1.name <> '.') and (ls1.name <> '..') then
                begin
                    textcolor(blue);
                    writeln(ls1.name);
                    textcolor(white);
                end;
            until findnext(ls1) <> 0;
            findclose(ls1);
        end;
    end
    else
    begin
        writeln('directory doesn`t exist');
        exit;
    end;
end;

procedure CD(args: string); { Процедура команды "change directory" }
begin
    if args = '' then
    begin
        currentDir := '';
        exit;
    end
    else if args[0] = '/' then 
            if directoryexists('./root' + args) then
                currentDir := args
         else if directoryexists('./root' + currentDir + args) then
                currentDir += args
        else
        begin
            writeln('directory doesn`t exist');
            exit;
        end;
end;

procedure ParseCommand(var com: string; var args: string);
var spacepos: integer;
begin
    spacepos := pos(' ', com);
    
    if spacepos > 0 then
    begin
        args := copy(com, spacepos + 1, length(com) - spacepos);
    
        com := copy(com, low(com), spacepos - 1);
    end
    else args := '';
end;

function DoesProgramInstalled(name: string): boolean;
begin
    DoesProgramInstalled := FileExists('./root/data/programs' + name);
end;

procedure caseofcommands(var com: string; var args: string);
begin
   case com of { ищет совпадения введенной команды среди заданных констант }
    'help':MainCommand;
    'ls':Ls(args);
    'hello':C3;
    'poweroff':OsPowerOff;
    'reboot':ReBoot;
    'clear':C5;
    
    { Команды cd }
    'cd':CD(args);

    
    { Команды запуска программ }
    'rpc':begin
            if doesprograminstalled('rpc') then
		        RockPaperScissors;
	        end;
	'calculator':begin
	         if doesprograminstalled('calculator') then
	            Calculator;
	         end;
    
    'cfile':FileCreate(args); { создание и удаление файлов }
    'rmfile':FileDelete(args);
    'readfile':ReadFile(args);
    'writefile':WriteToFile(args);
    
    'ipm':repoApi(args); { пакетный менеджер а также установка програм из репозитория }
    'useradd':Createuser(args);
    'userdel':DeleteUser(args);
    
    else UnknownCommand; { если совпадений нет }
   end;
end;

procedure OsStart;
begin { Основной код для работы системы }
  
   InitRepo; { инициализация репозитория }
  
   OsLoader;
        
   power := true;
   
   Usersinit;
  
   Login;
   
   while power = true do
   begin
   
    ConsoleWrite; { выводит приглашение командной строки }
    readln(com); { чтение команды }
    
    com := lowercase(com); { переводит команду в нижний регистр }
    
    ParseCommand(com, args);
    
    Caseofcommands(com, args);
   end;
end;

begin
    OsStart;
end.
