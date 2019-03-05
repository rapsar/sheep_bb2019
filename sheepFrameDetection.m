function [pos] = sheepFrameDetection(frame,maxAreaThreshold,minIntensityThreshold)
%SHEEPFRAMEDETECTION Localize "sheep" in a frame by finding local maxima
%Based on imregionalmax (Matlab built-in).
%Removes objects that are not small and bright.
%
% RS, 2019/03/01

if nargin == 1
    maxAreaThreshold = 2;
    minIntensityThreshold = graythresh(frame)*max(frame(:));   
elseif nargin == 2
    minIntensityThreshold = graythresh(frame)*max(frame(:));    
end

% converts to grayscale
fgs = rgb2gray(frame);

% finds local maxima
localMax = imregionalmax(fgs);

% maxima characteristics
rp = regionprops(localMax,fgs,'Centroid','Area','MeanIntensity');

% removes large objects
rp(vertcat(rp.Area) > maxAreaThreshold) = [];

% removes dark objects
rp(vertcat(rp.MeanIntensity) < minIntensityThreshold) = [];

% returns Nx2 array
pos = vertcat(rp.Centroid);


end

