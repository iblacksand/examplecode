classdef Kidneys
    properties
        vflow;
        raflow;
        rvflow;
        out_stream;
        water;
        GFR;
    end
    methods
        function obj = Kidneys(inputs)
            [EPO,rvflow,pH,water,oxygen, GFR] = modifyBlood(obj, 1000*inputs.vflow./60, inputs.oxygen, inputs.carbdioxide, inputs.hct, -log10(inputs.h), inputs.water);
            obj.out_stream = inputs;
            obj.GFR = GFR;
            obj.out_stream.epo = EPO;
            obj.out_stream.vflow = rvflow;
            obj.out_stream.h = 10^(-pH);
            obj.out_stream.oxygen = oxygen; % oxygen consumption(hopkins medicine)
            obj.out_stream.water = water;
            obj.out_stream.carbdioxide = obj.out_stream.carbdioxide + .8*abs(SatToPress(obj.out_stream.oxygen) - SatToPress(inputs.oxygen));
        end

        function [EPO,rvflow,pH,water, oxygen, GFR] = modifyBlood(self, raflow, oxygen, pCO2, hct, pH, water)
            %Inputs
            %tbv = total blood flow in body (mL/min)
            %oxygen = total oxygen in body (mL/min)
            %pCO2= partial pressure of carbon dioxide of blood in body (mmHg)
            %hct = volume of hct in body (mL)
            %raflow originally in L/s --> ml/min

            %BUG -RAFLOW MUST BE CONVERTED INTO SOME SORT OF AVERAGE FLOW (ml/min), NOT INSTANTANEOUS
            voxygen = 1.39*raflow*15*.0007848;
            kidnOx = 0.072*voxygen; %oxygen consumption in kidneys is 7.2% of total O2 cons
            oxygen = oxygen - kidnOx;

            H = -1.53*10^(-7)+5.26*10^(-8)*log(pCO2); %H concentration as a function of partial pressure of CO2
            %^^^MAYBE THIS SHOULD BE IN LUNGS INSTEAD

            %Ph differences
            pH = -log10(H);
            if pH > 7.3 %normal blood pH is greater than 7.3
                GFR = 10*kidnOx-25; %normal kidney function
                EPO = -0.0128*hct*raflow+41.2; %EPO(mIU/mL),hct(mL)
            else
                GFR = 5*kidnOx-20; %acute kidney injury
                EPO = -0.0133*hct*raflow+41.7; %EPO(mIU/mL),hct(mL)
            end

            %volume of blood leaving the kidneys
            rvflow = raflow-0.0083*GFR; %renal vein flow (mL/min)

            %Taking into account water loss in blood due to urine 
            urine = 0.0083*GFR;
            water_loss = 0.95*urine; %%TAKE OUT WATER FROM BLOOD (mL/min)

            old_water_vflow = raflow * (water./100);
            v_other = raflow - old_water_vflow;
            new_water_vflow = old_water_vflow - water_loss;
            new_rvflow = new_water_vflow + v_other;
            rvflow = new_rvflow;
            water = 100*(new_water_vflow/rvflow);

            %Oxygen Consumption?
            %oxygen = oxygen - .0007848;
        end
    end
end