all: release compileInstaller compileKernels clean

release: installer/installer.pas
	cp installer/installer.pas .
	
compileInstaller: installer.pas
	fpc -oInstaller.bin installer.pas
	
compileKernels: kernels/main/os.pas kernels/recovery/recovery.pas
	fpc ./kernels/main/os.pas -oPascalOs.bin
	fpc ./kernels/recovery/recovery.pas -oRecovery.bin
	
clean:
	rm ./kernels/main/*.o ./kernels/main/*.ppu ./kernels/recovery/*.o *.pas *.o
