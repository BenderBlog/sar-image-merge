angle = [
    struct("Angle",-12, "Start",[42.62,-305.66,rdrhgt],"End",[1.05,-110.02,rdrhgt])
    struct("Angle",-8,  "Start",[23.65,-238.21,rdrhgt],"End",[-4.18,-40.16,rdrhgt])
    struct("Angle",-5,  "Start",[12.53,-186.81,rdrhgt],"End",[-4.91,12.43,rdrhgt])
    struct("Angle",0,   "Start",[0,-100,rdrhgt],       "End",[0,100,rdrhgt])
    struct("Angle",5,   "Start",[-4.91,-12.43,rdrhgt], "End",[12.53,186.81,rdrhgt])
    struct("Angle",8,   "Start",[-4.18,40.16,rdrhgt],  "End",[23.65,238.21,rdrhgt])
    struct("Angle",12,  "Start",[1.05,110.02,rdrhgt],  "End",[12.53,186.81,rdrhgt])
];


for i=6:7
    slcimg = load("pic"+angle(i).Angle+".mat").slcimg;
    helperPlotSLC(slcimg,minSample,fs,v,prf,angle(i).Start,...
        angle(i).Start(2),angle(i).End(2))
end