%% ============================================================
% EJERCICIO 1
% ANALISIS DE RESPUESTA EN FRECUENCIA
% GM, PM Y ESTABILIDAD EN LAZO CERRADO
% =============================================================

clear;
clc;
close all;

%% ============================================================
% 1. DATOS DEL SISTEMA
% =============================================================

K = 1e8;

fz  = 100e3;      % Frecuencia del cero [Hz]
fp1 = 90e3;       % Frecuencia del polo 1 [Hz]
fp2 = 140e3;      % Frecuencia del polo 2 [Hz]

% Conversion de Hz a rad/s
wz  = 2*pi*fz;
wp1 = 2*pi*fp1;
wp2 = 2*pi*fp2;

fprintf('\n');
fprintf('====================================================\n');
fprintf('               EJERCICIO 1\n');
fprintf('====================================================\n');

fprintf('\nFRECUENCIAS ANGULARES\n');
fprintf('wz  = %.6f rad/s\n',wz);
fprintf('wp1 = %.6f rad/s\n',wp1);
fprintf('wp2 = %.6f rad/s\n',wp2);

%% ============================================================
% 2. FUNCION DE TRANSFERENCIA
% =============================================================

s = tf('s');

G = K*(s+wz) / ...
    (s*(s+wp1)*(s+wp2));

fprintf('\nFUNCION DE TRANSFERENCIA G1(s):\n');
disp(G);

%% ============================================================
% 3. TABULAR 20 VALORES ENTRE 80 kHz Y 150 kHz
% =============================================================

% Generar exactamente 20 frecuencias
f = linspace(80e3,150e3,20);

% Frecuencia angular
w = 2*pi*f;

%% ============================================================
% 4. RESPUESTA EN FRECUENCIA
% =============================================================

respuesta = squeeze(freqresp(G,w));

% Convertir todos los vectores en columnas
respuesta = respuesta(:);
f_kHz = f(:)/1000;
omega_rad_s = w(:);

% Magnitud lineal
Mag = abs(respuesta);

% Magnitud en decibeles
Mag_dB = 20*log10(Mag);

% Fase en grados
Fase = unwrap(angle(respuesta))*180/pi;

%% ============================================================
% 5. TABLA DE LOS 20 VALORES
% =============================================================

Tabla = table( ...
    f_kHz, ...
    omega_rad_s, ...
    Mag_dB, ...
    Fase, ...
    'VariableNames', ...
    {'f_kHz','omega_rad_s','Magnitud_dB','Fase_grados'});

fprintf('\n');
fprintf('====================================================\n');
fprintf('TABLA DE 20 VALORES ENTRE 80 kHz Y 150 kHz\n');
fprintf('====================================================\n');

disp(Tabla);

%% ============================================================
% 6. FORMULAS ANALITICAS DE MAGNITUD Y FASE
% =============================================================

fprintf('\n');
fprintf('====================================================\n');
fprintf('FORMULAS UTILIZADAS\n');
fprintf('====================================================\n');

fprintf('\nMagnitud:\n');
fprintf('|G(jw)| = K*sqrt(w^2+wz^2) /\n');
fprintf('[w*sqrt(w^2+wp1^2)*sqrt(w^2+wp2^2)]\n');

fprintf('\nMagnitud en dB:\n');
fprintf('|G(jw)|dB = 20*log10(|G(jw)|)\n');

fprintf('\nFase:\n');
fprintf('Fase = atan(w/wz) - 90 - atan(w/wp1) - atan(w/wp2)\n');

%% ============================================================
% 7. COMPROBACION MANUAL DE MAGNITUD Y FASE
% =============================================================

Mag_manual = ...
    K.*sqrt(w.^2 + wz^2) ./ ...
    (w .* sqrt(w.^2 + wp1^2) .* sqrt(w.^2 + wp2^2));

Mag_manual_dB = 20*log10(Mag_manual);

Fase_manual = ...
    atan(w./wz)*180/pi ...
    - 90 ...
    - atan(w./wp1)*180/pi ...
    - atan(w./wp2)*180/pi;

Mag_manual_dB = Mag_manual_dB(:);
Fase_manual = Fase_manual(:);

Tabla_manual = table( ...
    f_kHz, ...
    Mag_manual_dB, ...
    Fase_manual, ...
    'VariableNames', ...
    {'f_kHz','Magnitud_Analitica_dB','Fase_Analitica_grados'});

fprintf('\nTABLA CALCULADA CON LAS FORMULAS ANALITICAS:\n');
disp(Tabla_manual);

%% ============================================================
% 8. MARGEN DE GANANCIA Y MARGEN DE FASE
% =============================================================

[Gm,Pm,Wcg,Wcp] = margin(G);

fprintf('\n');
fprintf('====================================================\n');
fprintf('MARGENES DE ESTABILIDAD\n');
fprintf('====================================================\n');

% ------------------------------------------------------------
% Margen de ganancia
% ------------------------------------------------------------

