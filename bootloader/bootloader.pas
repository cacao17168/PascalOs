unit bootloader;

interface
        procedure LoaderConfigure;
        procedure InitKernel;
        procedure KernelLoad;
        
        type TKernel = record { специальный тип для массива с ядрами, в массив записываются имя ядра, путь, и является ли оно стандартным для загрузки }
                name:string;
                path:string;
                isdefault:boolean;
             end;
        
        const MAX_KERNELS = 2;
        
        var Kernels: array[1..MAX_KERNELS] of TKernel;
        
implementation

uses crt, sysutils, process;

var		loaderfile:text;
		loaderpath:string;
		n:integer;
		kernelexist, DefaultKernelsPath, KernelsPath:string;
		
		
function DefaultKernel: string;
var o: integer;
begin
    for o := low(Kernels) to high(Kernels) do
    begin
        if pos('[default-boot]', Kernels[o].name) > 0 then
            DefaultKernel := Kernels[o].name;
    end;
end;		
		
procedure LoaderConfigure;
var g, h:tsearchrec; i:integer; defaultload:string;
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
                findclose(h);
            end
            else
            begin
                writeln('No kernels found');
                halt(1);
            end;
        end;
            
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
        
        if i > MAX_KERNELS then 
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
    until findnext(g) <> 0;
    findclose(g);
    end;
    close(loaderfile);
end;

procedure InitKernel; { инициализация ядер }
begin
    loaderpath := './root/boot/neoinit/loader.conf';
    
    if not fileexists(loaderpath) then { проверка наличия конфига }
        begin
            writeln('Loader`s cfg file is corrupted');
            halt(1);
        end;
        
    assign(loaderfile, loaderpath); { конфиг открывается для чтения }
    reset(loaderfile);
    
    n := 0;
    
    while not eof(loaderfile) do
    begin
        inc(n);
        readln(loaderfile, Kernels[n].name); { читается конфиг, значения из конфига записываются в массив ядер }
        readln(loaderfile, Kernels[n].path);
    end;
    close(loaderfile);
end;

procedure FirstSetup; { процедура первого запуска, она всего лишь проверяет наличие хоть одного ядра, если ядра есть, то она передает управление генератору конфигов загрузчика }
var krnl:tsearchrec;
begin
    clrscr;
	loaderpath := './root/boot/neoinit/loader.conf';
  writeln('This is NeoInit loader first-setup helper!'#10'I will help you to configure loader!');
  writeln('Detecting kernel...');
  
  if findfirst('./root/boot/*.bin', fareadonly, krnl)=0 then { сканирование на наличие ядер }
  begin
        writeln('Kernel found successfully!');
	    writeln('Generating config in directory /boot/neoinit...');
	    LoaderConfigure; { здесь происходит передача управления }
        findclose(krnl);
  end
  else writeln('Kernel not found');
end;

procedure ShowMenu; { процедура вывода меню загрузчика }
var a:integer;
begin
    writeln('====NeoInit====');
    
    for a := low(Kernels) to high(kernels) do
        writeln('-->', Kernels[a].name, ' - ', a, '. Path to kernel: ', Kernels[a].path);
end;

procedure KernelLoad; { сама процедура загрузки интерфейса загрузчика }
var w, t, status:integer;
begin
  status := 1;
  
  loaderpath := './root/boot/neoinit/loader.conf';
  
    if fileexists(loaderpath)=false then { проверка существования конфига }
            FirstSetup;
            
  InitKernel;
  
  while (status <> 0) do
  begin
  
  repeat
    
    clrscr;
    
    ShowMenu;
    
    write('Choose the kernel(or wait 10 seconds): ');
    
    for t := 1 to 10 do
    begin
        
        if KeyPressed then
        begin
            readln(w); { с помощью 1 и 2 осуществляется выбор ядер }
    
            if (w > 2) or (w < 1) then
                begin
                    writeln('Unknown parameter, Please try again');
                    sleep(500);
                    continue;
                end;
     
            case w of
            1: Status := ExecuteProcess(Kernels[1].path, []);
            2: Status := ExecuteProcess(Kernels[2].path, []);
            end;
            break;
        end
        else sleep(1000);
    
    end;
    
    KernelsPath := copy(DefaultKernel, 1, pos('[default-boot]', Defaultkernel) - 1);
    
    DefaultKernelsPath := './root/boot/' + KernelsPath;
    
    if t = 10 then
        Executeprocess(DefaultKernelsPath, []);
    
    until (w = 1) or (w = 2);
  end;
end;

end.
