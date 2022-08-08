function PlotBlood(time, samples, ptitle)
% PlotBlood plots all of the components in the samples of blood versus time
%   time - vector of the times
%   samples - cell array of Blood objects to be used in sample
%   ptitle - title of plot to be used

    % time = time/60;
    if(length(time) ~= length(samples))
        error("Time vector and samples cell array not of equal length");
    end
    figure
    ylim([0,200]);
    hold on
    % pressure
    pressure = [];
    for i = 1:length(samples)
        pressure(i) = samples{i}.pressure;
    end
    plot(time, pressure);

    % oxygen
    oxygen = [];
    for i = 1:length(samples)
        oxygen(i) = samples{i}.oxygen*100;
    end
    plot(time, oxygen);

    % carbdioxide
    carbdioxide = [];
    for i = 1:length(samples)
        carbdioxide(i) = samples{i}.carbdioxide;
    end
    plot(time, carbdioxide);

    % vflow
    vflow = [];
    means = [];
    for i = 1:length(samples)
        vflow(i) = samples{i}.vflow*1000;
        if i > 60
            means(i) = mean(vflow(end-60:end));
        else
            means(i) = mean(vflow);
        end
    end
    plot(time, means);

    % h
    h = [];
    for i = 1:length(samples)
        h(i) = -log10(samples{i}.h);
    end
    plot(time, h);

    title(ptitle);
    legend("Pressure","Oxygen","Carbon Dioxide", "Volumetric Flow", "Hydrogen Concentration");
    figure
    hold on
    % hct
    hct = [];
    for i = 1:length(samples)
        hct(i) = samples{i}.hct;
    end
    plot(time, hct);

    % glucose
    glucose = [];
    for i = 1:length(samples)
        glucose(i) = samples{i}.glucose;
    end
    plot(time, glucose);

    % epo
    epo = [];
    for i = 1:length(samples)
        epo(i) = samples{i}.epo;
    end
    plot(time, epo);

    % iron
    iron = [];
    for i = 1:length(samples)
        iron(i) = samples{i}.iron;
    end
    plot(time, iron);
    legend("Hematocrit", "Glucose", "EPO", "Iron");
    figure
    % water
    water = [];
    for i = 1:length(samples)
        water(i) = samples{i}.water;
    end
    plot(time, water);
    axis([0, samples{end}.time,0, 100]);
    % legend("Hematocrit", "Glucose", "EPO", "Iron", "Water");
    title(ptitle);
end