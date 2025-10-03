unit fs;

interface
	procedure FileSystemRecovery;
	procedure FileSystemChecking;
	procedure FileCreate(var a: string);
	procedure FileDelete(var b: string);
	procedure ReadFile(var c: string);
	procedure WriteToFile(var d: string);

implementation

uses crt, sysutils;

procedure FileSystemRecovery; { теперь ядро напрямую не может восстановить ФС }
begin
  writeln('-->File system was corrupted. Please, recover it from recovery mode.');
end;

procedure FileCreate(var a:string); { Создание файлов }
var input, filename: string; flname: text;
begin
    input := a;
    
    filename := './root/data/user/';
    filename += input;
    
    if fileexists(filename) = true then
    begin
        writeln('File already exists');
        exit;
    end
    else
    begin
        assign(flname, filename);
        rewrite(flname);
        close(flname);
    end;
end;

procedure FileDelete(var b:string); { Удаление файлов }
var input, deletefilename: string; filedel: text;
begin
  input := b;
    
    deletefilename := './root/data/user/';
    deletefilename += input;
    
  if FileExists(deletefilename) then
  begin
    assign(filedel, deletefilename);
    erase(filedel);
    writeln('Deleted successfully!');
  end
    else writeln('File doesn`t exist');
end;

procedure readFile(var c: string);
var input, filestr: string; fileforread: text;
begin
    input := c;
    
    input := './root/data/user/' + input;
    
    if fileexists(input) = false then
    begin
        writeln('File not found');
        exit;
    end
    else
    begin
        assign(fileforread, input);
        reset(fileforread);
        
        writeln('File content: ');
        
        while not eof(fileforread) do
        begin
            readln(fileforread, filestr);
            writeln(filestr);
        end;
        
        close(fileforread)
    end;
end;

procedure WriteToFile(var d: string);
var input, userstr, choice: string; targetfile: text; editing: boolean = true; editchoice: char;
begin
    input := './root/data/user/'+ d;
    
    if fileexists(input) = false then
    begin
        writeln('File not found');
        exit;
    end;
    
    assign(targetfile, input);
    
    write('How do you want to change file content?(rewrite/append): ');
    readln(choice);
    
    case choice of
    'rewrite': rewrite(targetfile);
    'append': append(targetfile);
    end;
    
    while editing do
    begin
        write('Enter your text: ');
        readln(userstr);
        
        writeln(targetfile, userstr);
        
        write('Would you like to add something to file?(y/n): ');
        readln(editchoice);
        
        editchoice := lowercase(editchoice);
        
        case editchoice of
        'y':continue;
        'n':editing := false;
        end;
        
    end;  
    close(targetfile);  
end;

procedure FileSystemChecking; { проверка целостности системных файлов и папок }
begin
  writeln('->Checking file system...');
  sleep(700);
  if (FileExists('./root/boot/neoinit/loader')) and (DirectoryExists('./root/data')) and (DirectoryExists('./root/system')) then 
    writeln('-->File system is intact')
      else
	begin
	  FileSystemRecovery;
	end;
end;
end.
