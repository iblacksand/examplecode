function consistency(data, marker_size)
%% FREQUENCY CONSISTENCY
close all
dev = "Pump After 106.8 Hours";
ACQUISITION_RATE = 100;
DOWN = 100;
BIN=60*10;
time = linspace(0,length(data)/DOWN,length(data)); % create times
tots = floor(floor(max(time))/BIN); % total number of bins
cutoff = tots*100*BIN; % cutoff time
data = data(1:cutoff);
dd = reshape(data, [], tots)'; % reshape data into bins

freqs = [];
for i = 1:length(dd(:, 1))
    freqs(i) = calculate(dd(i,:), DOWN); % calculate frequency for each bin
end

m = median(freqs); % calculate frequency
freqs(freqs < 1) = m;
t = 1:tots;

figure
hold on
gt = [];
bt = [];
gfreqs = [];
bfreqs = []; 
% determine which frequencies are too far from median
for i = 1:length(freqs)
    if freqs(i) > 1.1*m || .9*m>freqs(i)
        bt(end+1) = t(i);
        bfreqs(end+1) = freqs(i);
    else
        gt(end+1) = t(i);
        gfreqs(end+1) = freqs(i);
    end
end

% create plot
rectangle('Position', [0, .9*m, (tots+1)/(3600/BIN), .2*m], 'FaceColor', [0 0 0 0.2], "EdgeColor", [0 0 0 0])
plot([0 (tots+1)/(3600/BIN)], [m m], "--k", 'LineWidth', 2)
plot(gt/(3600/BIN),gfreqs, '.b', 'MarkerSize', marker_size)
plot(bt/(3600/BIN),bfreqs, '.r', 'MarkerSize', marker_size)
title("Consistency of " + dev)
xlim([0, (tots+1)/(3600/BIN)])
ylim([0, ceil(1.5*max(freqs)/5)*5])
[h,icons] = legend("Median = " + m + " Hz","Inside Range", "Outside Range");
ylabel("Frequency (Hz)")
xlabel("Time (hr)")
set(findobj(gcf,'type','axes'),'FontName','Franklin Gothic','FontSize', 32, 'LineWidth', 1);
% Find the 'line' objects
texts = findobj(icons,'Type','Text');
icons = findobj(icons,'Type','line');
% Find lines that use a marker
icons = findobj(icons,'Marker','none','-xor');


% Resize the marker in the legend
set(texts,'fontsize',20);
set(icons,'MarkerSize',30);
set(findobj(gcf,'type','axes'),'FontName','Franklin Gothic','FontSize', 32, 'LineWidth', 1);

% display results
if sum(freqs > 1.1*m | .9*m>freqs) ~= 0
    disp("THE FOLLOWING VALUES ARE OUTSIDE THE RANGE")
    disp("-----------------------------------------")
    disp("----------- " + m*.9 + " < m = " + m + " < " + m*1.1 + " -----------")
    disp("-----------------------------------------")
    for i = 1:length(freqs)
        if freqs(i) > 1.1*m || .9*m>freqs(i)
           disp("FREQUENCY: " + freqs(i) + " Hz" + " INDEX: " + i);
        end
    end
else
    disp("ALL VALUES ARE +- 10% OF THE MEDIAN")
    if(abs(max(freqs) - m)) > (abs(min(freqs) - m))
        disp("MAX ERROR WAS: " + abs(max(freqs) - m)/m*100 + "%")
    else
        disp("MAX ERROR WAS : " + abs(min(freqs) - m)/m*100 + "%")
    end
end

%% Pressure
gt = [];
gp = [];
gv = [];
bt = [];
bp = [];
for i = 1:length(dd(:, 1))
    p = toPressure(mean(dd(i,:))); % convert raw voltage to pressur
    if(p < 15) % check to make sure pressure is safe
        gp(end+1) = p;
        gt(end+1) = t(i);
        gv(end+1) = mean(dd(i,:));
    else
        bp(end+1) = p;
        bt(end+1) = t(i);
    end
end

