classdef Heart_Oxygenated
    properties
        oxygen;
        bpm;
        pressure;
        phase;
        vflow;
        out_stream;
        hct;
    end
    methods
        function obj = Heart_Oxygenated(input1, input2)
            %input1: oxygenated blood object
            %input2: deoxygenated blood object
            obj.out_stream = input1;

            if ((input1.blood_loss*input1.time)./5) ~= 0
                %obj.out_stream.vflow = ((0.0797*((input1.blood_loss*input1.time)./5))+6)./60; %Forsytn et al (Monkey blood loss)
                obj.out_stream.vflow = 6./60; %L/s output
            else
                obj.out_stream.vflow = 6./60; %L/s output
            end
            % Blood pressure
            obj.out_stream.pressure = (-1.7128*((input1.blood_loss*input1.time)./5) + 1)*120; %Gupta (Reg of )
            

            %myocardial oxygen consumption
            obj.out_stream.oxygen = obj.leftoxycons(obj.out_stream.time, input1, input2);
        end

        function pressure = left_v2(self, t)
            %This function simulates arterial blood pressure as a function of time

            %CONSTANT FOR NOW
            pressure = 120; %mmHg
        end

        function newoxsat = leftoxycons(self, t, input1, input2)
            %This function calculates how much oxygen the heart consumes in a given amount of time and returns
            %a new value for oxygen saturation 

            cor_blood_flow = 4.16667; %mL/s average coronary blood flow
            
            %Arteriovenous Difference is the difference in arterial - venous oxygen concentration
            artery_o2_conc = SatToPress(input1.oxygen)*0.000031; %oxygen pressure solubility constant (mL o2/mmHg * mL blood)
            venous_o2_conc = SatToPress(input2.oxygen)*0.000031; %Henry's Law
            arteriovenous_difference = (artery_o2_conc-venous_o2_conc);
            MVO2 = cor_blood_flow * arteriovenous_difference; %oxygen consumption (mL/s)
            MVO2 = MVO2*input1.tstep; %oxygen consumption in one tstep (mL)
            
            %Calculating total number of Hb in this blood object
            total_Hb = ((270*10.^(6))*(input1.hct)*(input1.tstep)*(input1.vflow*1000))./(9.4*10.^(-11));
            o2_molec = input1.oxygen*total_Hb*4; %Assuming 4 oxygens per hemoglobin protein
            mol_o2 =  o2_molec/(6.0221409*10^(23));
            PO2_in = SatToPress(input1.oxygen); % in mmHg
            PO2_in = PO2_in./760; %convert to atm
            VO2_in = (mol_o2*0.08206*310.15)./PO2_in;
            VO2_out = VO2_in - MVO2;
            n_out = (PO2_in*VO2_out)./(0.08206*310.15);
            molec_o2_out = n_out * 6.0221409*10^(23);
            Hb_w_o2_out = molec_o2_out./4;
            newsat = Hb_w_o2_out/total_Hb;
            newoxsat = newsat;
        end
        
    end
end