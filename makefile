all: release compile clean

release: installer/installer.pas
	cp installer/installer.pas .
	
compile: installer.pas
	fpc -oInstaller.bin installer.pas
	
clean:
	rm *.pas *.o
