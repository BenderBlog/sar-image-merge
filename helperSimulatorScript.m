% 生成模拟地形
% 设定随机数
rng(2500)

% 生成模拟地形
xLimits         = [800 1500]; % x-axis limits of terrain (m)
yLimits         = [-200 200]; % y-axis limits of terrain (m)
roughnessFactor = 1.75;       % Roughness factor % a
initialHgt      = 0;          % Initial height (m)
initialPerturb  = 200;        % Overall height of map (m)
numIter         = 8;          % Number of iterations
[x,y,A] = helperRandomTerrainGenerator(roughnessFactor,initialHgt, ....
    initialPerturb,xLimits(1),xLimits(2), ...
    yLimits(1),yLimits(2),numIter);
A(A < 0) = 0; % Fill-in areas below 0
xvec = x(1,:);
yvec = y(:,1);
% Define key radar parameters
resMapX = mean(diff(xvec));
resMapY = mean(diff(yvec));

% 查看地形
helperPlotSimulatedTerrain(xvec,yvec,A);

% 确定 SAR 参数
% Define key radar parameters
freq = 1e9;                        % Carrier frequency (Hz)
[lambda,c] = freq2wavelen(freq);   % Wavelength (m)
bw = 30e6;                         % Signal bandwidth (Hz)
fs = 60e6;                         % Sampling frequency (Hz)
tpd = 3e-6;                        % Pulse width (sec)

% Verify that the range resolution is as expected
bw2rangeres(bw)

% Antenna properties
apertureLength = 6;                % Aperture length (m)
sqa = 30;                           % Squint angle (deg)

% Platform properties
v = 100;                           % Speed of the platform (m/s)
dur = 4;                           % Duration of flight (s)
rdrhgt = 1000;                     % Height of platform (m)
rdrpos1 = [0 -200 rdrhgt];            % Start position of the radar (m)
rdrvel = [0 v 0];                  % Radar plaform velocity
rdrpos2 = rdrvel*dur + rdrpos1;    % End position of the radar (m)
len = sarlen(100,1)                % Synthetic aperture length (m)

% Configure the target platforms in x and y
targetpos = [1000,len/2,0;1020,len/2,0;1040,len/2,0]; % Target positions (m)
tgthgts = 110*ones(1,3); % Target height (m)
for it = 1:3
    % Set target height relative to terrain
    [~,idxX] = min(abs(targetpos(it,1) - xvec));
    [~,idxY] = min(abs(targetpos(it,2) - yvec));
    tgthgts(it) = tgthgts(it) + A(idxX,idxY);
    targetpos(it,3) = tgthgts(it);
end

% Set the reference slant range for the cross-range processing
rc = sqrt((rdrhgt - mean(tgthgts))^2 + (mean(targetpos(:,1)))^2);

% Antenna orientation
depang = depressionang(rdrhgt,rc,'Flat','TargetHeight',mean(tgthgts)); % Depression angle (deg)
grazang = depang; % Grazing angle (deg)

% Azimuth resolution
azResolution = sarazres(rc,lambda,len)  % Cross-range resolution (m)

% Determine PRF bounds
[swlen,swwidth] = aperture2swath(rc,lambda,apertureLength,grazang);
[prfmin,prfmax] = sarprfbounds(v,azResolution,swlen,grazang);

% Select a PRF within the PRF bounds
prf = 500; % Pulse repetition frequency (Hz)

% Create a radar scenario
scene = radarScenario('UpdateRate',prf,'IsEarthCentered',false,'StopTime',dur);

% Add platforms to the scene using the configurations previously defined
rdrplat = platform(scene,'Trajectory',kinematicTrajectory('Position',rdrpos1,'Velocity',[0 v 0]));

% Add target platforms
rcs = rcsSignature('Pattern',5);
for it = 1:3
    platform(scene,'Position',targetpos(it,:),'Signatures',{rcs});
end

% Plot ground truth
helperPlotGroundTruth(xvec,yvec,A,rdrpos1,rdrpos2,targetpos);

