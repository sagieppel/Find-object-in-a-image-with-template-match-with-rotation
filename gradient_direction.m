function [ Is ] = gradient_direction( i3 )

%GRADIENT_direction return the absolute direction from -pi/2 to pi/2 sobel
%gradient in every point of the gradient (only half circle does not have
%negative directionss
%the picture

i3=double(i3);%convert image to double to accumolate for negative values
%-------------------------------------------------------------------
Dy=imfilter(i3,[1; -1],'same');%x first derivative  sobel mask
Dx=imfilter(i3,[1  -1],'same');% y sobel first derivative
%Is=atan2(Dy,Dx)+pi();
Is=mod(atan2(Dy,Dx)+pi(), pi());%atan(Dy/Dx);%note that this expression can reach infinity if dx is zero mathlab aparently get over it but you can use the folowing expression instead slower but safer: 
%mod(atan2(Dy,Dx)+pi(), pi());%gradient direction map going from 0-180
%--------------------show the image-----------------------------------------------
%{
imshow(Is,[]);% the ,[]  make sure the display will be feeted to doube image
colormap jet
colorbar
pause;
%}
end