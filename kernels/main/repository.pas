unit repository;

interface
	 procedure InitRepo;
	 procedure RockPaperScissors;
	 procedure Calculator;
	 procedure repoApi(args: string);

implementation

uses crt, sysutils;

type TAppInfo = record { тип для массива программ }
	    name: string;
	    installed: boolean;
	    execpath: string;
	    version: string;
     end;

var Apps: array[1..10] of TAppInfo; { специальный массив с программами }
    AppCount: integer;
    playerChoice: integer;
    computerChoice: integer;
    playAgain: char;
    flag, progname: string;

procedure Loading; { прогресс бар для установки приложений }
var i: integer;
begin
  i := 0;
  
  write('Completed: [');
  for i := 1 to 20 do
  begin
    write('#');
    sleep(100);
  end;
  writeln('] Done!');
end;

procedure InitRepo; { инициализация репозитория }
var i: integer;
begin
  i := 0;
  AppCount := 2;

  Apps[1].name := 'rpc';
  Apps[1].execpath := './root/data/programs/rpc';
  Apps[1].version := '1.0';
  
  Apps[2].name := 'calculator';
  Apps[2].execpath := './root/data/programs/calculator';
  Apps[2].version := '1.0';

  for i := 1 to AppCount do
    Apps[i].installed := fileexists(Apps[i].execpath);
end;

procedure Install(appname: string); { установка программ }
var i: integer; f: file of string;
begin
    i := 0;
    
    for i := 1 to AppCount do
    begin
        if Apps[i].name = appname then
        begin
            if Apps[i].installed = false then
            begin
                write('Searching ', Apps[i].name, '...');
                sleep(150);
                writeln('Done!');
                writeln('Installing...');
                assign(f, Apps[i].execpath);
                rewrite(f);
                close(f);
                Loading;
                Apps[i].installed := true;
                break;
            end
            else
            begin
                writeln('You have already installed this program');
                break;
            end;
        end;
    end;
end;