if isinf(Gm)

    fprintf('\nMargen de ganancia lineal GM = infinito\n');
    fprintf('Margen de ganancia GM = infinito dB\n');

else

    GM_dB = 20*log10(Gm);

    fprintf('\nGM lineal = %.6f\n',Gm);
    fprintf('GM = %.6f dB\n',GM_dB);

end

% ------------------------------------------------------------
% Margen de fase
% ------------------------------------------------------------

fprintf('\nPM = %.6f grados\n',Pm);

% ------------------------------------------------------------
% Frecuencia de cruce de fase
% Wcg: frecuencia asociada al margen de ganancia
% ------------------------------------------------------------

if isfinite(Wcg) && ~isnan(Wcg)

    fprintf('\nFrecuencia de cruce de fase (-180 grados):\n');
    fprintf('Wcg = %.6f rad/s\n',Wcg);
    fprintf('fcg = %.6f Hz\n',Wcg/(2*pi));

else

    fprintf('\nNo existe un cruce finito de fase en -180 grados.\n');

end

% ------------------------------------------------------------
% Frecuencia de cruce de ganancia
% Wcp: frecuencia donde magnitud = 0 dB
% ------------------------------------------------------------

if isfinite(Wcp) && ~isnan(Wcp)

    fprintf('\nFrecuencia de cruce de ganancia (0 dB):\n');
    fprintf('Wcp = %.6f rad/s\n',Wcp);
    fprintf('fcp = %.6f Hz\n',Wcp/(2*pi));

end

%% ============================================================
% 9. GRAFICA SOLICITADA ENTRE 80 Y 150 kHz
% =============================================================

figure('Name','Ejercicio 1 - Respuesta en frecuencia');

% ------------------------------------------------------------
% MAGNITUD
% ------------------------------------------------------------

subplot(2,1,1);

semilogx(f_kHz,Mag_dB,'LineWidth',1.6);

grid on;
hold on;

% Corte solicitado de 0 dB
yline(0,'--','0 dB');

% Frecuencias de quiebre
xline(90,'--','Polo 90 kHz');
xline(100,'--','Cero 100 kHz');
xline(140,'--','Polo 140 kHz');

xlabel('Frecuencia (kHz)');
ylabel('Magnitud (dB)');
title('Ejercicio 1 - Magnitud de G(j\omega)');
xlim([80 150]);

% ------------------------------------------------------------
% FASE
% ------------------------------------------------------------

subplot(2,1,2);

semilogx(f_kHz,Fase,'LineWidth',1.6);

grid on;
hold on;

% Cortes solicitados
yline(-90,'--','-90 grados');
yline(-180,'--','-180 grados');
yline(-270,'--','-270 grados');

% Frecuencias características
xline(90,'--','90 kHz');
xline(100,'--','100 kHz');
xline(140,'--','140 kHz');

xlabel('Frecuencia (kHz)');
ylabel('Fase (grados)');
title('Ejercicio 1 - Fase de G(j\omega)');
xlim([80 150]);

%% ============================================================
% 10. DIAGRAMA DE BODE COMPLETO
% =============================================================

figure('Name','Ejercicio 1 - Bode completo');

margin(G);
grid on;

title('Ejercicio 1 - Diagrama de Bode con GM y PM');

%% ============================================================
% 11. SISTEMA EN LAZO CERRADO
% =============================================================

T = feedback(G,1);

fprintf('\n');
fprintf('====================================================\n');
fprintf('SISTEMA EN LAZO CERRADO\n');
fprintf('====================================================\n');

fprintf('\nFuncion de transferencia T(s):\n');
disp(T);

%% ============================================================
% 12. POLOS DEL SISTEMA EN LAZO CERRADO
% =============================================================

polosLC = pole(T);

fprintf('\nPolos de lazo cerrado:\n');
disp(polosLC);

%% ============================================================
% 13. DICTAMEN DE ESTABILIDAD
% =============================================================

if all(real(polosLC) < 0)

    fprintf('\n');
    fprintf('RESULTADO:\n');
    fprintf('Todos los polos tienen parte real negativa.\n');
    fprintf('EL SISTEMA EN LAZO CERRADO ES ESTABLE.\n');

else

    fprintf('\n');
    fprintf('RESULTADO:\n');
    fprintf('Existe al menos un polo con parte real >= 0.\n');
    fprintf('EL SISTEMA EN LAZO CERRADO NO ES ESTABLE.\n');

end

%% ============================================================
% 14. RESPUESTA AL ESCALON EN LAZO CERRADO
% =============================================================

figure('Name','Ejercicio 1 - Respuesta al escalon');

step(T);
grid on;

title('Ejercicio 1 - Respuesta al escalon en lazo cerrado');
xlabel('Tiempo (s)');
ylabel('Salida');

%% ============================================================
% FIN DEL EJERCICIO 1
% =============================================================

fprintf('\n====================================================\n');
fprintf('FIN DEL EJERCICIO 1\n');
fprintf('====================================================\n');