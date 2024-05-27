function img = helperSaveSLC(slcimg,minSample,fs,v,prf)
% Save SAR image by providing start and stop

% Cross-range length y (m)
numPulses = size(slcimg,2);
du = v*1/prf; % Cross-range sample spacing (m)
dky = 2*pi/(numPulses*du); % ku domain sample spacing (rad/m)
dy = 2*pi/(numPulses*dky); % y-domain sample spacing (rad/m)
y = dy*numPulses % Cross-range length y (m)

% Range length (m)
c = physconst('LightSpeed');
numSamples = size(slcimg,1);
samples = minSample:(numSamples + minSample - 1);
sampleTime = samples*1/fs;
rngVec = time2range(sampleTime(1:end),c);
x = max(rngVec) - min(rngVec)

% SAR Image
img = abs(slcimg).';
img = imresize(img,[y,x]);
img = imcrop(img,[0,0,250,size(slcimg,2)]);
img = img / max(max(img));

end