% 生成地形反射率图（模拟对应地形对雷达的反射率）
% Specify custom reflectivity map
grazTable = 20:0.1:60;
freqTable = [1e9 10e9];
numSurfaces = 2;
reflectivityLayers = zeros(numel(grazTable),numel(freqTable),numSurfaces);
reflectivityLayers(:,:,1) = landreflectivity('Woods', ...
    grazTable,freqTable);
reflectivityLayers(:,:,2) = landreflectivity('WoodedHills', ...
    grazTable,freqTable);
reflectivityType = ones(size(A));
reflectivityType(A > 100) = 2;

% Plot custom reflectivity map
helperPlotReflectivityMap(xvec,yvec,A,reflectivityType,rdrpos1,rdrpos2,targetpos);

reflectivityMap = surfaceReflectivity('Custom','Frequency',freqTable, ...
    'GrazingAngle',grazTable,'Reflectivity',reflectivityLayers, ...
    'Speckle','Rayleigh');

% 设置雷达接受装置
% Create a radar looking to the right
mountAngles = [0 depang 0];
rdr = radarTransceiver('MountingAngles',mountAngles,'NumRepetitions',1);

% Set peak power
rdr.Transmitter.PeakPower = 50e3;

% Set receiver sample rate and noise figure
rdr.Receiver.SampleRate = fs;
rdr.Receiver.NoiseFigure = 30;

% Define transmit and receive antenna and corresponding parameters
antbw = ap2beamwidth(apertureLength,lambda);
ant = phased.SincAntennaElement('FrequencyRange',[1e9 10e9],'Beamwidth',antbw);
rdr.TransmitAntenna.Sensor = ant;
rdr.TransmitAntenna.OperatingFrequency = freq;
rdr.ReceiveAntenna.Sensor = ant;
rdr.ReceiveAntenna.OperatingFrequency = freq;
antennaGain = aperture2gain(apertureLength^2,lambda);
rdr.Transmitter.Gain = antennaGain;
rdr.Receiver.Gain = antennaGain;

% Configure the LFM signal of the radar
rdr.Waveform = phased.LinearFMWaveform('SampleRate',fs,'PulseWidth',tpd, ...
    'PRF',prf,'SweepBandwidth',bw);

% Add radar to radar platform
rdrplat.Sensors = rdr;

% 生成数据集
% Collect clutter returns with the clutterGenerator
clutterGenerator(scene,rdr);

% Initialize output IQ datacube
minSample = 500; % Minimum sample range
maxRange = 2500; % Maximum range for IQ collection
truncRngSamp = ceil(range2time(maxRange)*fs); % Limit the number of samples
T = 1/prf; % Pulse repetition interval (sec)
numPulses = dur/T + 1; % Number of pulses
raw = zeros(numel(minSample:truncRngSamp),numPulses); % IQ datacube

% Collect IQ
ii = 1;
hRaw = helperPlotRawIQ(raw,minSample);
while advance(scene) %#ok<UNRCH>
    tmp = receive(scene); % nsamp x 1
    raw(:,ii) = tmp{1}(minSample:truncRngSamp);
    if mod(ii,100) == 0 % Update plot after 100 pulses
        helperUpdatePlotRawIQ(hRaw,raw);
    end
    ii = ii + 1;
end
helperUpdatePlotRawIQ(hRaw,raw);

% 模拟后生成
% Generating Single Look Complex image using range migration algorithm
slcimg = rangeMigrationLFM(raw,rdr.Waveform,freq,v,rc);
helperPlotSLC(slcimg,minSample,fs,v,prf,rdrpos1,targetpos, ...
    xvec,yvec,A)

% 查看目标是否可见
for it = 1:3
    % Determine whether the target was occluded
    occ = false(1,numPulses);
    for ip = 1:numPulses
        rdrpos = rdrpos1 + rdrvel.*1/prf*(ip - 1);
        occ(ip) = s.occlusion(rdrpos,targetpos(it,:));
    end

    % Translate occlusion values to a visibility status
    helperGetVisibilityStatus(it,occ)
end