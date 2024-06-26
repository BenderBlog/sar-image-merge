function helperPlotGroundTruth(xvec,yvec,A,targetpos)
% Plot ground truth

f = figure('Position',[505 443 997 535]);
movegui(f,'center');
% Plot boundary. Set plot boundary much lower than 0 for rendering reasons. 
hLim = surf([0 1200],[-200 200].',-100*ones(2),'FaceColor',[0.8 0.8 0.8],'FaceAlpha',0.7);
hold on;
hS = surf(xvec,yvec,A);
hS.EdgeColor = 'none';
hC = colorbar;
hC.Label.String = 'Elevation (m)';
hTgt = plot3(targetpos(:,1),targetpos(:,2),targetpos(:,3), ...
    'o','LineWidth',2,'MarkerFaceColor',[0.8500 0.3250 0.0980], ...
    'MarkerEdgeColor','k');
view([26 75])
xlabel('Range (m)')
ylabel('Cross-range (m)')
title('Ground Truth')
axis tight;
zlim([-100 1200])
legend([hLim,hS,hTgt], ...
    {'Scene Limits','Terrain','Target'},'Location','SouthWest')
drawnow
pause(0.25)
end