figure % create plots
plot(gt/(3600/BIN), gp, '.b','MarkerSize', marker_size);
hold on
plot(bt/(3600/BIN), bp, '.r','MarkerSize', marker_size);
title("Pressure of Device Over 106.8 Hours");
xlabel("Time (hr)");
ylabel("Average Pressure (cmH2O)")
[h, icons] = legend("Safe Pressure", "Dangerous Pressure");
texts = findobj(icons,'Type','Text');
icons = findobj(icons,'Type','line');
% Find lines that use a marker
icons = findobj(icons,'Marker','none','-xor');


% Resize the marker in the legend
set(texts,'fontsize',20);
set(icons,'MarkerSize',30);
set(findobj(gcf,'type','axes'),'FontName','Franklin Gothic','FontSize', 32, 'LineWidth', 1);
% xlim([0, (tots)/(3600/BIN)])
ylim([0, ceil(1.5*max(gp)/5)*5])

% display results
if(~isempty(bp))
    disp("-------------------------------------------------------------------")
    disp("--ERROR: THE FOLLOWING VALUES ARE OUTSIDE THE SAFE PRESSURE RANGE--")
    disp("-------------------------------------------------------------------")
    for i = 1:length(bp)
        disp("PRESSURE: " + bp(i) + " cmH2O" + " INDEX: " + i);
    end
else
    disp("---------------------------------------------");
    disp("--ALL VALUES ARE IN THE SAFE PRESSURE RANGE--");
    disp("---------------------------------------------");
    disp("MAX PRESSURE WAS: " + max(gp)+ " cmH2O");
    disp("MIN PRESSURE WAS : " + min(gp)+ " cmH2O");
end

figure
[p, s] = polyfit(gt,gv,4);
t1 = linspace(gt(1), gt(end), length(gt));
p1 = polyval(p, t1);
ngv = gv - p1 + 1.0107;
plot(gt/(3600/BIN), gv, '.b','MarkerSize', marker_size);
hold on
plot(t1/(3600/BIN), p1, '--r', 'LineWidth', 2);
gp = toPressure(ngv);
r2 = 1 - (s.normr/norm(gv - mean(gv)))^2;
disp("R2 : " + r2)


title("Sensor Voltage for 107 Hour Test");
ylabel("Voltage (V)");
xlabel("Time (Hr)");
legend("Sensor Voltage", "Line of Best Fit, R^2 = " + r2);
set(findobj(gcf,'type','axes'),'FontName','Franklin Gothic','FontSize', 20, 'LineWidth', 1);

figure
plot(gt/(3600/BIN), gp+4, '.b','MarkerSize', marker_size);
hold on
plot(bt/(3600/BIN), bp+4, '.r','MarkerSize', marker_size);
plot([0, max(gt)], [15, 15], '--r', 'LineWidth', 2); 
title("Pressure of Device Over 82 Hours");
xlabel("Time (hr)");
ylabel("Average Pressure (cmH_2O)")
legend("Safe Pressure", "Dangerous Pressure (15 cmH_2O");
xlim([0, 82])
ylim([0,20])
disp("MAX POSSIBLE CHANGE " + (toPressure(max(gv)) - toPressure(min(gv))));
set(findobj(gcf,'type','axes'),'FontName','Franklin Gothic','FontSize', 18, 'LineWidth', 1);

disp("TOTAL VALID TIME: " + sum(gp > 0)/length(gp)*gt(end)/(3600/BIN))
end

function frequency = calculate(data, Fs)
    ndata = data./norm(data); % normalize data
    Y = fft(ndata); % get fft
    Y = Y(2:floor(length(data)/2+1)); % get only the first half
    freq = Fs/length(data):Fs/length(data):Fs/2; % get frequency domain
    
    % CUTOFF
    
    cutoff = 1;
    [~, I] = min(abs(freq - cutoff));
    Y = Y(I:end);
    freq = freq(I:end);
    
    [~, I] = max(abs(Y)); % find max prominence and corresponding frequency
    frequency = freq(I);
end

function pressure = toPressure(voltage)
    pressure = 2660.727 * voltage - 2687.109; % Pressure in units of cmH2O accounting for signal drift
end