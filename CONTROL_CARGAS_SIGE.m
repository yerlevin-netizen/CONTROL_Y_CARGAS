%JESUS YERLEVIN RODRIGUEZ CELIS
%CODIGO 203036_18
%INGENIERIA EN TELECOMUNICACIONES
%RETO 3 ALGORITMO DE CONTROL Y CARGAS (SIGE)

%INICIACION ENTORNO DE TRABAJO
clc;
clear;
close all;

%IMPORTACION DE DATOS DEL RETO 2
run('SIGE.m');
%VECTORES DE GENERACION SOLAR, EOLICA Y DEMANDA DE LA COMUNIDAD
horas=1:24;
produccion_solar;
produccion_eolica;
P_demanda;

%DEFINIR VARIABLE PARA ESTADO DE CARGA DE LA BATERIA 
SOC_MAX=100;  %EVITAR SOBRECARGAS
SOC_MIN=0;  % EVITAR VACIAMIENTO PROFUNDO
SOC_CAPACIDAD=100; % CAPACIDAD EN kWh PARA CALCULO PORCENTUAL 

%ESTADO DE CARGA INICIAL
SOC_ACTUAL=50; 

%VECTORES PARA ALMACENAR RESULTADOS DE CONTROL
SOC_historial = zeros(size(horas));
estado_alumbrado= cell(1,24);
estado_bombeo= cell(1,24);
estado_escuela= cell(1,24);

%BUCLE DE SIMULACION PARA LAS 24 HORAS 
fprintf('===========================================================\n');
fprintf('       INICIO DE SIMULACION Y CONTROL SIGE 24 HORAS        \n');
fprintf('===========================================================\n');
for h = 1:24 
    E_gen= produccion_solar(h)+ produccion_eolica(h);
    E_dem= P_demanda(h);

    % CALCULO DEL BALANCE ENERGETICO (Positivo = Superávit, Negativo = Déficit)
    balance= E_gen - E_dem;
    
   %ESCENARIO SUPERAVIT (E_GEN > E_DEM)
   if E_gen>=E_dem
       excedente = E_gen - E_dem;
       SOC_ACTUAL = SOC_ACTUAL +(excedente/SOC_MAX) * 100;
       %PROTECCION DEL LIMITE DE CARGA SUPERIOR
       if SOC_ACTUAL> SOC_MAX
           SOC_ACTUAL=SOC_MAX;
       end

    %ESCENARIO DEFICIT ( E_GEN < E_DEM)
   else
       deficit = E_dem - E_gen;
       SOC_ACTUAL = SOC_ACTUAL - (deficit / SOC_MAX) * 100;
       %PROTECCION LIMITE INFERIOR
       if SOC_ACTUAL < SOC_MIN
           SOC_ACTUAL = SOC_MIN;
       end
   end
       
    %PROTOCOLO DESCONEXION DE CARGAS (EMERGENCIA,ALERTA Y SEGURA)
   if SOC_ACTUAL <= 20 %EMERGENCIA
           alumbrado = 'OFF';
           bombeo = 'OFF';
           escuela='ON';

   elseif SOC_ACTUAL <=40 %ALERTA
           alumbrado = 'OFF';
           bombeo='ON';
           escuela='ON';

   else  %RUTA SEGURA
           alumbrado= 'ON';
           bombeo='ON';
           escuela='ON';
   end
   

   %GUARDAR EL HISTORIAL DE LA HORA
   SOC_historial(h) = SOC_ACTUAL;
   estado_alumbrado{h} = alumbrado;
   estado_bombeo{h} = bombeo;
   estado_escuela{h} = escuela;
   %REPORTE DE CONSOLA HORA POR HORA
   fprintf('Hora %02d | Gen: %6.2f kW | Dem: %6.2f kW |Bal: %+6.2f kW| SOC: %6.2f%% | Alumbrado: %-3s | Bombeo: %-3s | Escuela: %-3s\n', ...
       h, E_gen, E_dem,balance, SOC_ACTUAL, alumbrado, bombeo,escuela);
end
fprintf('===========================================================\n');
fprintf('         FIN DE SIMULACION Y CONTROL SIGE                  \n');
fprintf('===========================================================\n');