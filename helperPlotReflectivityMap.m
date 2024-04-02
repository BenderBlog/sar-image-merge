function helperPlotReflectivityMap(xvec,yvec,A,reflectivityType,rdrpos1,rdrpos2,targetpos)
% Plot custom reflectivity map

f = figure('Position',[505 443 997 535]);
movegui(f,'center');
% Plot boundary. Set plot boundary much lower than 0 for rendering reasons. 
hLim = surf([0 1200],[-200 200].',-100*ones(2),'FaceColor',[0.8 0.8 0.8],'FaceAlpha',0.7);
hold on
hS = surf(xvec,yvec,A,reflectivityType);
hS.EdgeColor = 'none';
hold on;
colormap(summer(2));
hC = colorbar;
clim([1 2]); 
hC.Ticks = [1 2];
hC.TickLabels = {'Woods','Hills'};
hC.Label.String = 'Land Type';
hPlatPath = plot3([rdrpos1(1) rdrpos2(1)],[rdrpos1(2) rdrpos2(2)],[rdrpos1(3) rdrpos2(3)], ...
    '-k','LineWidth',2);
hPlatStart = plot3(rdrpos1(1),rdrpos1(2),rdrpos1(3), ...
    'o','MarkerFaceColor','g','MarkerEdgeColor','k');
hTgt = plot3(targetpos(:,1),targetpos(:,2),targetpos(:,3), ...
    'o','MarkerFaceColor',[0.8500 0.3250 0.0980],'MarkerEdgeColor','k');
view([26 75])
xlabel('X (m)')
ylabel('Y (m)')
title('Reflectivity Map')
axis tight; 
zlim([-100 1200])
legend([hLim,hS,hPlatPath,hPlatStart,hTgt], ...
    {'Scene Limits','Reflectivity Map','Radar Path','Radar Start','Target'},'Location','SouthWest')
drawnow
pause(0.25)
end
