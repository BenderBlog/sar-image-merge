function [x,y,terrain] = helperRandomTerrainGenerator(f,initialHeight, ...
    initialPerturb,minX,maxX,minY,maxY,numIter)
%randTerrainGenerator Generate random terrain
% [x,y,terrain] = helperRandomTerrainGenerator(f,initialHeight, ...
%    initialPerturb,minX,maxX,minY,maxY,seaLevel,numIter)
%
% Inputs: 
%   - f                   = A roughness parameter.  A factor of 2 is a
%                           typical default. Lower values result in a 
%                           rougher terrain; higher values result in a 
%                           smoother surface.
%   - initialHeight       = Sets the initial height of the lattice before 
%                           the perturbations.
%   - initialPerturb      = Initial perturbation amount. This sets the 
%                           overall height of the landscape.
%   - minX,maxX,minY,maxY = Initial points. Provides some degree of control
%                           over the macro appearance of the landscape.
%   - numIter             = Number of iterations that affects the density 
%                           of the mesh that results from the iteration
%                           process.
%
% Output: 
%    - x                  = X-dimension mesh grid
%    - y                  = Y-dimension mesh grid
%    - terrain            = Two-dimensional array in which each value 
%                           represents the height of the terrain at that 
%                           point/mesh-cell

% Generate random terrain
dX = (maxX-minX)/2;
dY = (maxY-minY)/2;
[x,y] = meshgrid(minX:dX:maxX,minY:dY:maxY);
terrain = ones(3,3)*initialHeight;
perturb = initialPerturb;
for ii = 2:numIter
    perturb = perturb/f;
    oldX = x;
    oldY = y;
    dX = (maxX-minX)/2^ii;
    dY = (maxY-minY)/2^ii;
    [x,y] = meshgrid(minX:dX:maxX,minY:dY:maxY);
    terrain = griddata(oldX,oldY,terrain,x,y);
    terrain = terrain + perturb*random('norm',0,1,1+2^ii,1+2^ii);
    terrain(terrain < 0) = 0; 
end
end