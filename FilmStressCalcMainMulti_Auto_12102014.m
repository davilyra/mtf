%{
FilmStressCalcMainMulti.m

Last updated: 03/12/2010
First version: 11/14/2009

written by Anya Grosberg
Disease Biophysics Group
School of Engineering and Applied Sciences
Havard University, Cambridge, MA 02138

The purpose of this code is to calculate the stress progression with time for multiple moves produced by hMTF assay.


Global variable: Cloc
                 cell_thick bound
                 thick
                 Yprime

Input: 
    The user is aksed for:
        1. Files containing the xprojection and radius of curvature information
        2. Thickness of the PDMS layer
        3. The pixels/mm scale of images
        4. The number of films to analyze
        
Output: 
%}
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
disp('This code is for calculating stress for data made from the same sample that has not been moved.');
disp('It assumes that the ImageJ macro was used');

% Ask the user to select all the files with the x_projectio and radius of
% curvature data.
[file3,path3]=uigetfile({'*_xProjDatafile.mat';'*.*'},'Select files with xProjection and radius of curvature data...','M:\Anya\Microscopy_Images\','MultiSelect','on');
path_stress = path3;

if iscell(file3)
    NumFiles = length(file3);

    for i=1:NumFiles
        temp = file3{i};
        FileIndex{i} = temp;
    end
else
    NumFiles = 1;
    FileIndex{1} = file3;
end

% %Go through the first file to get set up information
% filecount=1;
% %Let the user know which file is being analyzed
% filecounter=['file # ' num2str(filecount) ' of ' num2str(NumFiles)];
% disp(filecounter)
% %set up filename and path
% filename = FileIndex{filecount};
% base_filename = filename(1:(length(filename)-18));
% path_and_filename = [path3 filename];
% filename2 = path_and_filename;
% disp(filename2)
% load(filename2);
% filename_fig = [path3 [base_filename '_stress_plot.jpg']];
% disp(['base filename: ', base_filename]);
% disp(['figure filename: ',filename_fig]);
% 
% 
% 
% 
% %run the stress code for the set-up file
% [FilmStress,pdms_thick,cell_thick_mod] = FilmStressCalc(RCurve,FilmLengthMet,num_films,frames,filename2);
% filename_stress = [filename2(1:(length(filename2)-4)) '_StressDatafile.mat'];
% save(filename_stress,'FilmStress','time','num_films','frame_rate','filename2','pdms_thick','cell_thick_mod');

% %Plot simple plot of stress
% figcount=figcount+1;
% %Change the units of the stress to kPa
% FilmStresskPa = FilmStress./1000;
% %Find the axis limits
% x_axis_min = 0;
% x_axis_max = time(frames);
% y_axis_min = floor(min(min(FilmStresskPa(1:frames-1,:))));
% y_axis_max = ceil(max(max(FilmStresskPa(1:frames-1,:)))+(max(max(FilmStresskPa(1:frames-1,:)))/50));
% x_step = round(x_axis_max/4);
% x_tick_vec = 0:x_step:x_axis_max;
% figure(figcount)
% plot(time,FilmStresskPa);
% axis([x_axis_min,x_axis_max,y_axis_min,y_axis_max]);
% xlabel('time (s)','FontName','Arial');
% ylabel('Stress (kPa)','FontName','Arial');
% set(gca,'FontName','Arial','XTickMode','manual','XTick',x_tick_vec,'YTickMode','auto');
% title(base_filename,'Interpreter','none');
% legend
% set(gcf,'Color',[1 1 1]);
% saveas(gcf,filename_fig)


clear('FilmStress');

%loop through all the other files
for filecount=1:NumFiles
    filecounter=['file # ' num2str(filecount) ' of ' num2str(NumFiles)];
    disp(filecounter)
    %set up filename and path
    filename = FileIndex{filecount};
    base_filename = filename(1:(length(filename)-18));
    path_and_filename = [path3 filename];
    filename2 = path_and_filename;
    disp(filename2)
    load(filename2);


    %run the stress code for the set-up file
    FilmStress = FilmStressCalcMulti(RCurve,FilmLengthMet,num_films,frames,filename2,pdms_thick,cell_thick_mod);
    %FilmStress = FilmStressCalcMulti_differentGuess(RCurve,FilmLengthMet,num_films,frames,filename2,pdms_thick,cell_thick_mod);
    filename_stress = [filename2(1:(length(filename2)-4)) '_StressDatafile.mat'];
    save(filename_stress,'FilmStress','time','num_films','frame_rate','filename2','pdms_thick','cell_thick_mod');

%     %Plot simple plot of stress
%     figcount=figcount+1;
%     %Change the units of the stress to kPa
%     FilmStresskPa = FilmStress./1000;
%     %Find the axis limits
%     x_axis_min = 0;
%     x_axis_max = time(frames);
%     y_axis_min = floor(min(min(FilmStresskPa(1:frames-1,:))));
%     y_axis_max = ceil(max(max(FilmStresskPa(1:frames-1,:)))+(max(max(FilmStresskPa(1:frames-1,:)))/50));
%     x_step = round(x_axis_max/4);
%     x_tick_vec = 0:x_step:x_axis_max;
%     figure(figcount)
%     plot(time,FilmStresskPa);
%     axis([x_axis_min,x_axis_max,y_axis_min,y_axis_max]);
%     xlabel('time (s)','FontName','Arial');
%     ylabel('Stress (kPa)','FontName','Arial');
%     set(gca,'FontName','Arial','XTickMode','manual','XTick',x_tick_vec,'YTickMode','auto');
%     title(base_filename,'Interpreter','none');
%     legend
%     filename_fig = [path3 [base_filename '_stress_plot2.jpg']];
%     set(gcf,'Color',[1 1 1]);
%     saveas(gcf,filename_fig)

    clear('FilmStress');
end