%Fonction SSD

function [res] = SSD (patch1, patch2)

res = sum(sum(sum((patch1 - patch2).^2)));

end
