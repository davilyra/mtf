%{
FilmXProjRcurvCalcMainMulti.m

Last updated: 12/09/2014

written by Anya Grosberg
Disease Biophysics Group
School of Engineering and Applied Sciences
Havard University, Cambridge, MA 02138

updated by Nethika Ariyasinghe

The purpose of this code is to calculate the x-projection, radius of curvature progression with time for multiple moves produced by hMTF assay.
Assumes the movies were analyzed with the hMTF macro.


Global variable: Cloc
                 cell_thick bound
                 thick
                 Yprime

Input: 
    The user is aksed for:
        1. Files containing the *.tif stacks
        2. Thickness of the PDMS layer
        3. The pixels/mm scale of images
        4. The number of films to analyze
        
Output: 
%}
clear
warning('off')
global cell_thick bound

%set figure counter, so that I can plot as many figures as I want without
%overlapping them
figcount=0;
%set global variables
bound=1000;
%make an assumption about the thickness of the cell layer
cell_thick=4.4e-6;

%========================================
% First Import data file named xy
%========================================

close all;
disp('This code is for analyzing multiple movies made from the same sample that has not been moved.');
disp('It assumes the use of the hMTF ImageJ macro.');

%Ask the user to choose the base directory
path_base = uigetdir('M:\Anya\Microscopy_Images\','Please pick a base directory...');

%Ask the user for the frame rate of the movies
%frame_rate = input('Enter the frame rate of the movies: ');

%Load files containing all constants from the base directory
filename_constants = [path_base '\hmtf-scale-pixels-per-mm_bot_filmnum_top_filmnum.txt'];
constants_temp = load(filename_constants);
num_films_bot = constants_temp(2);
%num_films_top = constants_temp(3);
cmlength=constants_temp(1); %scale in pixels/mm
%Change to px/m
cmlength=cmlength.*1000;

filename_constants2 = [path_base '\frame-rate_PDMS-thick_cell-thick.txt']; % doesn't like the "001" in the code
constants_temp2 = load(filename_constants2);
%Change the units to meters
frame_rate = constants_temp2(1); %frame rate of the movie
pdms_thick=constants_temp2(2).*1e-6; %thickness of PDMS
cell_thick_mod=constants_temp2(3).*1e-6; %thickness of the cell layer

%load the files with the film locations
filename_loc_bottom = [path_base '\hmtf_film_locations.txt'];
%filename_loc_top = [path_base '\hmtf_top_film_locations.txt'];
films_loc_temp = load(filename_loc_bottom);
Film_Loc_bottom = films_loc_temp';
%films_loc_temp = load(filename_loc_top);
%Film_Loc_top = films_loc_temp';


%%%%%%%%%%%%% START INITIAL IMAGE %%%%%%%%%%%%%%%%%%%%
%Load the text file with the film lengths
filename_Init_bottom = [path_base '\Film_Lengths.txt'];
%filename_Init_top = [path_base '\Film_Lengths_top.txt'];
Film_Length_bot_temp = load(filename_Init_bottom);
%Film_Length_top_temp = load(filename_Init_top);
Film_Length_mm_bottom = Film_Length_bot_temp(:,1);
%Film_Length_mm_top = Film_Length_top_temp(:,1);
xProjMetInit_bottom = Film_Length_mm_bottom/1000;
%xProjMetInit_top = Film_Length_mm_top/1000;
xProjPixInit_bottom = Film_Length_bot_temp(:,2);
%xProjPixInit_top = Film_Length_top_temp(:,2);
cmlengthInit = cmlength;
%%%%%%%% END INITIAL IMAGE %%%%%%%%%%%%%%%%%%%%%%


%Ask the user for all files with cleaned images
[file,path]=uigetfile({'*clean.tif';'*.*'},'Select Stacks with "clean" images...',path_base,'MultiSelect','on');

if iscell(file)
    NumFiles = length(file);
    
    for i=1:NumFiles
        temp = file{i};
        FileIndex{i} = temp;
    end
else
    NumFiles = 1;
    FileIndex{1} = file;
end

%loop through all the other files
for filecount=1:NumFiles
    filecounter=['file # ' num2str(filecount) ' of ' num2str(NumFiles)];
    disp(filecounter)
    
    %set up filename and path
    filename = FileIndex{filecount};
    path_and_filename = [path filename];
    filename2 = path_and_filename;
    base_filename = filename(1:(length(filename)-10));
    
    % get file info
    info = imfinfo([filename2]); %produces a structure that containes information about the stack file
    frames = length(info); %The number of frames in the stack
    XX = info(1).Height; %Use first image to get the height in pixels
    YY = info(1).Width; %Use first image to get the width in pixels
    
    %Determine whether the files is of the bottom or the top of the films
    %TobBotInd = 0 for the top, =1 for bottom
    
    FilmLoc(1:2,:) = Film_Loc_bottom(1:2,:);
    FilmLoc(3,:) = XX*ones(size(Film_Loc_bottom(3,:))) - Film_Loc_bottom(3,:);
    num_films = num_films_bot;
    FilmLengthMet = xProjMetInit_bottom;
    xProjMetInit = xProjMetInit_bottom;
    TopBotInd = 1;
    raw_rgb_filename=[path filename(1:(length(filename)-10)) 'raw_RGB.tif'];
    x_proj_mov_filename = [path filename(1:(length(filename)-10)) 'xProj.avi'];
    
end
[xProjPix,xProjMet]=FilmXPorjCalc_Multi(frames,XX,YY,cmlength,filename2,num_films,FilmLoc);

%Check the quality of the image: i.e. check that the films are never longer
%than the reported film length. Return an error and the number of films
%that are read incorrectly if the error is larger than a few pixels. If the
%error is only a few pixels it is possible that the films don't have a lot
%of initial pre-stress and then it is really hard to deconvolute the two
%images, since the lighting can be weird. Therefore, in that case I set it
%back to the maximum.
MaximumFilmLength_movie=max(xProjMet,[],2);
film_too_long_check = ((xProjMetInit-MaximumFilmLength_movie)<0);
if sum(film_too_long_check)>0
    disp(['ERROR: The following film(s) are longer than their initial length: ', num2str(find(film_too_long_check')),'. Check images and scales'])
    if (min(film_too_long_check)< (-0.05e-3)) %easier to do in meters - so if the difference is less than 1/20 of a mm reset film length
        return
    else
        disp('reseting film length');
        FilmLengthMet(find(film_too_long_check'))=MaximumFilmLength_movie(find(film_too_long_check'));
    end
end

%Check to make sure that there aren't frames that got wiped out due to
%the imperfections in the imageJ funcitons. It won't be possible to
%capture this if the films remain at all, however I think the way
%ImageJ was written that shouldn't happen. However, it is possible that
%the whole frame will be wiped to white. If that happens the stress
%code hangs rather badly, since the radius of curvature is
%unrealistically small, making the stress approach infinity. To avoid
%this I will go through the films and force the ones that are totaly
%blank to be the average of the frames to either side.
films_are_gone = (xProjMet==0);
[row_nz,col_nz] = find(films_are_gone);
Num_Films_Blank = length(row_nz);
for blank_frame = 1:Num_Films_Blank
    disp(['Film #', num2str(row_nz(blank_frame)), ' is blank on frame #', num2str(col_nz(blank_frame)), ', resetting to average of neighboring frames']);
    frame_prev = 2*((col_nz(blank_frame)-1)<1)+(col_nz(blank_frame)-1)*((col_nz(blank_frame)-1)>=1);
    frame_next = (frames-1)*((col_nz(blank_frame)+1)>frames)+(col_nz(blank_frame)+1)*((col_nz(blank_frame)+1)<=frames);
    xProjMet(row_nz(blank_frame),col_nz(blank_frame)) = 0.5*(xProjMet(row_nz(blank_frame),frame_prev)+xProjMet(row_nz(blank_frame),frame_next));
    xProjPix(row_nz(blank_frame),col_nz(blank_frame)) = 0.5*(xProjPix(row_nz(blank_frame),frame_prev)+xProjPix(row_nz(blank_frame),frame_next));
end

%reset pixel count for film length
FilmLengthPix = FilmLengthMet.*(cmlength);

MakeFilmMovie(xProjPix,FilmLoc,FilmLengthPix,XX,YY,frames,num_films,frame_rate,1,1,frames,raw_rgb_filename,x_proj_mov_filename,TopBotInd);

%Calculate the radius of curvature
[RCurve,FilmEdgeMet] = FilmRCurvCalc(xProjMet,FilmLengthMet,frames,num_films);
%Find the number of pixels from the bottom of the screen to the edge of
%the film
FilmEdgePix = FilmEdgeMet.*(cmlength);
%Determine the time vector
time = linspace(0,frames/frame_rate,frames);

filename_xproj = [path base_filename '_xProjDatafile.mat']
path_stress = path;
save(filename_xproj,'xProjPix','xProjMet','FilmLoc','cmlength','XX','YY','frames',...
    'time','RCurve','FilmLengthMet','FilmLengthPix','num_films','frame_rate','path_base','path_stress','FilmEdgePix','TopBotInd',...
    'raw_rgb_filename','x_proj_mov_filename','pdms_thick','cell_thick_mod');

clear 'filename_xproj' 'xProjPix' 'xProjMet' 'frames' 'time' 'RCurve' 'raw_rgb_filename' 'x_proj_mov_filename' 'MaximumFilmLength_movie' ...
    'xProjMetInit' 'film_too_long_check' 'FilmLengthMet' 'FilmLoc'

close all