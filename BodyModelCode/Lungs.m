classdef Lungs
    properties
        oxygen;
        carbdioxide;
        vflow;
        out_stream;
    end
    methods
        function obj = Lungs(inputs)
            %gas exchange stuffs
            p_o2 = 100;
            s_o2 = ((((((p_o2)^3 + 150*p_o2)^(-1))+23400)+1)^(-1))*(100);
            obj.out_stream = inputs;
            obj.out_stream.oxygen = .95;
            obj.out_stream.carbdioxide = 150/500*inputs.carbdioxide;
        end
    end
end