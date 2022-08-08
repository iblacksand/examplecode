classdef Liver
    properties
        bpm;
        pressure;
        phase;
        vflow;
        out_stream;
        newolds;
    end
    methods
        function obj = Liver(inputs, olds)
            % out_streams(1) - going to heart
            % out_streams(2) - going to pancreas

            %try to make up for division by 0
            % if inputs.vflow == 0
            %     inputs.vflow = inputs.vflow + 10^-6;
            % end
           %% Oxygen Desaturation from pancreas
            

            bs = Splitter(inputs,[21/27, 6/27]);
            bs{1}.oxygen = (13.57*exp(1.6155*bs{1}.pressure/120))/100;
            inb = Mixer({bs{1}, bs{2}}, olds); % blood with less oxygen
            obj.out_stream = inb;
            obj.newolds = bs;
            
            %%  volumetric flow
            
            obj.out_stream.vflow = 0.6732*log(obj.out_stream.pressure/120) + 1.0031;
            
           %% oyxgen consumption
            
            obj.out_stream.oxygen = (1.2764*exp(3.7647*obj.out_stream.pressure/120))/100;
%             obj.out_stream = inputs;
            % obhelp retunr

            obj.out_stream.carbdioxide = obj.out_stream.carbdioxide + .7*abs(SatToPress(obj.out_stream.oxygen) - SatToPress(inb.oxygen));
        end
    end
    
end