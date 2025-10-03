program PascalOS;

uses bootloader;

begin
    KernelLoad; { при запуске программа сразу передает управление загрузчику а тот в свою очередь загружает ядро }
end.
