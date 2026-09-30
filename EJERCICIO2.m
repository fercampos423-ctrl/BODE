%% ============================================================
% EJERCICIO 2
% ANALISIS DE RESPUESTA EN FRECUENCIA
% GM, PM Y ESTABILIDAD EN LAZO CERRADO
% =============================================================

clear;
clc;
close all;

%% ============================================================
% 1. DATOS DEL SISTEMA
% =============================================================

K = 5e13;

fz = 85e3;       % Frecuencia del cero [Hz]
fp = 110e3;      % Frecuencia del polo real [Hz]
fa = 120e3;      % Coeficiente del termino de segundo orden
fn = 130e3;      % Frecuencia natural [Hz]

% Conversion a rad/s
wz = 2*pi*fz;
wp = 2*pi*fp;
a  = 2*pi*fa;
wn = 2*pi*fn;

fprintf('\n');
fprintf('====================================================\n');
fprintf('               EJERCICIO 2\n');
fprintf('====================================================\n');

fprintf('\nPARAMETROS DEL SISTEMA\n');
fprintf('wz = %.6f rad/s\n',wz);
fprintf('wp = %.6f rad/s\n',wp);
fprintf('a  = %.6f rad/s\n',a);
fprintf('wn = %.6f rad/s\n',wn);

%% ============================================================
% 2. FACTOR DE AMORTIGUAMIENTO DEL SEGUNDO ORDEN
% =============================================================

% Forma estandar:
%
% s^2 + 2*zeta*wn*s + wn^2
%
% Por comparacion:
%
% a = 2*zeta*wn

zeta = a/(2*wn);

fprintf('\nFactor de amortiguamiento:\n');
fprintf('zeta = %.6f\n',zeta);

%% ============================================================
% 3. FUNCION DE TRANSFERENCIA
% =============================================================

s = tf('s');

G = K*(s+wz) / ...
    (s*(s+wp)*(s^2+a*s+wn^2));

fprintf('\nFUNCION DE TRANSFERENCIA G2(s):\n');
disp(G);

%% ============================================================
% 4. TABULAR 20 VALORES ENTRE 80 kHz Y 150 kHz
% =============================================================

f = linspace(80e3,150e3,20);

% Conversion a frecuencia angular
w = 2*pi*f;

%% ============================================================
% 5. RESPUESTA EN FRECUENCIA
% =============================================================

resp = squeeze(freqresp(G,w));

% Convertir todos los vectores a columnas
resp = resp(:);
f_kHz = f(:)/1000;
omega_rad_s = w(:);

% Magnitud lineal
Mag = abs(resp);

% Magnitud en decibeles
Mag_dB = 20*log10(Mag);

% Fase en grados
Fase = unwrap(angle(resp))*180/pi;

%% ============================================================
% 6. TABLA DE LOS 20 VALORES
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
% 7. FORMULAS ANALITICAS DE MAGNITUD Y FASE
% =============================================================

fprintf('\n');
fprintf('====================================================\n');
fprintf('FORMULAS UTILIZADAS\n');
fprintf('====================================================\n');

fprintf('\nMagnitud:\n');

fprintf(['|G(jw)| = K*sqrt(w^2+wz^2) /\n' ...
    '[w*sqrt(w^2+wp^2)*' ...
    'sqrt((wn^2-w^2)^2+(a*w)^2)]\n']);

fprintf('\nMagnitud en dB:\n');
fprintf('|G(jw)|dB = 20*log10(|G(jw)|)\n');

fprintf('\nFase:\n');

fprintf(['Fase = atan(w/wz) - 90 - atan(w/wp) - ' ...
    'atan2(a*w,wn^2-w^2)\n']);

%% ============================================================
% 8. CALCULO ANALITICO DE MAGNITUD
% =============================================================

Mag_manual = ...
    K.*sqrt(w.^2+wz^2) ./ ...
    ( ...
    w .* ...
    sqrt(w.^2+wp^2) .* ...
    sqrt((wn^2-w.^2).^2 + (a.*w).^2) ...
    );

Mag_manual_dB = 20*log10(Mag_manual);

%% ============================================================
% 9. CALCULO ANALITICO DE FASE
% =============================================================

% atan2d se utiliza porque el termino:
%
% wn^2 - w^2
%
% puede cambiar de signo.

Fase_manual = ...
    atan(w./wz)*180/pi ...
    - 90 ...
    - atan(w./wp)*180/pi ...
    - atan2d(a.*w,wn^2-w.^2);

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
% 10. MARGEN DE GANANCIA Y MARGEN DE FASE
% =============================================================

