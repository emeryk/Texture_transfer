function [ cut ] = dpcutV2(a, b, mode)

% SSD
errors = sum((a - b).^2, 3); 

% Transpose
if (strcmp(mode, 'horizontal'))
  
  errors = errors';
    
end

% Initialize with the errors
dp = zeros(size(errors, 1), size(errors, 2));

dp(1:size(errors, 2), :) = errors(1:size(errors, 2), :);

% Complete the array with the min path
for i = 2:size(errors, 1)
  for j = 1:size(errors, 2)
  
    path = [dp(i - 1, j)];
    
    if j ~= 1    
      path = [path dp(i - 1, j - 1)];      
    end
    
    if j ~= size(errors, 2)
      path = [path dp(i - 1, j+ 1)];
    end
    
    dp(i, j) = errors(i, j) + min(path);
  
  end
end

% Get the best cut path
cut = ones(size(errors, 1), size(errors, 2));
[~, start] = min(errors(size(errors, 1), 1:size(errors, 2)));
cut(i, start) = 0;
cut(i, start + 1:size(errors, 2)) = 1;
cut(i, 1:start - 1) = -1; 

for i = size(errors, 1) - 1:-1:1
  for j = 1:size(errors, 2)
    
    if start < size(errors, 2)
      
      if errors(i, start + 1) == min(errors(i, max(start - 1, 1):start + 1))
        start = start + 1;
      end
    
    end
    
    if start > 1
      
      if errors(i, start - 1) == min(errors(i, start - 1:min(start + 1, size(errors, 2))))
        start = start - 1;
      end
    
    end
    
    cut(i, start) = 0;
    cut(i, start + 1:size(errors, 2)) = 1;
    cut(i, 1:start - 1) = -1;
  end
end

if strcmp(mode, 'horizontal')
  cut = cut';
end

end