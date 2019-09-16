%{
MakeFilmMovie.m

Last updated by Davi Lyra-Leite: 10/13/2016
- Updated the code to account for MATLAB's internal function changes
- Where originally we had avifile, now reads VideoWriter
- Where originally we had addframe, now reads open(mov) followed by writeVideo


Last updated by Anya: 03/10/2010
First written: 11/14/2009

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

function MakeFilmMovie(xProjPix,FilmLoc,FilmLengthPix,XX,YY,frames,num_films,frame_rate,...
    frame_step,start_frame,end_frame,raw_rgb_filename,x_proj_mov_filename,TopBotInd)

%ask the user for the original movie
%Ask the user for a single file
filename7 = x_proj_mov_filename;
bot_filename = [filename7(1:(length(filename7)-9)) 'bottom_xProjDatafile.mat'];
top_filename = [filename7(1:(length(filename7)-9)) 'top_xProjDatafile.mat'];

if XX<max(FilmLengthPix)
    disp('Error: The length of the film is longer than crop area')
end

%seed image matrix
clear raw_image_data
% initialize image stack array
raw_image_data = zeros(XX,YY,3,frames,'uint8'); % preallocate prodduces HeightxWidthx3(rgb) for each frame

FilmLoc = cast(FilmLoc,'int16');
%specify line width in pixels
line_width = 6;
%for each film specify where the film is "located"
film_width = max(FilmLoc(1,:),FilmLoc(2,:))-min(FilmLoc(1,:),FilmLoc(2,:)); %the width of the film
%The height of each film +/- line width
xProjPixMat = cast(xProjPix(:,:),'int16');
ttsz = size(FilmLoc);
if ttsz(1) == 2
    BaseFilm = zeros(ttsz(2),frames);
    FilmLoc(3,:) = zeros(1,ttsz(2));
else
    BaseFilm = repmat(FilmLoc(3,:)',1,frames);
end
BaseFilm = cast(BaseFilm(:,:),'int16');

pmTopBot = TopBotInd*2-1; %this will be +1 for bottom and -1 for top

%vertical position of horizontal line
h_line_str = (TopBotInd*XX).*ones(num_films,frames,'int16')-pmTopBot.*(xProjPixMat+BaseFilm)-line_width.*ones(num_films,frames,'int16');
h_line_end = (TopBotInd*XX).*ones(num_films,frames,'int16')-pmTopBot.*(xProjPixMat+BaseFilm)+line_width.*ones(num_films,frames,'int16');

%The start+1/4, end-1/4, and center of each film
w_line_str = min(FilmLoc(1,:),FilmLoc(2,:))+floor(0.25.*film_width);
w_line_end = max(FilmLoc(1,:),FilmLoc(2,:))-floor(0.25.*film_width);
center_film = min(FilmLoc(1,:),FilmLoc(2,:))+floor(0.5.*film_width);

%if the x-projection is less than the line width, reset it to draw line at
%the bottom of the screen
OnePlaceHolder = ones(size(h_line_end),'uint8');
h_line_str((xProjPixMat+BaseFilm) <= line_width) = (TopBotInd*XX).*OnePlaceHolder((xProjPixMat+BaseFilm) <= line_width)-pmTopBot.*line_width.*OnePlaceHolder((xProjPixMat+BaseFilm) <= line_width);
h_line_end((xProjPixMat+BaseFilm) <= line_width) = (TopBotInd*XX).*OnePlaceHolder((xProjPixMat+BaseFilm) <= line_width);
if(min(min((xProjPixMat+BaseFilm))) <= line_width)
    disp('Warning: one of the films is not there for one of the frames');
end

%specify blue (initial image) line width in pixels
line_width_i = 3;
%The height of each film +/- line width
Top_line_str = floor(((TopBotInd*XX).*ones(num_films,1)-pmTopBot.*(FilmLengthPix+cast(FilmLoc(3,:)','double')))-line_width_i.*ones(num_films,1));
Top_line_end = floor(((TopBotInd*XX).*ones(num_films,1)-pmTopBot.*(FilmLengthPix+cast(FilmLoc(3,:)','double')))+line_width_i.*ones(num_films,1));
%The left line location
L_line = min(FilmLoc(1,:),FilmLoc(2,:));
%The right line location
R_line = max(FilmLoc(1,:),FilmLoc(2,:));

% load in image stack
disp('Loading image stack...')
%If the frame_step is zero assume the movie is being made for
%a error check and compress it. Otherwise, assume it will be used in
%ImageJ, and specify no compression. Also adjust the frame rate
if frame_step == 1 && start_frame==1  %bug check
    %Check, if top/bottom was already drawn then, cycle through each frame to load it into the data array
    if TopBotInd == 1
        if exist(top_filename,'file')~=0
            %Temp = load(top_filename);
            %raw_image_data = Temp.raw_image_data;
            %raw_image_data = cast(raw_image_data,'int16');
            %readerobj = mmreader(filename7);
            % Read in all the video frames.
            mov2 = aviread(filename7);
            for frame=1:frames
                raw_image_data(1:XX,1:YY,1:3,frame) = mov2(1,frame).cdata(1:XX,1:YY,1:3);
            end
            raw_image_data = cast(raw_image_data,'uint8');
            clear mov2
        else
            for frame=1:frames
                [raw_image_data(:,:,:,frame)] = imread([raw_rgb_filename],'tif',frame); %load each frame separately
            end
        end
    else %if this is the top
        if exist(filename7,'file')~=0
            mov2 = aviread(filename7);
            for frame=1:frames
                %             size(mov(1,frame).cdata)
                %             size(raw_image_data(:,:,:,frame))
                raw_image_data(1:XX,1:YY,1:3,frame) = mov2(1,frame).cdata(1:XX,1:YY,1:3);
            end
            raw_image_data = cast(raw_image_data,'uint8');
            clear mov2
        else
            for frame=1:frames
                [raw_image_data(:,:,:,frame)] = imread([raw_rgb_filename],'tif',frame); %load each frame separately
            end
        end
    end
    disp(filename7);
    if frame_rate < 1
        apperent_frame_rate = 10; %this is done so that the VSM data that has a frame rate of less than 1 can be made into a movie
    else
        apperent_frame_rate = frame_rate; %otherwise keep actual frame rate
    end
%     mov = avifile([filename7],'fps',apperent_frame_rate,'compression','none');
    mov = VideoWriter([filename7],'Uncompressed AVI');

else
    if frame_rate < 1
        apperent_frame_rate = 10; %this is done so that the VSM data that has a frame rate of less than 1 can be made into a movie
        filename7afr = [filename7 '_VSM'];
        disp(filename7afr);
%         mov = avifile(filename7afr,'fps',apperent_frame_rate,'compression','none');
        mov = VideoWriter([filename7],'Uncompressed AVI');
    else
        apperent_frame_rate = frame_rate/frame_step;
        filename7 = [filename7(1:length(filename7)-4) '_fps_' num2str(apperent_frame_rate) '.avi'];
        disp(filename7);
%         mov = avifile(filename7,'fps',apperent_frame_rate,'compression','none');
        mov = VideoWriter([filename7],'Uncompressed AVI');
        disp(['The apperent frame rate is: ', num2str(apperent_frame_rate)]);
    end
    %Check, if top/bottom was already drawn then, cycle through each frame to load it into the data array
if TopBotInd == 1
    if exist(top_filename,'file')~=0
        %Temp = load(top_filename);
        %raw_image_data = Temp.raw_image_data;
        %raw_image_data = cast(raw_image_data,'int16');
        %readerobj = mmreader(filename7);
        % Read in all the video frames.
        mov2 = aviread(filename7);
        for frame=1:frames
            raw_image_data(1:XX,1:YY,1:3,frame) = mov2(1,frame).cdata(1:XX,1:YY,1:3);
        end
        raw_image_data = cast(raw_image_data,'uint8');
        clear mov2
    else
        for frame=1:frames
            [raw_image_data(:,:,:,frame)] = imread([raw_rgb_filename],'tif',frame); %load each frame separately
        end
    end
else %if this is the top
    if exist(bot_filename,'file')~=0
        mov2 = aviread(filename7);
        for frame=1:frames
%             size(mov(1,frame).cdata)
%             size(raw_image_data(:,:,:,frame))
            raw_image_data(1:XX,1:YY,1:3,frame) = mov2(1,frame).cdata(1:XX,1:YY,1:3);
        end
        raw_image_data = cast(raw_image_data,'uint8');
        clear mov2
    else
        for frame=1:frames
            [raw_image_data(:,:,:,frame)] = imread([raw_rgb_filename],'tif',frame); %load each frame separately
        end
    end
end
end


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
    hls_temp=Top_line_str(j)+2;
    hle_temp=(TopBotInd*XX)-pmTopBot.*cast(FilmLoc(3,j)','double')+1;
    hls = min(hls_temp,hle_temp);
    hle = min(max(hls_temp,hle_temp),XX);
    wls=L_line(j)-line_width_i;
    wle=L_line(j)+line_width_i;
    one_size = size(raw_image_data(hls:hle,wls:wle,3,:));
    zero_size = size(raw_image_data(hls:hle,wls:wle,1:2,:));
    raw_image_data(hls:hle,wls:wle,3,:)=255*ones(one_size);
    raw_image_data(hls:hle,wls:wle,1:2,:)=0.0.*ones(zero_size);
end
%vertical line Right
for j=1:num_films
    hls_temp=Top_line_str(j)+2;
    hle_temp=(TopBotInd*XX)-pmTopBot.*cast(FilmLoc(3,j)','double')+1;
    hls = min(hls_temp,hle_temp);
    hle = min(max(hls_temp,hle_temp),XX);
    wls=R_line(j)-line_width_i;
    wle=R_line(j)+line_width_i;
    one_size = size(raw_image_data(hls:hle,wls:wle,3,:));
    zero_size = size(raw_image_data(hls:hle,wls:wle,1:2,:));
    raw_image_data(hls:hle,wls:wle,3,:)=255*ones(one_size);
    raw_image_data(hls:hle,wls:wle,1:2,:)=0.0.*ones(zero_size);
end
%%%%%%%%%%%%%%%%% Initial Image %%%%%%%%%%%%%%%%%%%%%%%%%%

%for each frame and for each film insert a line at the edge and film outline, then write it
%to the file.

for i=start_frame:frame_step:end_frame
    %%%%%%%%%%%%%%%%%%%% BARS %%%%%%%%%%%%%%%%%%%
    %horizontal line
    for j=1:num_films
        hls=h_line_str(j,i)+1;
        hle=h_line_end(j,i)+1;
        wls=w_line_str(j)+1;
        wle=w_line_end(j)+1;
        one_size = size(raw_image_data(hls:hle,wls:wle,1,i));
        zero_size = size(raw_image_data(hls:hle,wls:wle,2:3,i));
        raw_image_data(hls:hle,wls:wle,1,i)=255*ones(one_size);
        raw_image_data(hls:hle,wls:wle,2:3,i)=0.0.*ones(zero_size);
    end
    %vertical line
    for j=1:num_films
        hls_temp=cast(h_line_str(j,i)+2,'int16');
        hle_temp=cast((TopBotInd*XX),'int16')-pmTopBot.*cast(FilmLoc(3,j)','int16')+1;
        hls = min(hls_temp,hle_temp);
        hle = min(max(hls_temp,hle_temp),XX);
        wls=cast(center_film(j)-line_width,'int16');
        wle=cast(center_film(j)+line_width,'int16');
        one_size = size(raw_image_data(hls:hle,wls:wle,1,i));
        zero_size = size(raw_image_data(hls:hle,wls:wle,2:3,i));
        raw_image_data(hls:hle,wls:wle,1,i)=255*ones(one_size);
        raw_image_data(hls:hle,wls:wle,2:3,i)=0.0.*ones(zero_size);
    end
    %%%%%%%%%%%%%%%%%% BARS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %raw_image_data_ui8 = cast(raw_image_data(:,:,:,i),'uint8');
%     mov = addframe(mov,raw_image_data(:,:,:,i));
open(mov)    
writeVideo(mov,raw_image_data(:,:,:,i));
end

%raw_image_data = cast(raw_image_data,'uint8');

% mov=close(mov);
close(mov);
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