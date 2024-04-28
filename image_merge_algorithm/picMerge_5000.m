rotate = -25:25;

pictures = cell(length(rotate),1);
for i=1:length(rotate)
    pictures{i} = imread(strcat('pic_5000/pic', num2str(rotate(i)), "-5000.jpg") );
end

% 图形要求，必须得够大(感觉得大于80，nstc 要求)
% 必须除以 8 之后依然是 2 的倍数(三次小波要求)
fixedIndex = ceil(length(rotate) / 2);
still = pictures{fixedIndex};
still(still < 180) = 0;
still(still >= 180) = 255;
for i = 1:size(pictures,1)
    i
    % 需要配准，以 0 度的为基准
    if i ~= 0
        moving = pictures{i};
        moving(moving < 128) = 0;
        moving(moving >= 128) = 255;
        %pictures{i} = imrotate(pictures{i},rotate(i) * -1,'bilinear','crop');
        tformEstimate = imregcorr(moving,still);
        Rfixed = imref2d(size(pictures{fixedIndex}));
        pictures{i} = imwarp(pictures{i},tformEstimate,OutputView=Rfixed);
        %imrotate(pictures{i},rotate(i) * -1,'bilinear','crop');
        imshowpair(pictures{fixedIndex},pictures{i},"montage");
        pause(2);
        %imwrite(pictures{i},"pic_5000/" + i + "-rotate.jpg");
    end
    
    
    % 图像裁剪
    r = centerCropWindow2d(size(pictures{i}),[128 128]);
    pictures{i} = imcrop(pictures{i},r);
    %imwrite(pictures{i},"pic_5000/" + i + "-cropped.jpg");
end
