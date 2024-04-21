angles = -12:12;
% (x0,y0) refrence dot, middle of the route
% (x,y) center of the target
v = 100;                           % Speed of the platform (m/s)
dur = 2;                           % Duration of flight (s)
x0 = 0; y0 = 0; x = 1000; y = 0;
routeLength = v * dur;

for angle = angles
    tic
    disp("angle " + angle)
    
    [xMidPoint,yMidPoint] = helperDotTurn(angle, x, y, x0, y0);
    [xStart,yStart] = helperDotTurn(angle, xMidPoint,yMidPoint, xMidPoint,yMidPoint - routeLength / 2);
    [xStop,yStop] = helperDotTurn(angle, xMidPoint,yMidPoint, xMidPoint,yMidPoint + routeLength / 2);
    rdrvel = [v*sin(angle*pi/180) v*cos(angle*pi/180) 0];
    disp([xMidPoint,yMidPoint])
    disp([xMidPoint,yMidPoint - routeLength / 2])
    disp([xMidPoint,yMidPoint + routeLength / 2])
    disp([xStart,yStart])
    disp([xStop,yStop])
end