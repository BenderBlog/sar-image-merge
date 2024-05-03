function [angle, rotatedImage] = image_rotate_with_gui(img)
angleToReturn = 0;
fig = uifigure('Name',"图像旋转窗口");
im = uiimage(fig);
imToShow = img;
for i = 1:3
end


im.ImageSource = arr   img;
b = uibutton(fig);
sld = uislider(fig, ...
    Value=angleToReturn, ...
    Limits=[-180 180]);
sld.ValueChangingFcn = @(src,event) updateAngle(src,event,angleToReturn,im,img);
end

function updateAngle(src,event,angleToReturn,im,img)
val = event.Value;
angleToReturn = val;
im.ImageSource = imrotate(img,angleToReturn);
end

