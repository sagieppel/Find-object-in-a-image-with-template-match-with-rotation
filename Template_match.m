
function [score,  y, x ]=Template_match(Is,Itm,CorlType,Edge_Type,Itm_dilation)
%{
Find  templae Itm (binary) image Is (GreyScale).
Return y,x coordinates of the best match and its score
the Edge_Type parameter determine the type of image to which the template will be matched (edge, gradient, greyscale). 
Edge_Type='sobel': Template Itm will be matched (cross-correlated) to the  to  'sobel'  gradient map of the image Is.
Edge_Type='canny':  Template Itm will be matched (cross-correlated) to the  to  'canny'  binary edge map  of the image Is (default).
Else Template Itm will be matched (crosscorrelated) to the  greyscale version of the image Is.

Itm_dilation: The amount of dilation for of the template. How much the template line will be thickened  (in pixels) for each side before crosscorelated with the image. 
 The thicker the template the better its chance to overlap with edge of object in the image and more rigid the recognition process, however thick template can also reduce recognition accuracy. 
The default value for this parameter is 1/40 of the average dimension size of the template Itm.

CorlType='full': Use negative template (negative correlation) around the template contour line (in small radious around the template line) for both the inside and outside of the template. Crosscorrelation of this areas with edges in the canny image will reduce the match score of the template in this location (default).
CorlType='none': Use the template as it is.
%}
%==========================================intialize optional paramters=================================================================================================================
if (nargin<3)
CorlType='full';% determine the negative correlation betweem the vessel template and the system edge to avoid the condition in which the vessel will have high false positive in dnse border areas 'full' mean create negative on the inside and out side border of the vessel, 'out' mean create negative correlation only on the out side of the vessel 'none' mean create no negative correlation
end;
if (nargin<4)
Edge_Type='canny';% determine the type of edge use in the system image canny(black and white) sobel (absolute gradient value from 1-2000) , or 'none' if the system image is already edge image
end;
if (nargin<5)
    Sitm=size(Itm);
Itm_dilation=floor(sqrt(Sitm(1)*Sitm(2))/80);% in order to avoid the edge from missing correct point by dilation the size of dilation is proportinal to the size of the item template dimension.
%tm_dilation=2
end;
%===================================================Prepare template=======================================================================================================================
%---------------------DILATE Template-------------------------------------------------------------------------------------------------------------------------------------------------
%%it might be that the border will be  tin to be idenified by single  edge
%dilution of the template will prevent it from being miss
It=double(Itm);
for f=1:1:Itm_dilation 
    It=dilate(It);%DILATE Template
end

%==============================prepare areas of negative crosscorrelation in the template (areas were the template value is negative)
%------------------------------we want both side of the edge to be empty so we can  avoid  getting false positive in noisy areas -------------------------------

if (strcmp(CorlType,'full'))
   Id=dilate(It);
    for f=1:1:Itm_dilation*2-1
        Id=dilate(Id);
    end
   NegWeight=0.5;
   Im=It*(1+NegWeight)-Id*NegWeight;

%---------------alternative to wanting both side of the edge to be empty we can want only the out side of the edge to be empty (assumping Itm is closed contour)-----------------------------------------------------------------------
elseif (strcmp(CorlType,'out'))   
    If=imfill(It,4,'holes');
    Ifd=dilate(If);
    for f=1:1:Itm_dilation*2-1
        Ifd=dilate(Ifd);
    end
    If=Ifd-If;
    Im=double(It-If);
else
%--------------------------no action use the vessel template as it is---------------------------------------------------------------------------------------------
    Im=double(It);
end;
%==================================================Prepare image======================================================================================== 
%----------------------------------------Transform image to canny edge map or sobel gradient map (absolute)--------------------------------------------------------------------------------------------------------
if (strcmp(Edge_Type,'canny'))
    Iedg=edge(Is,'canny');%,[highthresh/3,highthresh],1.1);
    Iedg=double(Iedg);
elseif (strcmp(Edge_Type,'sobel'))
    Iedg=gradient_size(Is);
    Iedg=double(Iedg);
end
%imtool(Iedg);

%==============================================Search for template in the image===============================================================================================
%------------------------------------------------------------------------------filter-----------------------------------------------------------------------------------------------------

Itr=imfilter(Iedg,Im,'same');%use filter/kernal to scan the cross correlation of the image Iedg to the template and give match of the cross corelation scoe for each pixel in the image
%---------------------------------------------------------------------------normalized according to template size (fraction of the template points that was found)------------------------------------------------------------------------------------------------
Itr=Itr./sqrt(sum(sum(Itm)));% normalize score match by the number of pixels in the template to avoid biase toward large template
%---------------------------------------------------------------------------find the location best match
mx=max(max(Itr));
[y,x]=find(Itr==mx,  1, 'first'); % find the location first 10 best matches which their score is at least thresh percents of the maximal score and put them in the x,y array
score=zeros(size(y));
ss=size(Itm);
 

   score=Itr(y(1),x(1));
   y(1)=round(y(1)-ss(1)/2);% normalize the location of the cordinate to so it will point on the edge of the image and not its center
   x(1)=round(x(1)-ss(2)/2);
%====================================For display only mark the ves result on the image=======================================================================
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%DILATE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55
% dilate binary image bw
function bw2=dilate(bw)
bw2=imdilate(bw,strel('square',3));%dilate image
end