function AnemiaModel(input_vals)
% AnemiaModel Models the effects of acute anemia caused by trauma
%   input_vals(1) - pulse rate(bpm)
%   input_vals(2) - blood pressure(mmHg)
%   input_vals(3) - blood sugar level(mg/dL)
%   input_vals(4) - oxygen saturation(e.g. 0.95)
%   input_vals(5) - 0 if steady-state, 1 if acute anemia
%   input_vals(6) - (optional) Blood loss(L/min)
%   input_vals(7) - time in seconds
if(input_vals(5) == 0 || input_vals(5) == 1)
    %% Steady-state model
    t_step = 1; % .01 second
    t_end = input_vals(7); % time
    blood_loss = input_vals(6);

    blood_initial = Blood; % blood starting in the heart
    blood_initial.vflow = 5; %volumetric flow: 5L/min 
    blood_initial.oxygen = input_vals(4); %oxygen saturation 
    blood_initial.carbdioxide = 40;
    blood_initial.h = 10^(-7.4); % assume blood pH is 7.4 
    %All placeholder values 
    blood_initial.hct = 0.37; % hematocrit is vol RBC/ total blood volume 
    blood_initial.epo = 20; % Place holders????
    blood_initial.iron = 34; % Place holders????
    blood_initial.water = 54.9/100; 
    blood_initial.pressure = input_vals(2); 
    blood_initial.glucose = input_vals(3);
    blood_initial.blood_loss = blood_loss;
    blood_initial.initial_volume = 5000;
    acute = input_vals(5);
    heartstreams = {};
    kidstreams = {};
    livstreams = {};
    brainstreams = {};
    lungstreams = {};
    plottimes = t_step:t_step:t_end;
    
    % Get oxygenated blood
    oxy_blood = blood_initial;
    oxy_blood.time = t_step;
    oxy_blood.tstep = t_step;
    to_lungs = oxy_blood;

    %% olds

    olds{1} = {oxy_blood, oxy_blood, oxy_blood};
    livolds{1} = {oxy_blood, oxy_blood, oxy_blood};

    % Organ failures

    failed_organs = 0;
    organ_log = {};
    death_percents = {"30%", "60%", "85%", "100%"};
    brain_dead = false;
    lungs_dead = false;
    liver_dead = false;
    heart_dead = false;
    kidney_dead = false;
    flowrates = [];
    meanrates = [];
    %% Loop through time steps
    for t = t_step:t_step:t_end
        % Order
        % 1. Oxygenated Heart
        % 2. Kidney and Brain and Liver
        % 3. Lungs
        % 1. Oxygenated Heart
        % ...
        oxy_blood.time = t;
        ho = Heart_Oxygenated(oxy_blood, to_lungs);
        heart_out_stream = ho.out_stream;
        heart_out_stream.tstep = t_step;
        heart_out_stream.time = t;
        
%         if(heart_dead | -log10(oxy_blood.h) < 7.24)
%             if ~heart_dead
%                 organ_log{end+1} = "Heart died at " + t;
%                 disp(organ_log{end});
%             end
%             heart_dead = true;
%             heart_out_stream.vflow = 0;
%         end

        flowrates = [flowrates, heart_out_stream.vflow];
        meanrate = mean(flowrates);
        meanrates(end + 1) = meanrate;
        heartstreams{end + 1} = heart_out_stream;
        splitting_vector = [.22, .15, .25, 1 - (.22 + .15 + .25)]; % 1 Kidney, 2 Brain, 3 Liver, 4 surroundings
        if acute == 1
            splitting_vector = [.20*.1, .15*2.05, .25*3, 1 - (.20*.1 + .15*2.05 + .25*3)];
        end
        streams = Splitter(heart_out_stream, splitting_vector);
        
        %% Surroundings
        
        surr_blood = streams{4};
        if acute == 1
            surr_blood.hct = (surr_blood.hct*surr_blood.vflow - surr_blood.hct*blood_loss)/surr_blood.vflow;

            surr_blood.iron = (surr_blood.iron*surr_blood.vflow - surr_blood.iron*blood_loss)/surr_blood.vflow;

            surr_blood.water = (surr_blood.water*(surr_blood.vflow - blood_loss) + 1*blood_loss)/surr_blood.vflow;
        end

        
        % Kidney

        k = Kidneys(streams{1});
        k_stream = k.out_stream;

        if(abs(k.GFR) < 15 || kidney_dead)
            if ~kidney_dead
                organ_log{end+1} = "Kidney died at " + t;
                disp(organ_log{end});
            end
            kidney_dead = true;
            k_stream = streams{1};
        end

        kidstreams{end + 1} = k_stream;

        % Liver

        liv = Liver(streams{3}, olds);
        liv_stream = liv.out_stream;

        if(SatToPress(streams{3}.oxygen) < 50 || liver_dead)
            if ~liver_dead
                organ_log{end+1} = "liver died at " + t;
                disp(organ_log{end});
            end
            liver_dead = true;
            liv_stream = streams{3};
        end

        if liv_stream.vflow ~= 0
            livolds{end + 1} = liv.newolds;
        end
        
        livstreams{end + 1} = liv_stream;
        

        % Brain

        b = Brain(streams{2});
        brain_stream = b.out_stream;
        brainstreams{end + 1} = brain_stream;
        if(SatToPress(streams{2}.oxygen) < 16 || streams{2}.carbdioxide > 105 | brain_dead)
            if ~brain_dead
                organ_log{end+1} = "brain died at " + t;
                disp(organ_log{end});
            end
            brain_dead = true;
            brain_stream = streams{2};
        end

        to_lungs = Mixer({liv_stream, k_stream, surr_blood}, olds);
        to_lungs.vflow = heart_out_stream.vflow;
        if to_lungs.vflow ~= 0
            olds{end+1} = {liv_stream, k_stream, surr_blood};
        end
        L = Lungs(to_lungs);
        lungs_stream = L.out_stream;
        if t ~= t_step && (to_lungs.carbdioxide > 50000 || lungs_dead) % dead lung
            if ~lungs_dead
                organ_log{end+1} = "lungs died at " + t;
                disp(organ_log{end});
            end
            lungs_dead = true;
            lungs_stream = to_lungs;
        end
        lungstreams{end + 1} = lungs_stream;
        oxy_blood = lungs_stream;
    end

    figure
    plot(1:length(flowrates), flowrates, 'r-');
    title("Flowrates");

    PlotBlood(plottimes, heartstreams, "Heart");
    PlotBlood(plottimes, kidstreams, "Kidney");
    PlotBlood(plottimes, livstreams, "Liver");
    PlotBlood(plottimes, brainstreams, "Brain");
    PlotBlood(plottimes, lungstreams, "Lungs");
    figure
    plot(1:length(meanrates), meanrates, 'r-');
    title("Flowrates");
    for i = 1:length(organ_log)
        disp(organ_log{i});
    end
else
    error("Incorrect value for input_vals(5)");
end
end