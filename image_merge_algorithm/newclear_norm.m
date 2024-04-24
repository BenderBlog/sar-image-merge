function newclear_norm = newclear_norm(inputArg1)
% 计算矩阵(图片)的核范式

% 奇异值分解，SVD
[~,S,~] = svd(inputArg1);
% 计算核范式，也就是矩阵奇异值的和
newclear_norm = sum(S(:));
end