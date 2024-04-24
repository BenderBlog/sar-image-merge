function [resultPic] = picMerge_nsct_softmax(pictures)

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
for i = 1:clevels
    if i == 1
        % 对于低频，绝对值最大法
        size_array = size(result{i});
        for j = 1:size_array(1)
            for k = 1:size_array(2)
                value_array = zeros(1,5);
                for pic = 1:pictures_count
                    value_array(pic) = abs(dealt{pic}{i}(j,k));
                end
                [~,index] = max(value_array);
                result{i}(j,k) = dealt{index}{i}(j,k);
            end
        end
    % 用于高频，仍使用修改的 softmax 函数，使用核范式            
    elseif i == 2
        % 第二层是高频，但只有一个图片
        newclear_norm_array = zeros(pictures_count,1);
        for k = 1:pictures_count
             newclear_norm_array(k) = newclear_norm(dealt{k}{i});
        end
        sumup = sum(newclear_norm_array);
        target_data = zeros(size(dealt{k}{i}));
        for k = 1:pictures_count
            target_data = target_data + dealt{k}{i} * newclear_norm_array(k);
        end
        result{i} = target_data / sumup;
    else
        % 分解了多少
        csubband = length( dealt{1}{i} );
        for j = 1:csubband
            newclear_norm_array = zeros(pictures_count,1);
            for k = 1:pictures_count
                newclear_norm_array(k) = newclear_norm(dealt{k}{i}{j});
            end
            sumup = sum(newclear_norm_array);
            target_data = zeros(size(dealt{k}{i}{j}));
            for k = 1:pictures_count
                target_data = target_data + dealt{k}{i}{j} * newclear_norm_array(k);
            end
            result{i}{j} = target_data / sumup;
        end
    end
end

resultPic = uint8(nsctrec(result, dfilter, pfilter));
end
