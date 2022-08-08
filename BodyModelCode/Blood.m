classdef Blood
    %UNITS:
    %   pressure: mmHg
    %   oxygen  : Saturation %
    %   co2     : Saturation %
    %   vflow   : L/s
    %   h       : Molarity
    %   hct     : Volume %
    %   glucose : mg/dL
    %   epo     : millions of IU/mL
    %   iron    : mg/mL
    %   water   : volume %
    %   tstep   : seconds
    %   time    : seconds
    properties
        pressure;
        oxygen;
        carbdioxide;
        vflow;
        h;
        hct;
        glucose;
        epo;
        iron;
        water;
        tstep;
        time;
        blood_loss;
        initial_volume;
    end
    methods
    end
end