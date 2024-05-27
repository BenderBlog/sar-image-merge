function [resultPic] = picMerge_wavelet_pca(pictures)
% 本代码参考
% 名称：Pixel level fusion for multiple SAR images using PCA and wavelet transform
% IEEE 链接：https://ieeexplore.ieee.org/document/4148315
disp("Fusioning with wavelet_pca...");

pictures_count = size(pictures,1);

% 小波类型
wave = 'haar';

% 按照分解层次分解的小波变换
% 小波融合会分成低频信息a，水平方向h，竖直方向v，对角线d
% level_data里面的存储顺序也是这样
dealt = cell(pictures_count,4);
for i = 1:pictures_count
    [a,h,v,d] = dwt2(pictures{i},wave);
    dealt{i,1} = a;
    dealt{i,2} = h;
    dealt{i,3} = v;
    dealt{i,4} = d;
end

save("mid-pca.mat","dealt");

% 生产结果矩阵
result = cell(1,4);

% 开始自适应融合
% 然后进行均值权重融合.
value_array = zeros(1,pictures_count);
for type = 1:4
    size_array = size(dealt{1,type});
    to_append = zeros(size_array);
    % 低频信号进行PCA变换，获得第一个近似分量
    % 根据 https://ww2.mathworks.cn/help/images/ref/hyperpca.html
    % 对一个遥感图片，需要获取图片和波长信息，但是目前本人呢没有这个数据
    % 所以，只能按照黑白图片所拥有主成分的一半来了
    % 同时，我们需要通过近似图像的比例值来计算融合比例参数
    if type == 1
        for pic = 1:pictures_count
            pca_level = min(size_array) * 0.75;
            dealt{pic,type} = pca_deal(dealt{pic,type},uint32(pca_level));
            value_array(pic) = mean(dealt{pic,type}(:));
        end
        value_array = value_array / sum(value_array);
    end
    % 进行均值权重融合
    for j = 1:size_array(1)
        for k = 1:size_array(2)
            for pic = 1:pictures_count
                to_append(j,k) = to_append(j,k) + dealt{pic,type}(j,k) * value_array(pic);
            end
        end
    end
    imshow(uint8(to_append));
    pause(2);
    result{type} = uint8(to_append);
end



% 融合回去
resultPic = uint8(idwt2(result{1},result{2},result{3},result{4},wave));

end
