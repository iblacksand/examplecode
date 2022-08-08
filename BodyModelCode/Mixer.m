function output_stream = Mixer(inputs, old)
% Mixer mixes all of the input streams to a single output stream

    %% volumetric flow
    
    output_stream = Blood;
    new_vflow = 0;
    for i = 1:length(inputs)
        new_vflow = new_vflow + inputs{i}.vflow;
    end

    if(new_vflow == 0)
        newolds = old{1:end-1};
        output_stream = Mixer(old{end}, newolds);
        output_stream.vflow = 0;
        return;
    end

    
    output_stream.vflow = new_vflow;

    %% oxygen
    
    new_oxygen = 0;
    for i = 1:length(inputs)
        new_oxygen = new_oxygen + inputs{i}.vflow*inputs{i}.oxygen;
    end
    new_oxygen = new_oxygen/new_vflow;
    output_stream.oxygen = new_oxygen;

    %% carbon dioxide

    new_carbdioxide = 0;
    for i = 1:length(inputs)
        new_carbdioxide = new_carbdioxide + inputs{i}.vflow*inputs{i}.carbdioxide;
    end
    new_carbdioxide = new_carbdioxide/new_vflow;
    output_stream.carbdioxide = new_carbdioxide;

    %% Hydrogen

    new_h = 0;
    for i = 1:length(inputs)
        new_h = new_h + inputs{i}.vflow*inputs{i}.h;
    end
    new_h = new_h/new_vflow;
    output_stream.h = new_h;

    %% hct

    new_hct = 0;
    for i = 1:length(inputs)
        new_hct = new_hct + inputs{i}.vflow*inputs{i}.hct;
    end
    new_hct = new_hct/new_vflow;
    output_stream.hct = new_hct;

    %% glucose

    new_glucose = 0;
    for i = 1:length(inputs)
        new_glucose = new_glucose + inputs{i}.vflow*inputs{i}.glucose;
    end
    new_glucose = new_glucose/new_vflow;
    output_stream.glucose = new_glucose;

    %% EPO

    new_epo = 0;
    for i = 1:length(inputs)
        new_epo = new_epo + inputs{i}.vflow*inputs{i}.epo;
    end
    new_epo = new_epo/new_vflow;
    output_stream.epo = new_epo;

    %% Iron

    new_iron = 0;
    for i = 1:length(inputs)
        new_iron = new_iron + inputs{i}.vflow*inputs{i}.iron;
    end
    new_iron = new_iron/new_vflow;
    output_stream.iron = new_iron;

    %% Water

    new_water = 0;
    for i = 1:length(inputs)
        new_water = new_water + inputs{i}.vflow*inputs{i}.water;
    end
    new_water = new_water/new_vflow;
    output_stream.water = new_water;

    % Time management
    output_stream.tstep = inputs{1}.tstep;
    output_stream.time = inputs{1}.time;
    output_stream.pressure = inputs{1}.pressure;
    output_stream.blood_loss = inputs{1}.blood_loss;
end