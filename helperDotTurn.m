function [x1,y1] = helperDotTurn(angle, x, y, x0, y0)
% Change the dot (x,y)'s position by setting the center of the circle
% as (x0, y0), and turning angle
    angle=angle*pi/180;
    x1 = x + (x0 - x) * cos(angle) - (y0 - y) * sin(angle);
    y1 = y + (y0 - y) * cos(angle) + (x0 - x) * sin(angle);
end