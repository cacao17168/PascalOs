unit rebootflag;

interface
        procedure SetFlag(input: string);
        function GetFlag: boolean;

implementation

uses sysutils;

procedure SetFlag(input: string);
var rebootfile: text;
begin
    filecreate('./root/boot/reboot.flag');
    
    assign(rebootfile, './root/boot/reboot.flag');
    rewrite(rebootfile);
    writeln(rebootfile, input);
    
    close(rebootfile);
end;

function GetFlag: boolean;
var rebootfile: text; isreboot: string;
begin
    if fileexists('./root/boot/reboot.flag') = false then
    begin
        GetFlag := true;
        exit;
    end;

    assign(rebootfile, './root/boot/reboot.flag');
    reset(rebootfile);
    readln(rebootfile, isreboot);
    
    case isreboot of
    'true':GetFlag := true;
    'false':Getflag := false;
    end;
end;

end.
