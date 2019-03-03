function [out] = sheepFlockBoundaries(v,blurSigma)
%SHEEPFLOCKBOUNDARIES Returns flock boundaries by brightness detection
%after blurring.
%   Input:
%   v - movie structure, returned by VideoReader
%   blurSigma (optional) - positive number, amount of blurring; default:
%   10; if 0, no blurring
%
%   Output:
%   out.b - cell array of boundaries in each frames
%   out.param - analysis parameters
%
% RS, 01/03/2019

if nargin == 1
    blurSigma = 10;
end

% number of frames
nFrames = v.NumberOfFrames;

% blur, binarize, calculate boundaries, for each frame
b = cell(1,nFrames);

for i = 1:nFrames
    
    frame = read(v,i);
    frame = rgb2gray(frame);
    if blurSigma > 0
        frame = imgaussfilt(frame,blurSigma);
    end
    bw = imbinarize(frame);
    b{i} = bwboundaries(bw,'noholes');
    
end

% returns
out.b = b;
out.param.blurSigma = blurSigma;


end

