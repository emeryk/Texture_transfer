close all
clear

pkg load image;

S = imread('S14.jpg');
S = im2double(S);

patchSize = 9;

T = imread('globe_tgt.jpg');
T = im2double(T);

Sg = rgb2gray(S)<0.1;
Tg = rgb2gray(T)<0.05;

figure(1)
imshow(Sg)

figure(2)
imshow(Tg)

Final = zeros(size(T, 1), size(T, 2), 3);

alpha = 0.5; %Tolérance, à tester différentes valeurs

 

for (i=floor(patchSize/2)+1:patchSize:size(T,1)-floor(patchSize/2))

  for (j=floor(patchSize/2)+1:patchSize:size(T,2)-floor(patchSize/2))
  
    patchA = T(i-floor(patchSize/2):i+floor(patchSize/2), j-floor(patchSize/2):j+floor(patchSize/2),:);
    
    %Find best Patch with SSD
    
    bestSSD = intmax;
    bestX = 0;
    bestY = 0;
    for (x=1+floor(patchSize/2):size(S,1)-floor(patchSize/2))
    
      for (y=1+floor(patchSize/2):size(S,1)-floor(patchSize/2))     
      
        patchB = S(x-floor(patchSize/2):x+floor(patchSize/2), y-floor(patchSize/2):y+floor(patchSize/2),:);
        
        ssd = SSD(patchA, patchB);
        if (ssd < bestSSD)
          bestSSD = ssd;
          bestX = x;
          bestY = y;
        end
      
      end
    
    end
    
    %création de nos 4 patchs pur la formule magique
    
    patchB = S(bestX-floor(patchSize/2):bestX+floor(patchSize/2), bestY-floor(patchSize/2):bestY+floor(patchSize/2),:);
    
    patchC = Sg(bestX-floor(patchSize/2):bestX+floor(patchSize/2), bestY-floor(patchSize/2):bestY+floor(patchSize/2),:);
    
    patchD = Tg(i-floor(patchSize/2):i+floor(patchSize/2), j-floor(patchSize/2):j+floor(patchSize/2),:);
    
    patchFinal = alpha * (patchA - patchD).^2 + (1 - alpha) * (patchB - patchC).^2;
    
    %Copie du patch dans notre image finale
    
    tmpX = 1;
    tmpY = 1;
    
    for (f1=i-floor(patchSize/2):i+floor(patchSize/2))
    
      for (f2=j-floor(patchSize/2):j+floor(patchSize/2))
      
        Final(f1,f2,:) = patchFinal(tmpX, tmpY,:);
        tmpY += 1;
      
      end
      tmpX += 1;
      tmpY = 1;
    
    end
  
  end

end
    
figure(3)
imshow(Final)

%Test avec rgb2gray ?
%Map correspondance

%Application formule 
% e(i,j) = alpha * (patch1(i,j) - patch2(i,j)).^2 + (1 - alpha) * (sourceCoressMap(u,v) - targetCoressMap(i,j)).^2