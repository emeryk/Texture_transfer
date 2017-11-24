close all
clear

pkg load image;

S = imread("nicho.jpg");
S = im2double(S);

patchSize = 50;
overlapSize = floor(patchSize / 5);

T = imread("lave.jpg");
T = im2double(T);

n = size(T, 1);
m = size(T, 2);

%Gestion des bords
%Ajout de bords en noir