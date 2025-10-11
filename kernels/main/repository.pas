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

function Install(appname: string): integer; { установка программ }
var i: integer; f: file of byte;
begin
    i := 0;
    
    for i := 1 to AppCount do
    begin
        if Apps[i].name = appname then
        begin
            if Apps[i].installed = false then
            begin
                assign(f, Apps[i].execpath);
                rewrite(f);
                close(f);
                Apps[i].installed := true;
                Install := 0;
                break;
            end
            else
            begin
                install := 1;
                break;
            end;
        end
        else
        Install := 2;
    end;
end;

procedure IpmHelp(arg: string); { выводит функции программного менеджера ipm }
begin
    writeln('Spm is a simple program manager for OS. Using: ipm [option] [program name]');
    writeln('Options:'#10'-i - install program'#10'-r - remove program');
end;


function Uninstall(appname: string): integer; { удаление программ }
var i: integer; f: file of byte;
begin
    i := 0;
    
    for i := 1 to AppCount do
    begin
        if Apps[i].name = appname then
        begin
            if Apps[i].installed = true then
            begin
                assign(f, Apps[i].execpath);
                erase(f);
                Apps[i].installed := false;
                Uninstall := 0;
                break;
            end
            else
            begin
                Uninstall := 1;
                break;
            end;
        end
        else
        Uninstall := 2;
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

function VideoInstall: integer; { Установка видеодрайвера }
var vdriver: text;
begin
  if FileExists('./root/system/modules/video') then
      VideoInstall := 1
    else
  begin
     assign(vdriver, './root/system/modules/video');
     rewrite(vdriver);
     sleep(500);
     VideoInstall := 0;
  end;
end;

function AudioInstall: integer; { Установка аудиодрайвера }
var adriver: text;
begin
  if FileExists('./root/system/modules/audio') then
      AudioInstall := 1
    else
  begin
     assign(adriver, './root/system/modules/audio');
     rewrite(adriver);
     sleep(500);
     AudioInstall := 0;
  end;
end;

procedure repoApi(args: string);
var status: integer;
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
        'video-driver':status := VideoInstall;
        'audio-driver':status := AudioInstall;
        end;
        
        case status of
        0:writeln('Installed Successfully!');
        1:writeln('Driver has already installed!');
        end;
        
        exit;
    end;
    
    case flag of
    '-i':status := Install(progname);
    '-r':status := Uninstall(progname);
    else
        writeln('Unknown flag. Enter "ipm help" for more info');
    end;
    
    case status of
    0:writeln('Program has installed/deleted successfully!');
    1:writeln('Program has already installed or hasn`t installed yet!');
    2:writeln('Program was not found!');
    end;
end;

procedure ShowChoices;
begin
  writeln('Choose:');
  writeln('1 - Rock');
  writeln('2 - Scissors');
  writeln('3 - Paper');
end;

procedure DetermineWinner(player, computer: integer);
begin
  { Выводим ход пользователя и компьютера }
  writeln('Your choice: ', playerChoice);
  writeln('Computer`s choice: ', computerChoice);

  { Если выбор равен, то ничья }
  if player = computer then
    writeln('Draw!')
  { Определяем победителя и выводим сообщение в консоль }
  else if ((player = 1) and (computer = 2)) or
          ((player = 2) and (computer = 3)) or
          ((player = 3) and (computer = 1)) then begin
    writeln('You win!');
    writeln(#7);
    end
  else
    writeln('Computer wins!');
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
    write('Your turn(1-3): ');
    readln(playerChoice);

    { Проверяем, чтобы ввод пользователя соответствовал условию }
    if (playerChoice < 1) or (playerChoice > 3) then
    begin
      writeln('Invalid choice. Please, try again.');
      sleep(2000);
      continue;  { Возвращаемся в начало цикла }
    end;

    { Генерируем случайный ход компьютера: 1 — камень, 2 — ножницы, 3 — бумага}
    computerChoice := random(3) + 1;
    
    { Определяем победителя}
    DetermineWinner(playerChoice, computerChoice);

    { Спрашиваем, хочет ли пользователь сыграть ещё раз}
    writeln;
    write('Do you want to play again? (y/n): ');
    readln(playAgain);

  { Цикл игры повторяется до тех пор, пока пользователь не введёт n или N }    
  until (playAgain = 'n') or (playAgain = 'N');

  { Благодарим пользователя и завершаем игру }
  writeln('Thanks for playing!');
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
