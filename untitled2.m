for i=1:9
    slcimg = load("pic"+angle(i).Angle+"-5000.mat").slcimg;
    helperPlotSLC(slcimg,minSample,fs,v,prf,angle(i).Start,...
        angle(i).Start(2),angle(i).End(2),angle(i).Angle)
end