[Gm,Pm,Wcg,Wcp] = margin(G);

fprintf('\n');
fprintf('====================================================\n');
fprintf('MARGENES DE ESTABILIDAD\n');
fprintf('====================================================\n');

%% Margen de ganancia

if isinf(Gm)

    fprintf('\nGM lineal = infinito\n');
    fprintf('GM = infinito dB\n');

else

    GM_dB = 20*log10(Gm);

    fprintf('\nGM lineal = %.6f\n',Gm);
    fprintf('GM = %.6f dB\n',GM_dB);

end

%% Margen de fase

fprintf('\nPM = %.6f grados\n',Pm);

%% Frecuencia de cruce de fase

if isfinite(Wcg) && ~isnan(Wcg)

    fprintf('\nFrecuencia de cruce de fase (-180 grados):\n');

    fprintf('Wcg = %.6f rad/s\n',Wcg);

    fprintf('fcg = %.6f Hz\n',Wcg/(2*pi));

    fprintf('fcg = %.6f kHz\n',Wcg/(2*pi*1000));

else

    fprintf('\nNo existe cruce finito de -180 grados.\n');

end

%% Frecuencia de cruce de ganancia

if isfinite(Wcp) && ~isnan(Wcp)

    fprintf('\nFrecuencia de cruce de ganancia (0 dB):\n');

    fprintf('Wcp = %.6f rad/s\n',Wcp);

    fprintf('fcp = %.6f Hz\n',Wcp/(2*pi));

end

%% ============================================================
% 11. GRAFICA ENTRE 80 Y 150 kHz
% =============================================================

figure('Name','Ejercicio 2 - Respuesta en frecuencia');

% ------------------------------------------------------------
% MAGNITUD
% ------------------------------------------------------------

subplot(2,1,1);

semilogx(f_kHz,Mag_dB,'LineWidth',1.6);

grid on;
hold on;

% Corte solicitado
yline(0,'--','0 dB');

% Frecuencias características
xline(85,'--','Cero 85 kHz');
xline(110,'--','Polo 110 kHz');
xline(120,'--','120 kHz');
xline(130,'--','\omega_n = 130 kHz');

xlabel('Frecuencia (kHz)');
ylabel('Magnitud (dB)');

title('Ejercicio 2 - Magnitud de G(j\omega)');

xlim([80 150]);

% ------------------------------------------------------------
% FASE
% ------------------------------------------------------------

subplot(2,1,2);

semilogx(f_kHz,Fase,'LineWidth',1.6);

grid on;
hold on;

% Cortes solicitados en la guia
yline(-90,'--','-90 grados');
yline(-180,'--','-180 grados');
yline(-270,'--','-270 grados');

% Marcar cruce real de -180 grados
if isfinite(Wcg) && ~isnan(Wcg)

    fcg_kHz = Wcg/(2*pi*1000);

    if fcg_kHz >= 80 && fcg_kHz <= 150

        xline(fcg_kHz,'--','Cruce -180 grados');

    end

end

xlabel('Frecuencia (kHz)');
ylabel('Fase (grados)');

title('Ejercicio 2 - Fase de G(j\omega)');

xlim([80 150]);

%% ============================================================
% 12. DIAGRAMA DE BODE COMPLETO CON GM Y PM
% =============================================================

figure('Name','Ejercicio 2 - Bode completo');

margin(G);
grid on;

title('Ejercicio 2 - Diagrama de Bode con GM y PM');

%% ============================================================
% 13. SISTEMA EN LAZO CERRADO
% =============================================================

T = feedback(G,1);

fprintf('\n');
fprintf('====================================================\n');
fprintf('SISTEMA EN LAZO CERRADO\n');
fprintf('====================================================\n');

fprintf('\nFuncion de transferencia T(s):\n');

disp(T);

%% ============================================================
% 14. POLOS DE LAZO CERRADO
% =============================================================

polosLC = pole(T);

fprintf('\nPolos del sistema en lazo cerrado:\n');

disp(polosLC);

%% ============================================================
% 15. DICTAMEN DE ESTABILIDAD
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
% 16. RESPUESTA AL ESCALON DEL SISTEMA EN LAZO CERRADO
% =============================================================

figure('Name','Ejercicio 2 - Respuesta al escalon');

step(T);
grid on;

title('Ejercicio 2 - Respuesta al escalon en lazo cerrado');

xlabel('Tiempo (s)');
ylabel('Salida');

%% ============================================================
% FIN DEL EJERCICIO 2
% =============================================================

fprintf('\n====================================================\n');
fprintf('FIN DEL EJERCICIO 2\n');
fprintf('====================================================\n');