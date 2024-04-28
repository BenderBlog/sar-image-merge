function [entropy_image, standard_deviation,sf] = evaluate(image)
% 使用熵值，标准差评估图像

% 熵值
entropy_image = entropy(image);
disp("熵值为" + num2str(entropy_image));

% 标准差
standard_deviation = std2(image);
disp("标准差为" + num2str(standard_deviation));

% 空间频率
RF = diff(image,1,1);
RF1 = sqrt(mean(mean(RF.^2)));
CF = diff(image,1,2);
CF1 = sqrt(mean(mean(CF.^2)));
sf = sqrt(RF1^2+CF1^2);
disp("空间频率为" + sf);

end