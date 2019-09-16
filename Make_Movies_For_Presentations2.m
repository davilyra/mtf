%PostProcessMulti.m
%
% Last updated: 02/10/2010
%
% Anya Grosberg
% Disease Biophysics Group
% School of Engineering and Applied Sciences
% Havard University, Cambridge, MA 02138
%
%
%
%
%This code is for making pretty movies for presentations.
%

clear all;

%Ask the user to pick a file with xProjections
[file_xpr,base_path] = uigetfile({'*_xProjDatafile.mat';'*.*'},'Select a file with xProjection data...','M:\Anya\Microscopy_Images\');
filename_xpr = [base_path file_xpr];
filename_str = [filename_xpr(1:(length(filename_xpr)-4)) '_StressDatafile_analyzed.mat'];
%%load the files
load(filename_xpr);
load(filename_str);
base_filename = file_xpr(1:(length(file_xpr)-18));
%Determine whether the files is of the bottom or the top of the films
%TobBotInd = 0 for the top, =1 for bottom
filename = [base_filename '_clean.tif'];
if strcmp(filename((length(filename)-12):(length(filename)-10)), 'top')
    TopBotInd = 0;
    raw_rgb_filename=[base_path '\' filename(1:(length(filename)-13)) 'raw_RGB.tif'];
    x_proj_mov_filename = [base_path '\' filename(1:(length(filename)-13)) 'xProj1.avi'];
else if strcmp(filename((length(filename)-15):(length(filename)-10)),'bottom')
        TopBotInd = 1;
        raw_rgb_filename=[base_path '\' filename(1:(length(filename)-16)) 'raw_RGB.tif'];
        x_proj_mov_filename = [base_path '\' filename(1:(length(filename)-16)) 'xProj6.avi'];
    else
        disp('ERROR: THERE IS SOMETHING WRONG WITH THE FILE NAMES, EXIT NOW!!!!');
        break;
    end
end

frame_step = 4;
start_frame=1 ;
end_frame=floor(frames/2)-1;
%make the movie with the films
%MakeFilmMovie(xProjPix,FilmLoc,FilmLengthPix,XX,YY,frames,num_films,frame_rate,frame_step,start_frame,end_frame,...
%    raw_rgb_filename,x_proj_mov_filename,TopBotInd);
%MakeFilmEdgeMovie(FilmEdgePix,FilmLoc,FilmLengthPix,XX,YY,frames,num_films,base_path,base_filename,frame_rate,frame_step,start_frame,end_frame)
FigureHeight = floor(YY/(num_films));
PlFH = 2*FigureHeight;
PlFW = 2*YY;
%make the stress movie
stress_for_plot = FilmStress;% - repmat(min(FilmStress(1:length(time')-1,:)),length(time')+1,1);
%MakeStressPlotMovie2(stress_for_plot,(frames-1),num_films,time,filename_str,PlFH,PlFW,frame_rate,frame_step,start_frame,end_frame)
MakeStressPlotPic(stress_for_plot,(frames-1),num_films,time,filename_str,PlFH,PlFW,frame_rate,frame_step,start_frame,end_frame)