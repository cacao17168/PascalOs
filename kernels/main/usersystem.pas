unit usersystem;

interface

type TUser = record
     usname: string;
     passwd: string;
     adminrights: boolean;
     end;
     
const 
    MAX_USERS = 4;
    
var
    users: array of TUser;
    
procedure UsersInit;
procedure createUser(UsAndPass: string);
procedure DeleteUser(usrname: string);
function SimpleHash(var input: string): string;

implementation

uses
    sysutils, crt;
    
var usersconfig: text;

function SimpleHash(var input: string): string;
var
  i, hash: integer;
begin
  hash := 0;
  for i := 1 to length(input) do
    hash := hash + ord(input[i]) * i;
  SimpleHash := IntToStr(hash);
end;

procedure FirstSetup;
var logname, passwd: string; success: boolean = false;
begin
repeat
    write('Enter your logname(make sure that logname change is not supported yet): ');
    readln(logname);
    
    write('Enter your password: ');
    readln(passwd);
    
    if (logname = '') or (passwd = '') then
    begin
        writeln('Invalid input. Please, try again!');
        sleep(150);
        continue;
    end;
    
    createuser(logname + ' ' + passwd);
until success;    
end;

procedure UsersInit;
var str: string; colonpos, colonpos2, i: integer;
begin
    i := 0;
    colonpos := 0;
    colonpos2 := 0;
    
    if fileexists('./root/config/users') = false then
    begin
        filecreate('./root/config/users');
        FirstSetup;
    end;
        
    assign(usersconfig, './root/config/users');
    reset(usersconfig);
    
    while (not eof(usersconfig)) or (i <= MAX_USERS) do
    begin
    
    setlength(users, length(users) + 1);
    
    readln(usersconfig, str);
    
    colonpos := pos(':', str);
    
    colonpos2 := pos(':', copy(str, colonpos + 1, length(str)));
    
    users[i].usname := copy(str, 0, colonpos - 1);

    users[i].passwd := copy(str, colonpos + 1, colonpos2 - 1);

    if copy(str, colonpos + colonpos2 + 1, length(str)) = 'true' then
        users[i].adminrights := true
    else users[i].adminrights := false;
    
    inc(i);
    
    end;
    
    close(usersconfig);
end;

procedure createUser(UsAndpass:string);
var q, n, p: string; hashedp: string; spacepos: integer;
begin
    spacepos := pos(' ', UsAndPass);
    
    if spacepos = 0 then
    begin
        writeln('password required');
        exit;
    end;

    n := copy(UsAndPass, low(UsAndPass), spacepos - 1);
    
    p := copy(UsAndPass, spacepos + 1, length(UsAndPass));

    hashedp := Simplehash(p);
    
    assign(usersconfig, './root/config/users');
    append(usersconfig);
    
    q := n + ':' + hashedp + ':' + 'true';
    
    writeln(usersconfig, q);
    
    close(usersconfig);
end;

procedure DeleteUser(usrname: string);
var inputfile, outputfile: text; configpath: string = './root/config/users'; i, j: integer; CurrentLine: string;
begin
    i := 0;
    j := 0;
    
    if fileexists(configpath) = false then
        exit;
    
    for i := low(users) to high(users) do
    begin
        if users[i].usname = usrname then
        begin
            for j := i to high(users) do
                users[j] := users[j + 1];
        end;
    end;
    
    SetLength(users, length(users) - 1);
    
    assign(inputfile, configpath);
    assign(outputfile, configpath + '.tmp');
    reset(inputfile);
    rewrite(outputfile);
    
    while not eof(inputfile) do
    begin
        readln(inputfile, CurrentLine);
        
        if pos(usrname, CurrentLine) = 0 then
            writeln(outputfile, CurrentLine);
    end;
    
    close(inputfile);
    close(outputfile);
    
    erase(inputfile);
    Rename(outputfile, configpath);
end;

end.
