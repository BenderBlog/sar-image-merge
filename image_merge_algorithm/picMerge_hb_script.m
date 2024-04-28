pictures = {
    imread("pic_hb/HB14981.jpg")
    imread("pic_hb/HB15051.jpg")
    imread("pic_hb/HB15121.jpg")
    imread("pic_hb/HB15181.jpg")
    imread("pic_hb/HB15247.jpg")
    };

rotate = [
    231.707016
    232.707016
    233.707016
    234.707016
    235.707016
    ];

% 图形要求，必须得够大(感觉得大于80，nstc 要求)
% 必须除以 8 之后依然是 2 的倍数(三次小波要求)
for i = 1:size(pictures,1)
    % 图像旋转
    pictures{i} = imrotate(pictures{i},rotate(i),'bilinear','crop');
    %imwrite(pictures{i},i + "-rotate.jpg");
    
    % 图像裁剪
    %size_pic = uint16(size(pictures{i}));
    %new_size = [uint16(size_pic(1)/2) uint16(size_pic(1)/2)];
    
    r = centerCropWindow2d(size(pictures{i}),[96 96]);
    pictures{i} = imcrop(pictures{i},r);
    %imwrite(pictures{i},i + "-cropped.jpg");
end

disp("一次小波分解，使用绝对值法");
result = picMerge_straight(pictures);
imwrite(result, "pic_hb/result_straight.jpg");
evaluate(result);
mutual_information(result,pictures);

disp("三次小波分解，使用绝对值法")
result = picMerge_wavelet(pictures);
imwrite(result, "pic_hb/result_wavelet.jpg");
evaluate(result);
mutual_information(result,pictures);

disp("三次小波分解，高频使用修改 softmax 方法，低频使用绝对值法")
result = picMerge_wavelet_softmax(pictures);
imwrite(result, "pic_hb/result_wavelet_softmax.jpg");
evaluate(result);
mutual_information(result,pictures);

disp("三次nsct分解，使用绝对值法")
result = picMerge_nsct(pictures);
imwrite(result, "pic_hb/result_nsct.jpg");
evaluate(result);
mutual_information(result,pictures);

disp("三次nsct分解，高频使用修改 softmax 方法，低频使用绝对值法")
result = picMerge_nsct_softmax(pictures);
imwrite(result, "pic_hb/result_nsct_softmax.jpg");
evaluate(result);
mutual_information(result,pictures);


disp("一次小波分解，pca method")
result = picMerge_wavelet_pca(pictures);
imwrite(result, "pic_hb/result_wavelet_pca.jpg");
evaluate(result);
mutual_information(result,pictures);

disp("三次 NSCT 分解，pca method")
result = picMerge_nsct_pca(pictures);
imwrite(result, "pic_hb/result_nsct_pca.jpg");
evaluate(result);
mutual_information(result,pictures);

%size(evaluate(result))