function [entropy_image, standard_deviation,sf ] = evaluate(image)
% 使用熵值，标准差评估图像

% 熵值
entropy_image = entropy(image);
disp("熵值为" + num2str(entropy_image));

% 标准差
standard_deviation = std2(image);
disp("标准差为" + num2str(standard_deviation));

% 空间频率
%image = image / 256;
%image_size = size(image);
%height = image_size(1);
%width = image_size(2);

%rf = 0;
%cf = 0;
%for i = 2:height
%    for j = 2:width
%        rf = rf + (image(i,j-1) - image(i,j)).^2;
%        cf = cf + (image(i-1,j) - image(i,j)).^2;
%    end
%    disp([rf,cf]);
%end
%rf = sqrt(cf / (height*width));
%cf = sqrt(cf / (height*width));

%sf = sqrt(rf^2+cf^2);
%disp("空间频率为" + sf);

end