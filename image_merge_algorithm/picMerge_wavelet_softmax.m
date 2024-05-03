function [resultPic] = picMerge_wavelet_softmax(pictures)

pictures_count = size(pictures,1);

% 分解层次
clevels = 3;

% 小波类型
wave = 'haar';

% 按照分解层次分解的小波变换
% 小波融合会分成低频信息a，水平方向h，竖直方向v，对角线d
% level_data里面的存储顺序也是这样
dealt = cell(pictures_count,1);
for pics = 1:pictures_count
    level_data = cell(clevels, 4);
    [c,s] = wavedec2(pictures{pics}, clevels, wave);
    for j = 1:clevels
        [h,v,d] = detcoef2('all',c,s,j);
        a = appcoef2(c,s,wave,j);
        level_data{j,1} = a;
        level_data{j,2} = h;
        level_data{j,3} = v;
        level_data{j,4} = d;
    end
    dealt{pics} = level_data;
end

% 生产结果矩阵
result = cell(size(dealt{1}));

% 开始自适应融合
for level = 1:clevels
    for type = 1:4
        to_append = zeros(size(dealt{1}{level,type}));
        % 如果不是低频，使用最大绝对值，因为数据量较少
        if (type == 1 && level == clevels) == false
            size_array = size(dealt{1}{level,type});
            for j = 1:size_array(1)
                for k = 1:size_array(2)
                    value_array = zeros(1,5);
                    for pic = 1:pictures_count
                        value_array(pic) = abs(dealt{pics}{level,type}(j,k));
                    end
                    [~,index] = max(value_array);
                    to_append(j,k) = dealt{index}{level,type}(j,k);
                end
            end
        else
            % 否则使用核范式
            newclear_norm_array = zeros(pictures_count,1);
            for pics = 1:pictures_count
                newclear_norm_array(pics) = newclear_norm(dealt{pics}{level,type});
            end
            sum_norm = sum(newclear_norm_array);
            newclear_norm_array = newclear_norm_array / sum_norm;
            for pics = 1:pictures_count
                to_append = to_append + dealt{pics}{level,type} * newclear_norm_array(pics);
            end
        end
        result{level,type} = to_append;
    end
end

% 根据 result 数组重构小波变换后的数据结构
result_append = cell(clevels,1);
for level = clevels:-1:1
    if level == clevels
        result_append{level} = idwt2( ...
            result{level,1}, ...
            result{level,2}, ...
            result{level,3}, ...
            result{level,4}, ...
            wave);
    else
        before = level+1;
        result_append{level} = idwt2( ...
            result_append{before}, ...
            result{level,2}, ...
            result{level,3}, ...
            result{level,4}, ...
            wave);
    end
    %if level == 1
    %    imwrite(uint8(result_append{before}),"wavelet-a.jpg");
    %    imwrite(result{level,2},"wavelet-v.jpg");
    %    imwrite(result{level,3},"wavelet-h.jpg");
    %    imwrite(result{level,3},"wavelet-d.jpg");
    %end
end

% 融合回去
resultPic = uint8(result_append{1});

end
