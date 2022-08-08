classdef Brain
    properties
        oxygen;
        carbdioxide;
        vflow;
        out_stream;
    end
    methods
        function obj = Brain(inputs)
            obj.out_stream = inputs;
            x = inputs.pressure/120;
            obj.out_stream.oxygen = inputs.oxygen - (.95-.64)*(9.7883*x^3 - 27.252*x^2 + 23.086*x - 4.5925);
            obj.out_stream.carbdioxide = obj.out_stream.carbdioxide + .7*abs(SatToPress(obj.out_stream.oxygen) - SatToPress(inputs.oxygen));
        end
    end
end