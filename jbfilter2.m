%{
% JBFILTER2 Two dimensional Joint bilateral filtering.
%    This function implements 2-D bilateral filtering using
%    the method outlined in, however with weights calculated according
%    to another image. 
%
%       C. Tomasi and R. Manduchi. Bilateral Filtering for 
%       Gray and Color Images. In Proceedings of the IEEE 
%       International Conference on Computer Vision, 1998. 
%
%    B = jbfilter2(D,C,W,SIGMA) performs 2-D bilateral filtering
%    for the grayscale or color image A. D should be a double
%    precision matrix of size NxMx1 (i.e., grayscale) 
%    with normalized values in the closed interval [0,1]. 
%    C should be similar to D, from which the weights are 
%    calculated, with normalized values in the closed 
%    interval [0,1].  The half-size of the Gaussian
%    bilateral filter window is defined by W. The standard
%    deviations of the bilateral filter are given by SIGMA,
%    where the spatial-domain standard deviation is given by
%    SIGMA(1) and the intensity-domain standard deviation is
%    given by SIGMA(2).
%
% Based on the code from Douglas R. Lanman, Brown University, September 2006.
%
% Varuna De Silva, University of Surrey, May 2010
% varunax@gmail.com


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pre-process input and select appropriate filter.
function B = jbfilter2(D,C,w,sigma)

% Verify that the input image exists and is valid.
if ~exist('D','var') || isempty(D)
   error('Input image D is undefined or invalid.');
end
if ~isfloat(D) || ~sum([1,3] == size(D,3)) || ...
      min(D(:)) < 0 || max(D(:)) > 1
   error(['Input image D must be a double precision ',...
          'matrix of size NxMx1 or NxMx3 on the closed ',...
          'interval [0,1].']);      
end

% Verify bilateral filter window size.
if ~exist('w','var') || isempty(w) || ...
      numel(w) ~= 1 || w < 1
   w = 5;
end
w = ceil(w);

% Verify bilateral filter standard deviations.
if ~exist('sigma','var') || isempty(sigma) || ...
      numel(sigma) ~= 2 || sigma(1) <= 0 || sigma(2) <= 0
   sigma = [3 0.1];
end

% Apply either grayscale or color bilateral filtering.
if size(D,3) == 1
   B = jbfltGray(D,C,w,sigma(1),sigma(2));
else
   B = jbfltGray(D,C,w,sigma(1),sigma(2));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Implements bilateral filtering for grayscale images.
function B = jbfltGray(D,C,w,sigma_d,sigma_r)

% Pre-compute Gaussian distance weights.
[X,Y] = meshgrid(-w:w,-w:w);
G = exp(-(X.^2+Y.^2)/(2*sigma_d^2));

% Create waitbar.
%h = waitbar(0,'Applying bilateral filter on gray image...');
%set(h,'Name','Bilateral Filter Progress');

% Apply bilateral filter.
dim = size(D);
B = zeros(dim);
for i = 1:dim(1)
   for j = 1:dim(2)
      
         % Extract local region.
         iMin = max(i-w,1);
         iMax = min(i+w,dim(1));
         jMin = max(j-w,1);
         jMax = min(j+w,dim(2));
         I = D(iMin:iMax,jMin:jMax);
         
         % To compute weights from the color image
         J = C(iMin:iMax,jMin:jMax);
      
         % Compute Gaussian intensity weights according to the color image
         H = exp(-(J-C(i,j)).^2/(2*sigma_r^2));
      
         % Calculate bilateral filter response.
         F = H.*G((iMin:iMax)-i+w+1,(jMin:jMax)-j+w+1);
         B(i,j) = sum(F(:).*I(:))/sum(F(:));
               
   end
   %waitbar(i/dim(1));
end

% Close waitbar.
%close(h);
%}

