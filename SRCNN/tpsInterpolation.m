function [imo,mask] = tpsInterpolation( im, ps, pd, varargin )
num_required_parameters = 3;

% initialize default parameters
[imh1,imw1,imc1] = size(int8(padarray(im, [1000 1000], 'replicate')));
r = 0.1*imw1;
imo = zeros(imh1,imw1,imc1);
mask = zeros(imh1,imw1);

% parse parameters
if nargin > num_required_parameters
    iVarargin = 1;
    while iVarargin <= nargin - num_required_parameters
        switch lower(varargin{iVarargin})
            case 'thin'
                method = 't';
            case 'gau'
                method = 'g';
                r = varargin{iVarargin+1};
                iVarargin = iVarargin + 1;
        end
        iVarargin = iVarargin + 1;
    end
end

%% Training w with L
nump = size(pd,1);
num_center = size(ps,1);
K=zeros(nump,num_center);

for i=1:num_center
    %Inverse warping from destination!
    dx = ones(nump,1)*ps(i,:)-pd; 
    K(:,i) = sum(dx.^2,2);
end

if( strcmpi(method,'g') )
    K = rbf(K,r);
elseif( strcmpi(method,'t') )
    K = ThinPlate(K);
end

% P = [1,xp,yp] where (xp,yp) are n landmark points (nx2)
P = [ones(num_center,1),pd];
% L = [ K  P;
%       P' 0 ]
L = [K,P;P',zeros(3,3)];
% Y = [x,y;
%      0,0]; (n+3)x2
Y = [ps;zeros(3,2)];
%w = inv(L)*Y;
w = L\Y;

%% Using w
[x,y] = meshgrid(1:imw1,1:imh1);
pt = [x(:), y(:)];

nump = size(pt,1);
Kp = zeros(nump,num_center);
for i=1:num_center
    dx = ones(nump,1)*ps(i,:)-pt;
    Kp(:,i) = sum(dx.^2,2);
end
if( strcmpi(method,'g') )
    Kp = rbf(Kp,r);
elseif( strcmpi(method,'t') )
    Kp = ThinPlate(Kp);    
end

L = [Kp,ones(nump,1),pt];
ptall = L*w;

%reshape to 2d image
xd = reshape( ptall(:,1),imh1,imw1 );
yd = reshape( ptall(:,2),imh1,imw1 );

for i = 1:imc1
    imt= interp2( single(im(:,:,i)),xd,yd,'linear');
    imo(:,:,i) = uint8(imt);
end


mask = ~isnan(imt);
end

function ko = rbf(d,r) 
    ko = exp(-d/r.^2);
end

function ko = ThinPlate(ri)
% k=(r^2) * log(r^2)
    r1i = ri;
    r1i((ri==0))=realmin; % Avoid log(0)=inf
    ko = (ri).*log(r1i);
end
