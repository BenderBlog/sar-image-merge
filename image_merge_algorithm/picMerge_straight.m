function [resultPic] = picMerge_straight(pictures)
disp("Fusioning with straight...")

pictures_count = size(pictures,1);
dealt = cell(pictures_count,4);
result = cell(1,4);

wave = 'haar';

for i = 1:pictures_count
    [a,h,v,d] = dwt2(pictures{i},wave);
    dealt{i,1} = a;
    dealt{i,2} = h;
    dealt{i,3} = v;
    dealt{i,4} = d;
end

for i = 1:4
    size_array = size(dealt{1,i});
    to_append = zeros(size_array);
    % 绝对值较大方式
    for j = 1:size_array(1)
        for k = 1:size_array(2)
            value_array = zeros(1,5);
            for pic = 1:pictures_count
                value_array(pic) = abs(dealt{pic,i}(j,k));
            end
            [~,index] = max(value_array);
            to_append(j,k) = dealt{index,i}(j,k);
        end
    end
    result{i} = to_append;
end

resultPic = uint8(idwt2(result{1},result{2},result{3},result{4},wave));

end