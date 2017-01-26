function [ Is ] = gradient_size( i3 )
%GRADIENT_SIZE return the absolute size of sobel gradient in every point of
%the picture

i3=double(i3);%convert image to double to accumolate for negative values
soby=fspecial('sobel');% create sobel 3 by 3 filter
sobx=soby';
%-------------------------------------------------------------------

Dy=imfilter(i3,sobx);%x first derivative  sobel mask

Dx=imfilter(i3,soby);


Is=(Dy.^2+Dx.^2).^0.5;
%--------------------show the image-----------------------------------------------

%imshow(Is,[]);% the ,[]  make sure the display will be feeted to doube image
%colormap jet
%colorbar
%pause;
end

