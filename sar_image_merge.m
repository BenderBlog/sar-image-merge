function sar_image_merge
addpath image_merge_algorithm/
addpath terrain_sar_image_simulator/
addpath .

disp("sar_image_merge, a SAR image fusion software with radar simulation module.");
disp("Copyright 2024 Chen Songze (aka. BenderBlog Rodriguez).");
disp("Please select a source for image fusion:");
disp("1. User's image.");
disp("2. Radar simulation.");
choice = input("Please enter your choice: ");
t = datetime('now','TimeZone','local','Format','yyyy-MM-dd_HH:mm:ss');
if choice == 1
    selpath = uigetdir;
    if selpath == 0
        error('Not inputing folder, not exit.')
    end
    disp(strcat("The folder you choice is ",selpath))
    cd(selpath)
    pictures = {};
    files = dir("*.*");
    % start from 3 to avoid . and ..
    for i = 3:length(files)
        pictures = [pictures,imread(files(i).name)]; %#ok<AGROW>
    end
    newFolderName = strcat("merge_",string(t));
    mkdir(newFolderName)
    cd(newFolderName);
    disp("Please select a fusion algorithm, default all of them")
    disp("1. Once wavelet, max absolute value. (straight)")
    disp("2. Once wavelet, pca method. (wavelet_pca)")
    disp("3. Three times wavelet, max absolute value. (wavelet)")
    disp("4. Three times wavelet, weight with nuclear norm. (wavelet_softmax)")
    disp("5. Three times NSCT, max absolute value. (nsct)")
    disp("6. Three times NSCT, pca method. (nsct_pca)")
    disp("7. Three times NSCT, weight with nuclear norm. (nsct_softmax)")
    choices = input("Enter your choice (straight enter will run all of above):","s");
    file=fopen('log.txt','w');
    fprintf(file, 'sar_image_merge program running on %s.\n',t);
    fprintf(file, 'Detected %d images to be fusioned.\n',size(pictures));
    switch choices
        case "1"
            result = picMerge_straight(pictures);
            evaluate(result,pictures,file,"straight");
            imwrite(result, "result_straight.jpg");
        case "2"
            result = picMerge_wavelet_pca(pictures);
            evaluate(result,pictures,file,"wavelet_pca");
            imwrite(result, "result_wavelet_pca.jpg");
        case "3"
            result = picMerge_wavelet(pictures);
            evaluate(result,pictures,file,"wavelet");
            imwrite(result, "result_wavelet.jpg");
        case "4"
            result = picMerge_wavelet_softmax(pictures);
            evaluate(result,pictures,file,"wavelet_softmax");
            imwrite(result, "result_wavelet_softmax.jpg");
        case "5"
            result = picMerge_nsct(pictures);
            evaluate(result,pictures,file,"nsct");
            imwrite(result, "result_nsct.jpg");
        case "6"
            result = picMerge_nsct_pca(pictures);
            evaluate(result,pictures,file,"nsct_pca");
            imwrite(result, "result_nsct_pca.jpg");
        case "7"
            result = picMerge_nsct_softmax(pictures);
            evaluate(result,pictures,file,"nsct_softmax");
            imwrite(result, "result_nsct_softmax.jpg");
        otherwise
            result = picMerge_straight(pictures);
            evaluate(result,pictures,file,"straight");
            imwrite(result, "result_straight.jpg");
            result = picMerge_wavelet_pca(pictures);
            evaluate(result,pictures,file,"wavelet_pca");
            imwrite(result, "result_wavelet_pca.jpg");
            result = picMerge_wavelet(pictures);
            evaluate(result,pictures,file,"wavelet");
            imwrite(result, "result_wavelet.jpg");
            result = picMerge_wavelet_softmax(pictures);
            evaluate(result,pictures,file,"wavelet_softmax");
            imwrite(result, "result_wavelet_softmax.jpg");
            result = picMerge_nsct(pictures);
            evaluate(result,pictures,file,"nsct");
            imwrite(result, "result_nsct.jpg");
            result = picMerge_nsct_softmax(pictures);
            evaluate(result,pictures,file,"nsct_softmax");
            imwrite(result, "result_nsct_softmax.jpg");
            result = picMerge_nsct_pca(pictures);
            evaluate(result,pictures,file,"nsct_pca");
            imwrite(result, "result_nsct_pca.jpg");
    end
    disp(strcat("Finished running. Log and result at ",newFolderName));
elseif choice == 2
    selpath = uigetdir;
    if selpath == 0
        error('Not inputing folder, not exit.')
    end
    newFolderName = strcat("simulation_",string(t));
    disp(strcat("The folder you choice is ",selpath))
    disp(strcat("The result will be outputed at",newFolderName))
    range = input("Please input image angle: ");
    seed = input("Please input random teerrian generator seed: ");
    cd(selpath)
    mkdir(newFolderName)
    cd(newFolderName);
    disp("Generating image...")
    file=fopen('log.txt','w');
    fprintf(file, 'sar_image_merge program running on %s.\n',t);
    fprintf(file, 'Simulation params: angle is %s and terrain seed is %d.\n',mat2str(range),seed);
    pictures = helperSimulatorScript(seed, range);
    result = picMerge_straight(pictures);
    evaluate(result,pictures,file,"straight");
    imwrite(result, "result_straight.jpg");
    result = picMerge_wavelet_pca(pictures);
    evaluate(result,pictures,file,"wavelet_pca");
    imwrite(result, "result_wavelet_pca.jpg");
    result = picMerge_wavelet(pictures);
    evaluate(result,pictures,file,"wavelet");
    imwrite(result, "result_wavelet.jpg");
    result = picMerge_wavelet_softmax(pictures);
    evaluate(result,pictures,file,"wavelet_softmax");
    imwrite(result, "result_wavelet_softmax.jpg");
    result = picMerge_nsct(pictures);
    evaluate(result,pictures,file,"nsct");
    imwrite(result, "result_nsct.jpg");
    result = picMerge_nsct_softmax(pictures);
    evaluate(result,pictures,file,"nsct_softmax");
    imwrite(result, "result_nsct_softmax.jpg");
    result = picMerge_nsct_pca(pictures);
    evaluate(result,pictures,file,"nsct_pca");
    imwrite(result, "result_nsct_pca.jpg");
    disp(strcat("Finished running. Log and result at ",newFolderName));
else
    error("Wrong choice! Now exit!");
end
disp("See you next time!")