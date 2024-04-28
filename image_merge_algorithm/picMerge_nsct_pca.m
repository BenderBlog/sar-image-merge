function [resultPic] = picMerge_nsct_pca(pictures)
% 本代码参考
% 名称：Pixel level fusion for multiple SAR images using PCA and wavelet transform
% IEEE 链接：https://ieeexplore.ieee.org/document/4148315

pictures_count = size(pictures,1);
dealt = cell(size(pictures));

% 这些是用于 nsct 分解用的常量
nlevels = [0, 1, 3];
pfilter = 'maxflat';
dfilter = 'dmaxflat7';

% 分解层次
clevels = 0;

% 进行 nsct 分解
for i = 1:pictures_count
    dealt{i} = nsctdec(double(pictures{i}), nlevels, dfilter, pfilter);
    clevels = length(dealt{i});
end

% 按照结果格式生产空白矩阵
result = cell(size(dealt{1}));
for i = 1:clevels
    if iscell( dealt{1}{i} )
        result{i} = cell(size(dealt{1}{i}));
        for j = 1:size(dealt{1}{i},2)
            result{i}{j} = zeros(size(dealt{1}{i}{j}));
        end
    else
        result{i} = zeros(size(dealt{1}{i}));
    end
end

% 按照分解层次来融合
% PCA 加权法
value_array = zeros(1,pictures_count);
for i = 1:clevels
    if i == 1
        size_array = size(result{i});
        % 对低频进行 PCA 变换
        for pic = 1:pictures_count
            pca_level = min(size_array) * 0.75;
            dealt{pic}{i} = pca_deal(dealt{pic}{i},uint32(pca_level)); 
            value_array(pic) = mean(dealt{pic}{i}(:));
        end
        value_array = value_array / sum(value_array);
    end
    if i == 1 || i == 2
        size_array = size(result{i});
        % 进行均值权重融合
        for j = 1:size_array(1)
            for k = 1:size_array(2)
                for pic = 1:pictures_count
                     result{i}(j,k) = result{i}(j,k) + dealt{pic}{i}(j,k) * value_array(pic);
                end
            end
        end
    else
        % 分解了多少
        csubband = length( dealt{1}{i} );
        for j = 1:csubband
            size_array = size(result{i}{j});
            for k = 1:size_array(1)
                for l = 1:size_array(2)
                    for pic = 1:pictures_count
                         result{i}{j}(k,l) = result{i}{j}(k,l) + dealt{pic}{i}{j}(k,l) * value_array(pic);
                    end
                end
            end
        end
    end
end

resultPic = uint8(nsctrec(result, dfilter, pfilter));
end
