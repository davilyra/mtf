%{
FilmXProjCalc.m

Last updated: 06/17/2009

written by Anya Grosberg
Disease Biophysics Group
School of Engineering and Applied Sciences
Havard University, Cambridge, MA 02138

The purpose of this code is to calculate the "x" projection of the films in hMTF

Input: 
    frames = The number of frames in the stack
    XX = The height in pixels
    YY = The width in pixels
    cmlength = The scale of the images (the number of pixels/meter)
    filename2 = The name of the file with the frames to be analyzed
        
Output: 
%}
function [xProjPix,xProjMet]=FilmXPorjCalc_Multi(frames,XX,YY,cmlength,filename2,num_films,FilmLoc)

% initialize image stack array
data = zeros(XX,YY,frames,'int8'); % preallocate 4-D array -- prodduces HeightxWidth for each frame

% load in image stack
disp('Loading image stack...')
%Cycle through each frame to load it into the data array
for frame=1:frames
    [data(:,:,frame)] = imread(filename2,'tif',frame); %load each frame separately
end


%conver indexes to integers
FilmLocIndex = cast(FilmLoc,'int16');
%Inverse as white pixels are ones
data_inv=cast((~data),'int8'); %make inverse of data
length_data_columns(:,:) = sum(data_inv,1); %calculate the total number of white pixels in each column
%cycle trhough each film to find the average length
%prelocate space for the xProjPix
xProjPix = zeros(num_films,frames,'double'); %number of films x number of frames
for i=1:num_films
    %the x-projection is the mean of the total number of pixels in each
    %column minus the height of the base
    xProjPix(i,:)=mean(length_data_columns(FilmLocIndex(1,i):FilmLocIndex(2,i),:),1) - FilmLoc(3,i);
end
%Convert lengths to meters
xProjMet=xProjPix./cmlength;

end
    
