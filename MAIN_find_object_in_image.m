function [Ismarked,Iborders,Ybest,Xbest, ItmAnf, BestScore]= MAIN_find_object_in_image(Is,Itm,Search_Mode,Edge_Type,Itm_dilation,CorlType)
%{
Find an object that fit Template Itm in image Is.
The orientation of the template and the object in the image does not have to be the same as that as the template. 
The template Itm is matched to the image Is in various of rotations and the best match is chosen.
The function can use various of methods to trace the template in the image, 
including: Generalized Hough transforms, Normalize crosscorrelation to edge image and other forms of template match.

Input (Essential):
Is: Color image with the object to be found.
Itm: Template of the object to be found. The template is written as binary image with the boundary of the template marked 1(white) and all the rest of the pixels marked 0. 
Template of object Itm could be created by extracting the object boundary in image with uniform background, 
this could be done (for symmetric objects) using the code at: http://www.mathworks.com/matlabcentral/fileexchange/46887-find-boundary-of-symmetric-object-in-image

Input (Optional):
Search_Mode: The method by which template Itm will be searched in image Is: 
Search_Mode='hough': use generalized hough transform to scan for template. 
Search_Mode='template': use cross-correlation to scan for template in the image (default). 

Edge_Type: Only in case of  search_mode='template', 
the Edge_Type parameter determine the type of image to which the template will be matched (edge, gradient, greyscale). 
Edge_Type='sobel': Template Itm will be matched (cross-correlated) to the  to  'sobel'  gradient map of the image Is.
Edge_Type='canny':  Template Itm will be matched (cross-correlated) to the  to  'canny'  binary edge map  of the image Is (default).
Else Template Itm will be matched (crosscorrelated) to the  greyscale version of the image Is.

Itm_dilation: The amount of dilation for of the template. How much the template line will be thickened  (in pixels) for each side before crosscorelated with the image. 
 The thicker the template the better its chance to overlap with edge of object in the image and more rigid the recognition process, however thick template can also reduce recognition accuracy. 
The default value for this parameter is 1/40 of the average dimension size of the template Itm.

CorlType: Only in case of  search_mode='template'. Matching the template to the edge image is likely to give high score in any place in the image with high edge density which  can give high false positive, to avoid this few possible template match option are available: 
CorlType='full': Use negative template (negative correlation) around the template Itm line  and positve on the template(in small radious around the template line) for both the inside and outside of the template. Crosscorrelation of this areas with edges in the canny image will reduce the match score of the template in this location (default).
CorlType='out': Use positve crosscorrelation on the template and negativeout side the template (assume the template Itm is closed contour
CorlType='none': Use the simple cross correlation with the template template as it is.

Output
Ismarked: The image (Isresize) with the template marked upon it in the location of and size of the best match.
Iborders: Binary image of the borders of the template/object in its scale and located in the place of the best match on the image. 
Ybest Xbest: location on the image (in pixels) were the template were found to give the best score (location the top left pixel of the template Itm in the image).
ItmAng: The rotation angle of  the template in degrees that give the best match
BestScore: Score of the best match found in the scan (the score of the output).

Algorithm:
The function rotate the template Itm in various of angles and for each rotation search for the template in the image. 
The angle and location in the image that gave the best match for the template are chosen.


%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%initialize optiona paramters%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (nargin<1)  Is=imread('Is.jpg');  end; %Read image
if (nargin<2)  Itm=imread('Itm.tif');end; %Read template image
if (nargin<3)    Search_Mode='template'; end;%method by which the template will be searche in the image (altrnative 'hough');
if (nargin<4)    Edge_Type='canny'; end;%'sobel';% type of image in which the template will be matched to could (canny edge image is the best
if (nargin<5) 
    Sitm=size(Itm);
    Itm_dilation=floor(sqrt(Sitm(1)*Sitm(2))/80); % dilation level of the template. 
    %In order to avoid the edge from missing correct point by dilation the size of dilation is proportinal to the size of the item template dimension.
end;
if (nargin<6) CorlType='full'; end;%type areas of crosscorrelation and negative crosscorrelation (negative template) around the original template
Is=rgb2gray(Is);
Itm=logical(Itm);% make sure Itm is boolean image
BestScore=-100000;
close all;
imtool close all;
%%%%%%%%%%%%%%%%Some parameters%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%555555555
St=size(Itm);
Ss=size(Is);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Main Scan  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for Ang=1:1:360 % rotate the template Itm 1 degree at the time and look for it in the image Is
    
    disp([num2str((Ang)/3.6) '% Scanned']);
  Itr=Rotate_binary_edge_image(Itm,Ang);
%----------------------------------------------------------------------------------------------------------------------------------------- 
 % the actuall recogniton step of the resize template Itm in the orginal image Is and return location of best match and its score can occur in one of three modes given in search_mode
     if strcmp(Search_Mode,'template')% the actuall recogniton step of the template in the resize image and return location of best match and its score can occur in one of three mode
             [score,  y,x ]=Template_match(Is,Itr,CorlType,Edge_Type,Itm_dilation); %apply template matching here and return list of good points (x,y) and their scoring
     elseif strcmp(Search_Mode,'hough')
            [score,  y,x ]=Generalized_hough_transform(Is,Itr);% use generalized hough transform to find the template in the image
     end;
     %--------------------------if the correct match score is better then previous best match write the paramter of the match as the new best match------------------------------------------------------
     if (score(1)>BestScore) % if item  result scored higher then the previous result
           BestScore=score(1);% remember best score
             Ybest=y(1);% mark best location y
           Xbest=x(1);% mark best location x
           ItmAng=Ang;
     end;
%-------------------------------mark best found location on image----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------        
end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%output%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%show   best match optional part can be removed %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if BestScore>-100000% Display best match
     Itr=Rotate_binary_edge_image(Itm,ItmAng);
            [yy,xx] =find(Itr);
             Ismarked=set2(Is,[yy,xx],255,Ybest,Xbest);%Mark best match on image
            imshow(Ismarked);
            Iborders=logical(zeros(size(Is)));
       Iborders=set2(Iborders,[yy,xx],1,Ybest,Xbest);
   
else % if no match 
   disp('Error no match founded');
    Ismarked=0;% assign arbitary value to avoid 
       Iborders=0;
       Iborders=0;
    
end;
end