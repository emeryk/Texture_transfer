close all
clear

%Params
patchSize = 10;
overlap = floor(patchSize / 6);
tolerance = 0.02;
alpha = 0.6;

%Texture
texture = imread('yogurt.jpg');
texture = im2double(texture);

%Target
target = imread('lincoln.jpg');
target = im2double(target);

%Mask
M = zeros(size(target, 1), size(target, 2), 3);
M = im2double(M);

%Size
sizeTexH = size(texture, 1);
sizeTexW = size(texture, 2);

sizeTarH = size(target, 1);
sizeTarW = size(target, 2);

sizeMH = size(M, 1);
sizeMW = size(M, 2);

%CreateMask
if ndims(texture) == 3
  tex_g = double(rgb2gray(uint8(texture)));
else
  tex_g = double(uint8(texture));
end

if ndims(target) == 3
  tar_g = double(rgb2gray(uint8(target)));
else
  tar_g = double(uint8(target));
end

figure(1)
subplot(2, 2, 1)
imshow(texture)
title('Texture de départ')
subplot(2, 2, 2)
imshow(target)
title('Image Target')
subplot(2, 2, 3)
imshow(tex_g)
title('Mask texture')
subplot(2, 2, 4)
imshow(tar_g)
title('Mask target')

for i = 1:(floor(sizeMH / patchSize))
  for j = 1:(floor(sizeMW / patchSize))
  
    si = (i - 1) * patchSize - (i - 1) * overlap + 1;
    sj = (j - 1) * patchSize - (j - 1) * overlap + 1;
    
    ei = si + patchSize - 1;
    ej = sj + patchSize - 1;
    
    errors = zeros(sizeTexH - patchSize, sizeTexW - patchSize);
    
    if i == 1 && j == 1 %% First pixel, random selection
    
      row_idx = randi(sizeTexH - patchSize);
      col_idx = randi(sizeTexW - patchSize);
      
      M(si:ei, sj:ej, :) = texture(row_idx:row_idx + patchSize - 1, col_idx:col_idx + patchSize - 1, :);
      
      continue;
      
    elseif i == 1 %% First row, can only check left
    
      M_slice = M(si:ei, sj:sj + overlap - 1, :);
      errors = calc_errors(texture, tex_g, tar_g, i, j, alpha, M_slice, 'left', patchSize, overlap, true);
      
    elseif j == 1 %% First col, can only check top
    
      M_slice = M(si:si + overlap -1, sj:ej, :);
      errors = calc_errors(texture, tex_g, tar_g, i, j, alpha, M_slice, 'above', patchSize, overlap, true);
 
    else %% All cases
    
      M_slice = M(si:ei, sj:sj + overlap - 1, :);
      errors = calc_errors(texture, tex_g, tar_g, i, j, alpha, M_slice, 'left', patchSize, overlap, true);
      
      M_slice = M(si:si + overlap - 1, sj:ej, :);
      errors = errors + calc_errors(texture, tex_g, tar_g, i, j, alpha, M_slice, 'above', patchSize, overlap, false);
 
      M_slice = M(si:si + overlap - 1, sj:sj + overlap - 1, :);
      errors = errors - calc_errors(texture, tex_g, tar_g, i, j, alpha, M_slice, 'corner', patchSize, overlap, false);
 
    end
    
    matches = find(errors(:) <= (1 + tolerance) * min(errors(:)));
    match_ind = matches(randi(length(matches)));
    [tex_r, tex_c] = ind2sub(size(errors), match_ind);
    
    boundary = ones(patchSize, patchSize);
    
    if i ~= 1 %Top overlap
    
      im_overlap = texture(tex_r:tex_r + overlap - 1, tex_c:tex_c + patchSize - 1, :);
      out_overlap = M(si:si + overlap - 1, sj:ej, :);
      cut = dpcut(im_overlap, out_overlap, 'horizontal');
      boundary(1:overlap, 1:patchSize) = double(cut >= 0);
    
    end
    
    if j~= 1 %Left overlap
    
      im_overlap = texture(tex_r:tex_r + patchSize - 1, tex_c:tex_c + overlap - 1, :);
      out_overlap = M(si:ei, sj:sj + overlap - 1, :);
      cut = dpcut(im_overlap, out_overlap, 'vertical');
      boundary(1:patchSize, 1:overlap) = boundary(1:patchSize, 1:overlap) .* double(cut >= 0);
    
    end
    
    boundary = repmat(boundary, 1, 1, 3);
    M(si:ei, sj:ej, :) = M(si:ei, sj:ej, :) .* (boundary == 0) + texture(tex_r:tex_r + patchSize - 1, tex_c:tex_c + patchSize - 1, :) .* (boundary == 1);
  
  end
  
  figure(2)
  imshow(M);
  drawnow();
  
end

imshow(M);
