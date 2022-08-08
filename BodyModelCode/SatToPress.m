function x = SatToPress(y)
% SatToPress 
% Converts oxygen saturation to partial pressure in mmHg
    x = (-631800*y^3 + 1263600*y^2 + sqrt((-631800*y^3 + 1263600*y^2 - 631800*y)^2 + 364500000*(y - 1)^6) - 631800*y)^(1/3)/(3*2^(1/3)*(y - 1)) - (150*2^(1/3)*(y - 1))/(-631800*y^3 + 1263600*y^2 + sqrt((-631800*y^3 + 1263600*y^2 - 631800*y)^2 + 364500000*(y - 1)^6) - 631800*y)^(1/3);
    % x = 3.8826*exp(3.3791*y);
end