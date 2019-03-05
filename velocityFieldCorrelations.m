function [out] = velocityFieldCorrelations(dxdy,nFrameAvg,frameMax,wx,wy)
%VELOCITYFIELDCORRELATIONS Correlations in field velocities
%Based on xcorr2 (Matlab built-in).
%
%   Input:
%   dxdy - displacements field, returned from sheepFlockFluid
%   nFrameAvg (optional) - averages displacements over n frames; default: 3
%   frameMax (optional) - correlations in each frame until frameMax
%   wx, wy (optional) - coordinates of frame window to analyze
%
%   Output:
%   out.Cvv - matrix of correlations (distance,frame), averaged over bins
%   out.R - bin centers (i.e. row coordinates)
%   out.frames - frame numbers (i.e. column coordinates)
%   out.c0 - Cvv(0)
%   out.param - analysis parameters
%
% RS, 01/03/2019

if nargin == 3
    wx = 250:480;
    wy = 100:330;
elseif nargin == 2
    wx = 250:480;
    wy = 100:330;
    frameMax = size(dxdy.dx,3)-1;
elseif nargin == 1
    wx = 250:480;
    wy = 100:330;
    frameMax = size(dxdy.dx,3)-1;
    nFrameAvg = 3;
end

dx = dxdy.dx(wx,wy,:);
dy = dxdy.dy(wx,wy,:);

% matrix of distances
A = xcorr2(dx(:,:,1));
A = double((A == max(A(:))));
rij = bwdist(A);

% bins
Rmax = floor(0.9*max(length(wx),length(wy)));
R = 0:Rmax;
R = R(:);

% frames
frames = 1:nFrameAvg:frameMax;
idx = 1;

for i = frames
    
    dX = mean(dx(:,:,i:i+nFrameAvg-1),3,'omitnan');
    dY = mean(dy(:,:,i:i+nFrameAvg-1),3,'omitnan');
    
    Ci = frameCvv(dX,dY,rij,R);
    
    Cvv(:,idx) = Ci.Cvv;    
    c0(idx) = Ci.c0;
    
    idx = idx+1;
    
    w = waitbar(i/frameMax);
    
end

close(w)

% returns
out.Cvv = Cvv;
out.R = 0.5*(R(1:end-1)+R(2:end));
out.frames = frames;
out.c0 = c0;
out.param.nFrameAvg = nFrameAvg;
out.param.frameMax = frameMax;

end



function [out] = frameCvv(dx,dy,rij,R)
%FRAMECVV Calculate field velocity correlations Cvv in one frame.

% all correlation points
cij = xcorr2(dx) + xcorr2(dy);
c0 = max(cij(:));

% binning
Cvv = splitapply(@mean,cij(:)/c0,discretize(rij(:),R(:)));

% returns
out.cij = cij(:);
out.rij = rij(:);
out.c0 = c0;

out.Cvv = Cvv;
out.R = 0.5*(R(1:end-1)+R(2:end));

end

