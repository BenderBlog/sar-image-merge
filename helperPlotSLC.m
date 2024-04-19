function helperPlotSLC(slcimg,minSample,fs,v,prf,rdrpos1,min_y,max_y,angle_pic)
% Plot magnitude of focused SAR image alongside reflectivity map

% Cross-range y-vector (m)
numPulses = size(slcimg,2); 
du = v*1/prf; % Cross-range sample spacing (m) 
dky = 2*pi/(numPulses*du); % ku domain sample spacing (rad/m)
dy = 2*pi/(numPulses*dky); % y-domain sample spacing (rad/m)
y = dy*(0:(numPulses - 1)) + rdrpos1(2); % Cross-range y-vector (m) 

% Range vector (m)
c = physconst('LightSpeed'); 
numSamples = size(slcimg,1); 
samples = minSample:(numSamples + minSample - 1);
sampleTime = samples*1/fs; 
rngVec = time2range(sampleTime(1:end),c); 

% Initialize figure
f = figure('Position',[264 250 1411 535]);
movegui(f,'center')
tiledlayout(1,2,'TileSpacing','Compact');

% SAR Image
slcimg = abs(slcimg).';
hProc = pcolor(rngVec,y,slcimg);
hProc.EdgeColor = 'none'; 
colormap(hProc.Parent,gray)
hC = colorbar('southoutside');
hC.Label.String = 'Magnitude';
xlabel('Slant Range (m)')
ylabel('Cross-range (m)')
title(strcat('SAR Image with angle"',int2str(angle_pic),'"'))
axis equal
xlim([1250 1500])
ylim([min_y max_y])

drawnow
pause(0.25)
end