function img_out = jbfilter2(image1, image2, n, sigma1, sigma2)
%bfilter2 function: perfrom two dimensional bilateral gaussian filtering.
%The standard deviations of the bilateral filter are given by sigma1 and
%sigma2, where the standard deviation of spatial-domain is given by sigma1
% and the standard deviation intensity-domain is given by sigma2.
%This function presents both bilateral filter and joint-bilateral filter.
%If you use the same image as image1 and image2, it is the normal bilateral
%filter; however, if you use different images in image1 and image2, you can
%use it as joint-bilateral filter, where the intensity-domain (range weight)
%calculations are performed using image2 and the spatial-domain (space weight)
%calculations are performed using image1.

%Usage:
%   %Example1: normal bilateral filter using 5x5 kernel, spatial-sigma=6, and
%   %intensity-sigma= 0.25:
%   image=bfilter2(I1,I1,5,1.2,0.25);
%   %Example2: joint-bilateral filter using 5x5 kernel, spatial-sigma=1.2,
%   %and range-sigma= 0.25, the spatial-domain calculations are performed
%   %using image (I1) and the intensity-domain calulcations (range weight)
%   %are performed using image (I2):
%   image=bfilter2(I1,I2,5,1.2,0.25);
%   %Example3: use the default values for n, sigma1, and sigma2
%   image=bfilter2(I1);

%Input:
%   -image1: the spatial-domain image
%   -image2: the intensity-domain (range weight) image (use the same image
%   for the normal bilateral filter. Use different images for joint-bilateral
%   filter.
%   (default, use the same image; i.e. image2=image1)
%   -n: kernel (window) size [nxn], should be odd number (default=5)
%   -sigma1: the standard deviation of spatial-domain (default=1.2)
%   sigma2: the standard deviation of intensity-domain (default=0.25)

%Author: Mahmoud Afifi, York University. 

%argument's check
if nargin<1
    error('Too few input arguments');
elseif nargin<2
    image2=image1;
    n=5;
    sigma1=1.2;
    sigma2=0.25;
elseif nargin<3
    n=5;
    sigma1=1.2;
    sigma2=0.25;
elseif nargin<4
    sigma1=1.2;
    sigma2=0.25;
elseif nargin<5
    sigma2=0.25;
end

%kernel size check
if mod(n,2)==0
    error('Please use odd number for kernel size');
end
%dimensionality check
if size(image1,1)~=size(image2,1) || size(image1,2)~=size(image2,2) || ...
        size(image1,3)~=size(image2,3)
    error('Both images should have the same dimensions and number of color channels');
end


display('processing...');

w=floor(n/2);

% spatial-domain weights.
[X,Y] = meshgrid(-w:w,-w:w);
gs = exp(-(X.^2+Y.^2)/(2*sigma1^2));

%normalize images
if isa(image1,'uint8')==1
    image1=double(image1)/255;
end

if isa(image2,'uint8')==1
    image2=double(image2)/255;
end

%intialize img_out
img_out=zeros(size(image1,1),size(image1,2),size(image1,3));
%padd both iamges
image1=padarray(image1,[w w],'replicate','both');
image2=padarray(image2,[w w],'replicate','both');
for i=ceil(n/2):size(image1,1)-w
    for j=ceil(n/2):size(image1,2)-w
        patch1(:,:,:)=image1(i-w:i+w,j-w:j+w,:);
        patch2(:,:,:)=image2(i-w:i+w,j-w:j+w,:);
        d=(repmat(image2(i,j,:),[n,n])-patch2).^2;
        % intensity-domain weights. (range weights)
        gr=exp(-(d)/(2*sigma2^2));
        for c=1:size(image1,3)
            g(:,:,c)=gs.*gr(:,:,c); %bilateral filter
            normfactor=1/sum(sum(g(:,:,c))); %normalization factor
            %apply equation:
            %out[i]=normfactor*sum (kernel * image)
            img_out(i-ceil(n/2)+1,j-ceil(n/2)+1,c)=...
                sum(sum(g(:,:,c).*patch1(:,:,c)))*normfactor;
         %   imshow(img_out,[]);
        end
        
    end
end
img_out=uint8(img_out*255);
end