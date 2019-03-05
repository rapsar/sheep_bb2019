function [ out ] = trackSheep(v,blurSigma,trackRadius,maxAreaThreshold,minIntensityThreshold)
%TRACKSHEEP Tracks sheep in all frames and connects trajectories.
%Based on imregionalmax (Matlab built-in) and trackDLB.m by Crocker, Blair 
%and Dufresne, available at http://site.physics.georgetown.edu/matlab/code.html
%(renamed 'trackDLB' because 'track' is Matlab built-in)
%
%   Input:
%   v - movie structure, returned by VideoReader
%   blurSigma (optional) - positive number, blurring; default: 0.5
%   trackRadius (optional) - maximum distance between two trajectory
%   positions between two frames; max possible value depends on blurSigma,
%   but should be no larger than 4; will stop if too large
%   maxAreaThreshold (optional) - maximum size of local maximum to be
%   considered a 'sheep'; typically 2
%   minIntensityThreshold (optional) - removes local maxima that are not
%   bright enough; can be a scalar, or string 'variable'; if 'variable'
%   will set a different threshold in each frame based on graythresh; if
%   left empty, will use a glabal threshold based on graythresh in the
%   first frame
%
%   Output:
%   out.tracks - returned by trackDLM; array with column: x y t trajID
%   out.trajObject - cell array of all trajectories; each cell has: x y t
%   out.trajLength - array of trajectory lengths (in frames)
%   out.trajEnd2End - array of trajectory end-to-end distances
%   out.param - analysis parameters
%
%   TO-DO: use assignin to save after detection, and be able to plug that
%   back in
%
% RS, 2019/03/01

if nargin < 5
    im1 = rgb2gray(read(v,1));
    minIntensityThreshold = graythresh(im1)*max(im1(:));
end
if nargin < 4
    maxAreaThreshold = 2;
end
if nargin < 3
    trackRadius = 3;
end
if nargin < 2
    blurSigma = 0.5;
end

% number of frames
nFrames = v.NumberOfFrames;

% runs sheepFrameDetection for each frame
posFrame = cell(1,nFrames);

for i = 1:nFrames
    
    frame = read(v,i);
    
    if blurSigma > 0
        frame = imgaussfilt(frame,blurSigma);
    end
    
    if isscalar(minIntensityThreshold)
        p = sheepFrameDetection(frame,maxAreaThreshold,minIntensityThreshold);
    elseif strcmp(minIntensityThreshold,'variable')
        p = sheepFrameDetection(frame,maxAreaThreshold);
    end
    
    posFrame{i} = horzcat(p,repmat(i,size(p,1),1));
    
    w = waitbar(i/nFrames);
end

close(w)

% connects positions into trajectories
xyt = vertcat(posFrame{:});
xyti = trackDLB(xyt,trackRadius);

% sorts into individual trajectories
nObjects = max(xyti(:,end));
trajObject = cell(1,nObjects);
trajLength = zeros(1,nObjects);
trajEnd2End = zeros(1,nObjects);

for i = 1:nObjects
    
    obj = xyti(xyti(:,end) == i,1:3);
    trajObject{i} = obj;
    trajLength(i) = size(obj,1);
    trajEnd2End(i) = hypot(obj(1,1)-obj(end,1),obj(1,2)-obj(end,2));
    
    w = waitbar(i/nObjects);
    
end

close(w)

% returns
out.tracks = xyti;
out.trajObject = trajObject;
out.trajLength = trajLength;
out.trajEnd2End = trajEnd2End;

out.param.trackRadius = trackRadius;
out.param.blurSigma = blurSigma;
out.maxAreaThreshold = maxAreaThreshold;
out.minIntensityThreshold = minIntensityThreshold;


end

