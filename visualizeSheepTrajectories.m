function [ ] = visualizeSheepTrajectories(sheepTracks,minEnd2End,frameRange,frame)
%VISUALIZESHEEPTRAJECTORIES Displays sheep trajectories from trackSheep
%
%   Input:
%   sheepTracks - sheep trajectories, from trackSheep
%   minEnd2End (optional) - min end-to-end distance of trajectories to be
%   plotted
%   frameRange (optional) - [first frame, last frame], only display
%   trajectory portions in between these two frames
%   frame (optional) - frame to overlay trajectories to
%
%   Note: display all trajectories, but sets portions outside of frameRange
%   to total transparency.
%
% RS, 2019/03/01

% number of frames in movie
nFrames = 1773;

if nargin < 2
    minEnd2End = 5;
end

if nargin < 3
    frameRange = [1 nFrames];
end

h = figure;
set(h,'Color','w')

if nargin == 4
    imshow(frame)
    hold on
end 

f = find(sheepTracks.trajEnd2End >= minEnd2End);

for i=f
    
    p = sheepTracks.trajObject{i};
    
    patch([p(:,1); NaN],[p(:,2);NaN],[p(:,3);NaN]/nFrames,...
        'EdgeColor','interp',...
        'FaceVertexAlphaData',double(vertcat(p(:,3),NaN) >= frameRange(1) & vertcat(p(:,3),NaN) <= frameRange(2)),...
        'AlphaDataMapping','none',...
        'EdgeAlpha','interp');
    
    hold on
    
end

axis ij equal 
box on
colormap parula

end

