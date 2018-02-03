function [ errors ] = calc_errors(texture, tex_g, tar_g, i, j, alpha, M_slice, mode, patchSize, overlap, bool)

sizeTexH = size(texture, 1);
sizeTexW = size(texture, 2);

errors = zeros(sizeTexH - patchSize, sizeTexW - patchSize);

% Find the best matching block
for x = 1:sizeTexH - patchSize
  for y = 1:sizeTexW - patchSize
  
    si = x;
    sj = y;
    
    if strcmp(mode, 'above')
      
      ei = si + overlap - 1;
      ej = sj + patchSize - 1;
      
    elseif strcmp(mode, 'left')
    
      ei = si + patchSize - 1;
      ej = sj + overlap - 1;
     
    elseif strcmp(mode, 'corner')
   
      ei = si + overlap - 1;
      ej = sj + overlap - 1; 
      
    end

    %The best one
    block_slice = texture(si:ei, sj:ej, :);
    
    constraint1 = sum((M_slice(:) - block_slice(:)).^2);
    
    if bool
    
      tar_block = tar_g((i - 1) * patchSize + 1:i * patchSize, (j - 1) * patchSize + 1:j * patchSize);
      tex_block = tex_g(si:si + patchSize - 1, sj:sj + patchSize - 1, :);
      constraint2 = sum(tex_block(:) - tar_block(:)).^2;
      
    else
    
      constraint2 = 0;
    
    end
    
    %Final error for our block
    errors(x, y) = constraint1 * alpha + constraint2 * (1 - alpha);
  
  end
end

end