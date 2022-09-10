Program ABM;

uses crt, sysUtils;

const   
    PATH = '.\clientes.dat';
    PATHAUX = '.\clientesAux.dat';
Type 
    Cliente = Record
        PosicionRegistro: integer;
        Nombre: String[50];
        Apellido: String[50];
        Codigo: integer;
        ACTIVO: boolean;
    end;
    ArchivoCliente = File of Cliente;

var
    opcion, NRegistros: integer;
    A: ArchivoCliente;

//---------------------METODOS----------------------------------------

procedure continuar();
begin
    WriteLn('');
    WriteLn('Presione para continuar');
    readln();
end;

function ingresarDatos(): Cliente;
var 
    RC: Cliente;
begin
    Write('Nombre: ');
    Readln(RC.Nombre);
    Write('Apellido: ');
    ReadLn(RC.Apellido);
    Write('Codigo de cliente: ');
    ReadLn(RC.Codigo);
    while (RC.Codigo <= 0) or (RC.Codigo > 9999) do begin //validacion maximo 4 digitos
        WriteLn('-Ingrese un codigo valido-');
        Write('Codigo de cliente: ');
        ReadLn(RC.Codigo);
    end;
    ingresarDatos := RC;
end;

procedure mostrarArchivo();
var 
    RC: Cliente;
begin
    Reset(A);
    if (FileSize(A) = 0) then begin
      writeln('El archivo esta vacio');
      continuar(); 
    end
    else begin
        NRegistros := FileSize(A);
        writeln('-------------------------------------------------------');
        writeln('----------------Mostrando ' + NRegistros.ToString + ' registros----------------');
        writeln('-------------------------------------------------------');
        continuar();
        while not EOF(A) do begin
            read(A,RC);
            writeln('- - - - - - - - - - - - - - - - - - - - - - -');
            writeln('PosicionRegistro: ' + RC.PosicionRegistro.ToString);
            Writeln('Nombre: ' + RC.Nombre);
            WriteLn('Apellido: ' + RC.Apellido);
            Writeln('CodigoCliente: ' + RC.Codigo.ToString);
            if RC.ACTIVO then //temporal
                WriteLn('Activo?: SI') 
            else
                WriteLn('Activo?: NO');
            continuar();
        end;
        Close(A);
    end;
end;

function alta(C:Cliente): boolean;
var 
    exito: boolean;
begin
    exito := false;
    if not FileExists(PATH) then begin
        WriteLn('Creando archivo...');
        Sleep(1000);
        Rewrite(A);
        NRegistros := 0;
        Close(A);
    end;
    Reset(A);
    NRegistros := FileSize(A);
    NRegistros := NRegistros + 1;
    C.PosicionRegistro := NRegistros;
    C.ACTIVO := true;
    seek(A,FileSize(A));
    write(A,C);
    WriteLn('Cliente guardado en el registro ' + C.PosicionRegistro.ToString);
    exito := true;
    Close(A);
    alta := exito;
end;

function baja(): boolean;
var 
    exito: boolean;
    RC: Cliente;
    P: integer;
begin
    exito := false;
    Write('Ingrese la posicion a dar de baja: ');
    readln(P);
    Reset(A);
    if FileExists(PATH) then begin
        if (P > 0) and (P <= FileSize(A)) then begin
            seek(A,P-1);
            Read(A,RC);
            WriteLn('');
            WriteLn('Se dara de baja el siguiente registro: ');
            Writeln('Nombre: ' + RC.Nombre);
            WriteLn('Apellido: ' + RC.Apellido);
            Writeln('CodigoCliente: ' + RC.Codigo.ToString);
            continuar();
            RC.ACTIVO := false;
            seek(A,P-1);
            Write(A,RC);
            exito := true;
        end else
            WriteLn('-Posicion fuera de rango-');
    end else
        WriteLn('El archivo no existe. Agrega un cliente para crearlo');
    close(A);
    baja := exito;
end;

function modificacion(): boolean;
var 
    exito: boolean;
    P: integer;
    RC: Cliente;
begin
    Write('Ingrese la posicion a modificar: ');
    readln(P);
    Reset(A);   
    if FileExists(PATH) then begin
        if (P > 0) and (P <= FileSize(A)) then begin
            seek(A,P-1);
            Read(A,RC);
            WriteLn('Se dara de baja el siguiente registro: ');
            Writeln('Nombre: ' + RC.Nombre);
            WriteLn('Apellido: ' + RC.Apellido);
            Writeln('CodigoCliente: ' + RC.Codigo.ToString);
            WriteLn('');
            RC := ingresarDatos();
            seek(A,P-1);
            Write(A,RC);
            exito := true;
        end else
            WriteLn('-Posicion fuera de rango-');
    end else
        WriteLn('El archivo no existe. Agrega un cliente para crearlo');
    close(A);
    modificacion := exito;
end;

procedure limpieza(); // agrega todas las altas a un nuevo archivo con el mismo nombre
var 
    ArchivoAux: ArchivoCliente;
    RC: Cliente;
begin
    Assign(ArchivoAux,PATHAUX);
    Rewrite(ArchivoAux);
    Reset(A);
    Reset(ArchivoAux);;
    while not EOF(A) do begin
        Read(A,RC);
        if RC.ACTIVO then begin
            seek(ArchivoAux,FileSize(ArchivoAux));
            RC.PosicionRegistro := FileSize(ArchivoAux) + 1;
            Write(ArchivoAux,RC);
        end;
    end;
    Close(A);
    Close(ArchivoAux);
    DeleteFile(PATH);
    Rename(ArchivoAux,PATH);
end;

//-------------------------------PROGRAMA PRINCIPAL-------------------------------------
Begin
    Assign(A,PATH);
    Opcion := -1;
    while (Opcion <> 0) do begin
        clrscr;
        WriteLn('-------------------------ABM---------------------------');
        WriteLn('');
        WriteLn('1. Dar de alta un cliente'); 
        WriteLn('2. Dar de baja un cliente');
        WriteLn('3. Modificar un cliente');
        WriteLn('4. Mostrar archivo');
        WriteLn('5. Limpieza');
        WriteLn('0. Salir');
        WriteLn('');
        Write('Ingrese una opcion: ');
        Readln(Opcion);
        WriteLn('');

        case Opcion of
            1: begin
                if alta(ingresarDatos()) then 
                    writeln('Cliente dado de alta con exito')
                else
                    WriteLn('-Error en Alta-');
                continuar();
            end;
            2: begin
                if baja() then
                    writeln('Cliente dado de baja con exito')
                else
                    WriteLn('-Error en Baja-');
                continuar();  
            end;
            3: begin
                if modificacion() then
                    writeln('Cliente modificado con exito')
                else
                    WriteLn('-Error en Modificacion-');
                continuar();     
            end;
            4: begin
                if (not FileExists(PATH)) then begin 
                    writeln('-El archivo no existe-');
                    continuar();
                end else
                    mostrarArchivo(); 
            end;
            5: begin
                WriteLn('Limpieza borrara todos los registros dados de baja');
                continuar();
                limpieza(); 
                clrscr;
                Writeln('Limpieza exitosa!');
                continuar()
            end;
            0: begin
                writeln('Saliendo...');
            end;  
        end;
    end;

End.