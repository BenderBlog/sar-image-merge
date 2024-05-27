function [pictures] = helperSimulatorScript(seed, angles)
% A SAR image generator based on simulated terrain
% Parameter:
%   seed: random number generator seed
%   angles: the angles image will shown

pictures = cell(length(angles),1);

% Initialize random number generator
rng(seed)

% Create terrain
xLimits         = [900 1600]; % x-axis limits of terrain (m)
yLimits         = [-400 400]; % y-axis limits of terrain (m)
roughnessFactor = 1.5;        % Roughness factor
initialHgt      = 0;          % Initial height (m)
initialPerturb  = 100;        % Overall height of map (m)
numIter         = 8;          % Number of iterations
[x,y,A] = helperRandomTerrainGenerator(roughnessFactor,initialHgt, ....
    initialPerturb,xLimits(1),xLimits(2), ...
    yLimits(1),yLimits(2),numIter);
A(A < 0) = 0; % Fill-in areas below 0
xvec = x(1,:);
yvec = y(:,1);
% Plot simulated terrain
%helperPlotSimulatedTerrain(xvec,yvec,A)

% Define key radar parameters
freq = 1e9;                        % Carrier frequency (Hz)
[lambda,~] = freq2wavelen(freq);   % Wavelength (m)
bw = 30e6;                         % Signal bandwidth (Hz)
fs = 60e6;                         % Sampling frequency (Hz)
tpd = 3e-6;                        % Pulse width (sec)

% Verify that the range resolution is as expected
bw2rangeres(bw)

% Antenna properties
apertureLength = 6;               % Aperture length (m)
%sqa = 0;                          % Squint angle (deg)

% Platform properties
v = 100;                           % Speed of the platform (m/s)
dur = 2;                           % Duration of flight (s)
rdrhgt = 1000;                     % Height of platform (m)
%len = sarlen(v,dur);               % Synthetic aperture length (m)

% Configure the target platforms in x and y
targetpos = [1000,0,0;1020,0,0;980,0,0;]; % Target positions (m)
tgthgts = 0*ones(1,size(targetpos,1)); % Target height (m)
for it = 1:size(targetpos,1)
    % Set target height relative to terrain
    [~,idxX] = min(abs(targetpos(it,1) - xvec));
    [~,idxY] = min(abs(targetpos(it,2) - yvec));
    tgthgts(it) = A(idxX,idxY);
    targetpos(it,3) = tgthgts(it);
end

% Set the reference slant range for the cross-range processing
rc = sqrt((rdrhgt - mean(tgthgts))^2 + (mean(targetpos(:,1)))^2);

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

% Multi wait bar
multiWaitbar( 'CloseAll' );
multiWaitbar( 'Angle process', 0 );
multiWaitbar( 'Generate process', 0);

% (x0,y0) refrence dot, middle of the route
% (x,y) center of the target
x0 = 0; y0 = 0; x = 1000; y = 0;
routeLength = v * dur;

% Plot ground truth on first
helperPlotGroundTruth(xvec,yvec,A,targetpos)

for i = 1:length(angles)
    tic
    angle = angles(i);
    
    [xMidPoint,yMidPoint] = helperDotTurn(angle, x, y, x0, y0);
    [xStart,yStart] = helperDotTurn(angle, xMidPoint,yMidPoint, xMidPoint,yMidPoint - routeLength / 2);
    rdrvel = [v*sin(-angle*pi/180) v*cos(-angle*pi/180) 0];
    
    %xStop = xStart + rdrvel(1) * dur;
    %yStop = yStart + rdrvel(2) * dur;
    
    rdrpos1 = [xStart,yStart,rdrhgt];      % Start position of the radar (m)
    %rdrpos2 = [xStop,yStop,rdrhgt];        % End position of the radar (m)
    
    %disp(xMidPoint)
    %disp(yMidPoint)
    %disp(rdrpos1)
    %disp(rdrpos2)
    %disp(rdrvel)
    %
    % Radar plaform velocity
    
    % Plot custom reflectivity map
    %helperPlotReflectivityMap(xvec,yvec,A,reflectivityType,rdrpos1,rdrpos2,targetpos)
    
    reflectivityMap = surfaceReflectivity('Custom','Frequency',freqTable, ...
        'GrazingAngle',grazTable,'Reflectivity',reflectivityLayers, ...
        'Speckle','Rayleigh');
    
    % Antenna orientation
    depang = depressionang(rdrhgt,rc,'Flat','TargetHeight',mean(tgthgts)); % Depression angle (deg)
    %grazang = depang % Grazing angle (deg)
    
    % Azimuth resolution
    %azResolution = sarazres(rc,lambda,len)  % Cross-range resolution (m)
    
    % Determine PRF bounds
    %[swlen,swwidth] = aperture2swath(rc,lambda,apertureLength,grazang)
    %[prfmin,prfmax] = sarprfbounds(v,azResolution,swlen,grazang);
    
    % Select a PRF within the PRF bounds
    % Not too much, or simulation will be too slow to complete.
    prf = 500; % Pulse repetition frequency (Hz)
    
    % Create a radar scenario
    scene = radarScenario('UpdateRate',prf,'IsEarthCentered',false,'StopTime',dur);
    
    % Add platforms to the scene using the configurations previously defined
    rdrplat = platform(scene,'Trajectory',kinematicTrajectory('Position',rdrpos1,'Velocity',rdrvel));
    
    % Add target platforms
    rcs = rcsSignature('Pattern',5);
    for it = 1:size(targetpos,1)
        platform(scene,'Position',targetpos(it,:),'Signatures',{rcs});
    end

    % Add land surface to scene
    s = landSurface(scene,'Terrain',A,'Boundary',[xLimits;yLimits], ...
        'RadarReflectivity',reflectivityMap, ...
        'ReflectivityMap',reflectivityType);
    
    % Create a radar looking to the right / down / left / up
    mountAngles = [angle depang 0];
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
    % Simulate IQ
    while advance(scene)
        tmp = receive(scene); % nsamp x 1
        raw(:,ii) = tmp{1}(minSample:truncRngSamp);
        %disp("current progress: " + ii/numPulses + "%");
        multiWaitbar( 'Generate process', (ii-1)/numPulses);
        ii = ii + 1;
    end
    multiWaitbar( 'Generate process', (ii-1)/numPulses);
    
    % Generating Single Look Complex image using range migration algorithm
    slcimg = rangeMigrationLFM(raw,rdr.Waveform,freq,v,rc);
    image_name = "pic" + angle + "-" + seed + ".jpg";
    imwrite(helperSaveSLC(slcimg,minSample,fs,v,prf),image_name);
    toc;
    waitfor(helperRotateImage(imread(image_name),image_name));
    pictures{i} = imread(strcat(image_name, "_dealt.jpg"));
    multiWaitbar( 'Angle process', (i)/length(angles) );
end
end