pictures = {
    imread("pic_5000/pic-4-5000.jpg")
    imread("pic_5000/pic-2-5000.jpg")
    imread("pic_5000/pic0-5000.jpg")
    imread("pic_5000/pic2-5000.jpg")
    imread("pic_5000/pic4-5000.jpg")
    };

rotate = [
    4
    2
    0
    -2
    -4
    ];


% 图形要求，必须得够大(感觉得大于80，nstc 要求)
% 必须除以 8 之后依然是 2 的倍数(三次小波要求)
for i = 1:size(pictures,1)
    % 图像旋转
    pictures{i} = imrotate(pictures{i},rotate(i),'bilinear','crop');
    %imwrite(pictures{i},"pic_5000/" + i + "-rotate.jpg");
    
    % 图像裁剪
    %size_pic = uint16(size(pictures{i}));
    %new_size = [uint16(size_pic(1)/2) uint16(size_pic(1)/2)];
    
    r = centerCropWindow2d(size(pictures{i}),[128 128]);
    pictures{i} = imcrop(pictures{i},r);
    %imwrite(pictures{i},"pic_5000/" + i + "-cropped.jpg");
end

disp("一次小波分解，使用绝对值法");
result = picMerge_straight(pictures);
imwrite(result, "pic_5000/result_straight.jpg");
evaluate(result);
mutual_information(result,pictures);

disp("三次小波分解，使用绝对值法")
result = picMerge_wavelet(pictures);
imwrite(result, "pic_5000/result_wavelet.jpg");
evaluate(result);
mutual_information(result,pictures);

disp("三次小波分解，高频使用修改 softmax 方法，低频使用绝对值法")
result = picMerge_wavelet_softmax(pictures);
imwrite(result, "pic_5000/result_wavelet_softmax.jpg");
evaluate(result);
mutual_information(result,pictures);

disp("三次nsct分解，使用绝对值法")
result = picMerge_nsct(pictures);
imwrite(result, "pic_5000/result_nsct.jpg");
evaluate(result);
mutual_information(result,pictures);

disp("三次nsct分解，高频使用修改 softmax 方法，低频使用绝对值法")
result = picMerge_nsct_softmax(pictures);
imwrite(result, "pic_5000/result_nsct_softmax.jpg");
evaluate(result);
mutual_information(result,pictures);

%size(evaluate(result))