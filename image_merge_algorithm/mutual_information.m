function [mutualInformation] = mutual_information(image,pictures)
pic_count = size(pictures,1);
mutualInformation = zeros(pic_count,1);

for i = 1:pic_count
    entropy1 = entropy(image);
    entropy2 = entropy(pictures{i});

    % https://stackoverflow.com/questions/23691398/mutual-information-and-joint-entropy-of-two-images-matlab
    indrow = double(image(:)) + 1;
    indcol = double(pictures{i}(:)) + 1;
    jointHistogram = accumarray([indrow indcol], 1);
    jointProb = jointHistogram / numel(indrow);
    indNoZero = jointHistogram ~= 0;
    jointProb1DNoZero = jointProb(indNoZero);
    jointEntropy = -sum(jointProb1DNoZero.*log2(jointProb1DNoZero));

    mutualInformation(i) = entropy1 + entropy2 - jointEntropy;
end

disp("图片前后融合的互信息评估值分别为" + mat2str(mutualInformation));

end

