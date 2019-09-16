%{
MakeFilmEdgeMovie.m

Last updated: 04/15/2010
First written: 04/15/2010

written by Anya Grosberg
Disease Biophysics Group
School of Engineering and Applied Sciences
Havard University, Cambridge, MA 02138

The purpose of this code is to create a movie with the original hMTF and the x projections.


Input: The user is aksed for:
        1. Files containing the *.tif stacks of the original movie 
            (should have the same cropping as the analyzed images)
        Automatic input of:
        2. The "x" projection (which is the y coordinate on the picture)
        3.   and it's location (which is the x coordinate on the picture)
        4. The height and width in pixels
        5. The number of films
        6. Direcotry from which to look for the raw image
        
Output: .avi movie of combined images
%}

function MakeFilmEdgeMovie(FilmEdgePix,FilmLoc,FilmLengthPix,XX,YY,frames,num_films,base_path,base_filename,frame_rate,frame_step,start_frame,end_frame)

%ask the user for the original movie
%Ask the user for a single file
raw_rgb_filename=[base_path '\' base_filename '_raw_RGB.tif'];
filename6 = [base_filename '_FilmEdge'];
filename7 = [base_path '\' filename6];

if XX<max(FilmLengthPix)
    disp('Error: The length of the film is longer than crop area')
end

%seed image matrix
% initialize image stack array
raw_image_data = zeros(XX,YY,3,frames,'uint8'); % preallocate prodduces HeightxWidthx3(rgb) for each frame

% load in image stack
disp('Loading image stack...')
%Cycle through each frame to load it into the data array
for frame=1:frames
    [raw_image_data(:,:,:,frame)] = imread([raw_rgb_filename],'tif',frame); %load each frame separately
end

FilmLoc = cast(FilmLoc,'int16');

%specify line width in pixels
line_width = 4;
%for each film specify where the film is "located"
film_width = max(FilmLoc(1,:),FilmLoc(2,:))-min(FilmLoc(1,:),FilmLoc(2,:)); %the width of the film
%The height of each film +/- line width
xProjPixMat = cast(FilmEdgePix(:,:),'uint8');

h_line_str = XX.*ones(num_films,frames,'uint8')-xProjPixMat-line_width.*ones(num_films,frames,'uint8');
h_line_end = XX.*ones(num_films,frames,'uint8')-xProjPixMat+line_width.*ones(num_films,frames,'uint8');
OnePlaceHolder = ones(size(h_line_end),'uint8');
h_line_str(xProjPixMat <= line_width) = XX.*OnePlaceHolder(xProjPixMat <= line_width)-line_width.*OnePlaceHolder(xProjPixMat <= line_width);
h_line_end(xProjPixMat <= line_width) = XX.*OnePlaceHolder(xProjPixMat <= line_width);
if(min(min(FilmEdgePix)) <= line_width)
    disp('Warning: one of the films is not there for one of the frames');
end
%The start+1/4, end-1/4, and center of each film
w_line_str = min(FilmLoc(1,:),FilmLoc(2,:))+floor(0.25.*film_width);
w_line_end = max(FilmLoc(1,:),FilmLoc(2,:))-floor(0.25.*film_width);
center_film = min(FilmLoc(1,:),FilmLoc(2,:))+floor(0.5.*film_width);

%specify blue (initial image) line width in pixels
line_width_i = 1;
%The height of each film +/- line width
Top_line_str = floor((XX.*ones(num_films,1)-FilmLengthPix)-line_width_i.*ones(num_films,1));
Top_line_end = floor((XX.*ones(num_films,1)-FilmLengthPix)+line_width_i.*ones(num_films,1));
%The left line location
L_line = min(FilmLoc(1,:),FilmLoc(2,:));
%The right line location
R_line = max(FilmLoc(1,:),FilmLoc(2,:));

%%%%%%%%%%%%%%%%% Initial Image %%%%%%%%%%%%%%%%%%%%%%%%%%
%horizontal line
for j=1:num_films
    hls=Top_line_str(j)+1;
    hle=Top_line_end(j)+1;
    wls=L_line(j)+1;
    wle=R_line(j)+1;
    one_size = size(raw_image_data(hls:hle,wls:wle,3,:));
    zero_size = size(raw_image_data(hls:hle,wls:wle,1:2,:));
    raw_image_data(hls:hle,wls:wle,3,:)=255*ones(one_size);
    raw_image_data(hls:hle,wls:wle,1:2,:)=0.0.*ones(zero_size);
end
%vertical line left
for j=1:num_films
    hls=Top_line_str(j)+2;
    hle=XX;
    wls=L_line(j)-line_width_i;
    wle=L_line(j)+line_width_i;
    one_size = size(raw_image_data(hls:hle,wls:wle,3,:));
    zero_size = size(raw_image_data(hls:hle,wls:wle,1:2,:));
    raw_image_data(hls:hle,wls:wle,3,:)=255*ones(one_size);
    raw_image_data(hls:hle,wls:wle,1:2,:)=0.0.*ones(zero_size);
end
%vertical line Right
for j=1:num_films
    hls=Top_line_str(j)+2;
    hle=XX;
    wls=R_line(j)-line_width_i;
    wle=R_line(j)+line_width_i;
    one_size = size(raw_image_data(hls:hle,wls:wle,3,:));
    zero_size = size(raw_image_data(hls:hle,wls:wle,1:2,:));
    raw_image_data(hls:hle,wls:wle,3,:)=255*ones(one_size);
    raw_image_data(hls:hle,wls:wle,1:2,:)=0.0.*ones(zero_size);
end
%%%%%%%%%%%%%%%%% Initial Image %%%%%%%%%%%%%%%%%%%%%%%%%%

%for each frame and for each film insert a line at the edge and film outline, then write it
%to the file. If the frame_step is zero assume the movie is being made for
%a error check and compress it. Otherwise, assume it will be used in
%ImageJ, and specify no compression. Also adjust the frame rate
if frame_step == 1 %bug check
    disp(filename7);
    mov = avifile([filename7],'fps',frame_rate,'compression','Indeo3');
    
else
    apperent_frame_rate = frame_rate/frame_step;
    filename7afr = [filename7 '_fps_' num2str(apperent_frame_rate)];
    disp(filename7afr);
    mov = avifile(filename7afr,'fps',apperent_frame_rate,'compression','none');
    disp(['The apperent frame rate is: ', num2str(apperent_frame_rate)]);
end

for i=start_frame:frame_step:end_frame
    %%%%%%%%%%%%%%%%%%%% BARS %%%%%%%%%%%%%%%%%%%
    %horizontal line
    for j=1:num_films
        hls=h_line_str(j,i)+1;
        hle=h_line_end(j,i)+1;
        wls=w_line_str(j)+1;
        wle=w_line_end(j)+1;
        one_size = size(raw_image_data(hls:hle,wls:wle,2,i));
        zero_size1 = size(raw_image_data(hls:hle,wls:wle,1,i));
        zero_size3 = size(raw_image_data(hls:hle,wls:wle,3,i));
        raw_image_data(hls:hle,wls:wle,2,i)=255*ones(one_size);
        raw_image_data(hls:hle,wls:wle,1,i)=0.0.*ones(zero_size1);
        raw_image_data(hls:hle,wls:wle,3,i)=0.0.*ones(zero_size3);
    end
    %vertical line
    for j=1:num_films
        hls=h_line_str(j,i)+2;
        hle=XX;
        wls=center_film(j)-line_width;
        wle=center_film(j)+line_width;
        one_size = size(raw_image_data(hls:hle,wls:wle,2,i));
        zero_size1 = size(raw_image_data(hls:hle,wls:wle,1,i));
        zero_size3 = size(raw_image_data(hls:hle,wls:wle,3,i));
        raw_image_data(hls:hle,wls:wle,2,i)=255*ones(one_size);
        raw_image_data(hls:hle,wls:wle,1,i)=0.0.*ones(zero_size1);
        raw_image_data(hls:hle,wls:wle,3,i)=0.0.*ones(zero_size3);
    end
    %%%%%%%%%%%%%%%%%% BARS %%%%%%%%%%%%%%%%%%%%%%%%%%%%

    mov = addframe(mov,raw_image_data(:,:,:,i));   
end

mov=close(mov);
%{
for i=1:frames
    for j=1:num_films
        hls=h_line_str(j,i)+1;
        hle=h_line_end(j,i)+1;
        wls=w_line_str(j)+1;
        wle=w_line_end(j)+1;
        one_size = size(raw_image_data(hls:hle,wls:wle,1,i));
        zero_size = size(raw_image_data(hls:hle,wls:wle,2:3,i));
        raw_image_data(hls:hle,wls:wle,1,i)=0.0*ones(one_size);
        raw_image_data(hls:hle,wls:wle,2:3,i)=0.0.*ones(zero_size);
    end
    imwrite(raw_image_data(:,:,:,i),filename7,'tif','Compression','none','WriteMode','append','ColorSpace','rgb');    
end
%}
end