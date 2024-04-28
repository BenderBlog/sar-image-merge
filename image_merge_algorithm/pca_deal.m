function output = pca_deal(I, level)
% PCA FOR GRAYSCALE IMAGE
% I: the grayscale image
% level: used in pca restore

A = double(I);

%MEAN OF EACH COLUMN IN THE IMAGE
meanCols = mean(A,1);

%SUBTRACT THE MEAN VALUE OF EACH COLUMN
for k = 1:size(A,1)
    A(k,:) = A(k,:)-meanCols;
end

%COMPUTE COVARIANCE MATRIX
covmat = cov(A);
%OBTAIN EIGEN VALUES
[coeff,~] = eig(covmat);
coeff = fliplr(coeff);
FV = coeff(:,1:level)'; %PRINCIPAL COMPONENT
Res = FV*A';

%RECONSTRUCTION
Org = (FV'*Res)';

%ADD THE MEAN VALUES OF THE COLUMN
output = zeros(size(A));
for k = 1:size(A,1)
    output(k,:) = Org(k,:)+meanCols;
end

output = uint8(output);
end