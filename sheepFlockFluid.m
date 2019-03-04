function [out] = sheepFlockFluid(v,fieldSmooth,globalRegistration)
%SHEEPFLOCKFLUID Calculates displacements using image registration
%Based on imregdemons (Matlab built-in, R2014b).
%
%   Input:
%   v - movie structure, returned by VideoReader
%   fieldSmooth (optional) - positive number, amount of blurring; default: 10
%   globalRegistration (optional) - true/false; if true, performs global
%   registration before calculating local registration
%
%   Output:
%   out.dx - x displacements
%   out.dy - y displacements
%   out.div - divergence field
%   out.cav - vorticity (angular velocity) field
%   out.param - analysis parameters
%
%   Note:
%   Attributes displacements between frame n+1 and n to frame n.
%   The last frame is NaN, rather than the first one, since last frame is
%   more easily discarded.
%
% RS, 01/03/2019

if nargin == 1
    fieldSmooth = 3;
    globalRegistration = false;
elseif nargin == 2
    globalRegistration = false;    
end

% if globalRegistration requested, calculate configuration for monomodal
% (similar brightness and contrast) images
if globalRegistration
    [optimizer,metric] = imregconfig('monomodal');
end

% number of frames
nFrames = v.NumberOfFrames;

% initialize with NaN
dx = NaN(v.Width,v.Height,nFrames);
dy = dx;
div = dx;
cav = dx;

% calculate local displacements
for i = 1:nFrames-1
    
    fixed = rgb2gray(read(v,i));
    moving = rgb2gray(read(v,i+1));
    
    if globalRegistration
        moving = imregister(moving,fixed,'rigid',optimizer,metric);
    end

    D = imregdemons(moving,fixed,'AccumulatedFieldSmoothing',fieldSmooth,'DisplayWaitbar',0);
    
    dx(:,:,i) = D(:,:,1);
    dy(:,:,i) = D(:,:,2);
    div(:,:,i) = divergence(dx(:,:,i),dy(:,:,i));
    [~,cav(:,:,i)] = curl(dx(:,:,i),dy(:,:,i));
    
    w = waitbar(i/nFrames);
    
end

close(w)

% returns
out.dx = dx;
out.dy = dy;
out.div = div;
out.cav = cav;
out.param.fieldSmooth = fieldSmooth;
out.param.globalRegistration = globalRegistration;


end

