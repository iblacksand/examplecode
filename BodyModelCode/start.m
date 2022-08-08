function start()
% Starts the anemia model
close all

pulse_rate = 70; % pulse rate in bpm
blood_pressure = 90; % blood pressure in mmHg
blood_sugar = 70; % blood sugar level in mg/dL
oxygen_saturation = .95; % percentage (e.g. .95)
state = 1; % 0 if steady-state, 1 if acute
blood_loss = .25*0.000694444444444444; % in L/s
time = 60*(60)*(2);% in seconds

AnemiaModel([pulse_rate, blood_pressure, blood_sugar, oxygen_saturation, state, blood_loss*state, time]);
end