function [entropy_image, standard_deviation, sf, mutualInformation]...
    = evaluate(image, original_images, file, method)
% 使用熵值，标准差，空间频率和互信息评估图像
fprintf(file, "This image is merged with %s method\n", method);

% 熵值
entropy_image = entropy(image);
fprintf(file, "Entropy of image is %.4f\n", entropy_image);

% 标准差
standard_deviation = std2(image);
fprintf(file, "Standard deviation of image is %.4f\n",standard_deviation);

% 空间频率
RF = diff(image,1,1);
RF1 = sqrt(mean(mean(RF.^2)));
CF = diff(image,1,2);
CF1 = sqrt(mean(mean(CF.^2)));
sf = sqrt(RF1^2+CF1^2);
fprintf(file, "Spatial frequency of image is %.4f\n",sf);

% 互信息
pic_count = size(original_images,1);
disp(pic_count);
mutualInformation = zeros(pic_count,1);

for i = 1:pic_count
    entropy1 = entropy(image);
    entropy2 = entropy(original_images{i});
    
    % https://stackoverflow.com/questions/23691398/mutual-information-and-joint-entropy-of-two-images-matlab
    indrow = double(image(:)) + 1;
    indcol = double(original_images{i}(:)) + 1;
    jointHistogram = accumarray([indrow indcol], 1);
    jointProb = jointHistogram / numel(indrow);
    indNoZero = jointHistogram ~= 0;
    jointProb1DNoZero = jointProb(indNoZero);
    jointEntropy = -sum(jointProb1DNoZero.*log2(jointProb1DNoZero));
    
    mutualInformation(i) = entropy1 + entropy2 - jointEntropy;
end
disp(mutualInformation)
fprintf(file, "Mutusal infos of image are %s\n", mat2str(mutualInformation));
fprintf(file, "Median of mutual info %.4f\n", median(mutualInformation));
fprintf(file, "=========================\n");

end