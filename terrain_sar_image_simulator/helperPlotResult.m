for angle = -90
    [xMidPoint,yMidPoint] = helperDotTurn(angle, x, y, x0, y0);
    [xStart,yStart] = helperDotTurn(angle, xMidPoint,yMidPoint, xMidPoint,yMidPoint - routeLength / 2);
    [xStop,yStop] = helperDotTurn(angle, xMidPoint,yMidPoint, xMidPoint,yMidPoint + routeLength / 2);
    rdrpos1 = [xStart,yStart,rdrhgt];      % Start position of the radar (m)
    rdrpos2 = [xStop,yStop,rdrhgt];      % End position of the radar (m)
    rdrvel = [v*sin(angle*pi/180) v*cos(angle*pi/180) 0];
    disp(rdrpos1)
    disp(rdrpos2)

    slcimg = load("pic"+angle+"-5000.mat").slcimg;
    helperPlotSLC(slcimg,minSample,fs,v,prf,rdrpos1,rdrpos2);
end