procedure IpmHelp(arg: string); { выводит функции программного менеджера ipm }
begin
    writeln('Ipm is a simple program manager for OS. Using: ipm [option] [program name]');
    writeln('Options:'#10'-i - install program'#10'-r - remove program');
end;


procedure Uninstall(appname: string); { удаление программ }
var i: integer; f: file of string;
begin
    i := 0;
    
    for i := 1 to AppCount do
    begin
        if Apps[i].name = appname then
        begin
            if Apps[i].installed = true then
            begin
                writeln(Apps[i].name, ' will be removed from your PC');
                assign(f, Apps[i].execpath);
                erase(f);
                Loading;
                Apps[i].installed := false;
                break;
            end
            else
            begin
                writeln('Program is not installed');
                break;
            end;
        end;
    end;
end;

Procedure ParseFlag(prog: string);
var spacepos: integer;
begin
    spacepos := pos(' ', prog);
    
    if spacepos = 0 then
        exit;
        
    flag := copy(prog, 0, spacepos - 1);
    
    progname := copy(prog, spacepos + 1, length(prog));
end;

procedure VideoInstall; { Установка видеодрайвера }
var vdriver: text;
begin
  if FileExists('./root/system/modules/video') then
      writeln('Driver has already installed')
    else
  begin
     writeln('Installing video driver...');
     assign(vdriver, './root/system/modules/video');
     rewrite(vdriver);
     sleep(200);
     writeln('Configuring driver...');
     sleep(500);
     writeln('Installed successfully!');
  end;
end;

procedure AudioInstall; { Установка аудиодрайвера }
var adriver: text;
begin
  if FileExists('./root/system/modules/audio') then
      writeln('Driver has already installed')
    else
  begin
     writeln('Installing audio driver...');
     assign(adriver, './root/system/modules/audio');
     rewrite(adriver);
     sleep(200);
     writeln('Configuring driver...');
     sleep(500);
     writeln('Installed successfully!');
  end;
end;

procedure repoApi(args: string);
begin
    ParseFlag(args);
    
    if args = 'help' then
    begin
        IpmHelp(args);
        exit;
    end;
    
    if (progname = 'video-driver') or (progname = 'audio-driver') then
    begin
        case progname of
        'video-driver':VideoInstall;
        'audio-driver':AudioInstall;
        end;
        
        exit;
    end;
    
    case flag of
    '-i':Install(progname);
    '-r':Uninstall(progname);
    else
        writeln('Unknown flag. Enter "ipm help" for more info');
    end;
end;

procedure ShowChoices;
begin
  writeln('Выберите:');
  writeln('1 - Камень');
  writeln('2 - Ножницы');
  writeln('3 - Бумага');
end;

procedure DetermineWinner(player, computer: integer);
begin
  { Выводим ход пользователя и компьютера }
  writeln('Вы выбрали: ', playerChoice);
  writeln('Компьютер выбрал: ', computerChoice);

  { Если выбор равен, то ничья }
  if player = computer then
    writeln('Ничья!')
  { Определяем победителя и выводим сообщение в консоль }
  else if ((player = 1) and (computer = 2)) or
          ((player = 2) and (computer = 3)) or
          ((player = 3) and (computer = 1)) then begin
    writeln('Вы победили!');
    writeln(#7);
    end
  else
    writeln('Компьютер победил!');
end;

{ Основной код игры }
procedure RockPaperScissors;
begin
  { Инициализируем генератор случайных чисел }
  randomize;

  repeat
    { Очищаем экран для нового раунда }
    clrscr;

    { Выводим меню }
    ShowChoices;
    
    { Получаем ход пользователя }
    write('Ваш ход (1-3): ');
    readln(playerChoice);

    { Проверяем, чтобы ввод пользователя соответствовал условию }
    if (playerChoice < 1) or (playerChoice > 3) then
    begin
      writeln('Неверный выбор. Попробуйте снова.');
      sleep(2000);
      continue;  { Возвращаемся в начало цикла }
    end;

    { Генерируем случайный ход компьютера: 1 — камень, 2 — ножницы, 3 — бумага}
    computerChoice := random(3) + 1;
    
    { Определяем победителя}
    DetermineWinner(playerChoice, computerChoice);

    { Спрашиваем, хочет ли пользователь сыграть ещё раз}
    writeln;
    write('Хотите сыграть ещё раз? (y/n): ');
    readln(playAgain);

  { Цикл игры повторяется до тех пор, пока пользователь не введёт n или N }    
  until (playAgain = 'n') or (playAgain = 'N');

  { Благодарим пользователя и завершаем игру }
  writeln('Спасибо за игру!');
end;

procedure ShowMenu; { выводит меню калькулятора }
begin
    writeln('--------------------');
    writeln('Simple calculator');
    writeln('--------------------');
    writeln('Available operations:');
    writeln('+ - addition');
    writeln('- - subtracktion');
    writeln('* - multiplication');
    writeln('/ - division');
    writeln('q - quit');
end;

function calculate(a, b: extended; op: char): extended; { главная функция для программы "Калькулятор" }
begin
    case op of
        '+':calculate := a + b;
        '-':calculate := a - b;
        '*':calculate := a * b;
        '/':if b <> 0 then
                calculate := a / b
                else
                    begin
                        writeln('Illegal expression!');
                        calculate := 0;
                    end
            else
            begin
                writeln('Unknown operation');
                calculate := 0;
            end;
    end;
end;

function readnumber(var num: extended): boolean; { проверка введенных символов на цифры, елсли это цифры, функция возвращает true, иначе false }
var inputstr:string; errorcode:integer;
begin
    readln(inputstr);
    val(inputstr, num, errorcode);
    readnumber := errorcode = 0;
    if not readnumber then
        writeln('Error! Enter the correct number: ');
end;

procedure Calculator; { программа "Калькулятор" }
var num1, num2, result: extended; calcwork: boolean = true; operation: char;
begin
    while calcwork do
    begin
        clrscr;
        ShowMenu;
        
        repeat
            Write('Enter the first number: ');
        until readnumber(num1);
        

            
        write('Enter the operation(+, -, *, /, q): ');
        readln(operation);
        
        if (operation = 'q') or (operation = 'Q') then
        begin
            calcwork := false;
            exit;
        end;
        
        repeat
            Write('Enter the second number: ');
        until readnumber(num2);
            
        result := calculate(num1, num2, operation);
        
        writeln('Result: ', num1:0:2, ' ', operation, ' ', num2:0:2, ' = ', result:0:2);
        
        writeln('Press enter to continue...');
        readln;
        end;
        
    writeln('Goodbye!');
end;

end.
