%PostProcessMulti.m
%
% Last updated: 02/04/2010
%
% Anya Grosberg
% Disease Biophysics Group
% School of Engineering and Applied Sciences
% Havard University, Cambridge, MA 02138
%
%
%
%
%This code is for processing data from multiple conditions, with the option
%of having multiple files per condition.
%

clear all;

%Repeat run for plots or new run?
Choose = input('Would you like to re-analyze that data [Yes = 0, No = 1]: ');

if Choose == 0

    %Ask the user to pick a file with all the condition names
    [file_cond,path_base] = uigetfile({'*.txt';'*.*'},'Please pick a text file with the condition names...','G:\Anya\Microscopy_Images\');
    filename_cond = [path_base file_cond];
    %load the file (into a cell array)
    Condition_Cell = textread(filename_cond,'%q');
    %How many conditions?
    NumCond = length(Condition_Cell);

    %Analyze stress data for each condition
    for cond_count = 1:NumCond
        %Store the name of the condition
        condname_temp = Condition_Cell{cond_count,1};
        condname_str(cond_count,1:length(condname_temp)) = condname_temp;

        [file_mX,pathX]=uigetfile({'*_StressDatafile.mat';'*.*'},['Select the stress data files for ' condname_temp ' ...'],path_base,'MultiSelect','on');

        %initilize n for this condition
        cond_n(cond_count) = 0;
        cond_n_temp = 1;
        %number of files
        cond_nf = length(file_mX);

        if iscell(file_mX)== 1 %multiple files call
            for fi=1:cond_nf
                temp = file_mX{fi};
                FileIndex{fi} = temp;
            end
        else %single file
            cond_nf=1;
            FileIndex{1} = file_mX;
        end

        for filecount=1:cond_nf
            fileX = FileIndex{filecount};
            %initilize filter values
            %the order of the butter filter
            order_filter = 10;
            %the normalized cut off frequency for the butter filter
            Cutoff_freq = 0.1;
            ChooseOKfilter = 1;
            %cycle until the filter values are satisfied
            while ChooseOKfilter == 1
                %create a structure with all the output variables
                [cond(cond_count,cond_nf).basal_stress,cond(cond_count,cond_nf).mean_rise_time,cond(cond_count,cond_nf).mean_fall_time,cond(cond_count,cond_nf).mean_peak_cont_stress,cond(cond_count,cond_nf).cont_stress,cond(cond_count,cond_nf).num_films,cond(cond_count,cond_nf).mean_freq,cond(cond_count,cond_nf).pre_stress,cond(cond_count,cond_nf).abs_max_stress] = PostProcessStressData_func(fileX,pathX,order_filter,Cutoff_freq);
                %aske the user if the filter is OK
               ChooseOKfilter = input('Is the filter OK? [Yes = 0, No = 1] ');
                if ChooseOKfilter == 1
                    %the order of the butter filter
                    order_filter = input('Please enter a different filter order (default = 10): ');
                    %the normalized cut off frequency for the butter filter
                    Cutoff_freq = input('Please enter a different cut-off frequency (default 0.1): ');
                end
            end
            %n for this condition
            cond_n(cond_count) = cond_n(cond_count) + cond(cond_count,cond_nf).num_films; %keeping track of the total number of films
            %record the additional films by appending the same vector
            %for this condition
            freq(cond_count,cond_n_temp:cond_n(cond_count)) = cond(cond_count,cond_nf).mean_freq;
            peak_stress(cond_count,cond_n_temp:cond_n(cond_count)) = cond(cond_count,cond_nf).mean_peak_cont_stress;
            sys_stress(cond_count,cond_n_temp:cond_n(cond_count)) = cond(cond_count,cond_nf).abs_max_stress;
            dys_stress(cond_count,cond_n_temp:cond_n(cond_count)) = cond(cond_count,cond_nf).pre_stress;
            cond_n_temp = cond_n_temp+cond_n(cond_count); %update the temporary cond number
        end        
    end

    %ask the user to choose the control condition
    [control,v_ok] = listdlg('PromptString','Select the control condition name:','SelectionMode','single','Name','Control condition','ListString',Condition_Cell);
    %the mean of the diastolic stresses is going to be the stress we
    %normalize everything to
    base_diastolic_stress = mean(dys_stress(control,1:cond_n(control)));
            
           
    %Calculate the statistics for each condition
    for i=1:NumCond
        ave_freq(i) = mean(freq(i,1:cond_n(i)));
        ave_cont_to_base_stress(i) = mean(sys_stress(i,1:cond_n(i)) - base_diastolic_stress.*ones(size(sys_stress(i,1:cond_n(i)))));
%        ave_peak_stress(i) = mean(peak_stress(i,1:cond_n(i)));
%         ave_sys_stress(i) = mean(sys_stress(i,1:cond_n(i)));
%         ave_dys_stress(i) = mean(dys_stress(i,1:cond_n(i)));
%         Nor_ave_sys_stress(i) = ave_sys_stress(i)/ave_dys_stress(1);
%         Nor_ave_dys_stress(i) = ave_dys_stress(i)/ave_dys_stress(1);
         er_freq(i) = std(freq(i,1:cond_n(i)));
         er_cont_to_base_stress(i) = std(sys_stress(i,1:cond_n(i)) - base_diastolic_stress.*ones(size(sys_stress(i,1:cond_n(i)))));
%         er_sys_stress(i) = std(sys_stress(i,1:cond_n(i)));
%         er_dys_stress(i) = std(dys_stress(i,1:cond_n(i)));
%         er_peak_stress(i) = std(peak_stress(i,1:cond_n(i)));
%         Nor_er_sys_stress(i) = er_sys_stress(i)/ave_dys_stress(1);
%         Nor_er_dys_stress(i) = er_dys_stress(i)/ave_dys_stress(1);
%         if NumCond > 1
%             if i<NumCond %stop before the last point for cross statistics
%                 for j=(i+1):NumCond
%                     [h_freq,p_freq(i,j)]=ttest2(freq(i,1:cond_n(i)),freq(j,1:cond_n(i)));
%                     [h_stress,p_stress(i,j)]=ttest2(peak_stress(i,1:cond_n(i)),peak_stress(j,1:cond_n(i)));
%                 end
%             end
%         end
    end

    %save the file containing all the summary variables
    %Ask for the file name and path
    path_user = uigetdir(path_base,'Please pick a directory for the summary file...');
    file_user = input('Please enter the filename for the summary file: ','s');
    filename_user = [path_user '\' file_user '.mat'];
    disp(filename_user)
    %save(filename_user,'cond','freq','peak_stress','p_freq','p_stress','ave_freq','ave_peak_stress','condname_str','NumCond','cond_n','er_freq','er_peak_stress','Nor_ave_sys_stress','Nor_ave_dys_stress','Nor_er_sys_stress','Nor_er_dys_stress');
    save(filename_user,'cond','freq','peak_stress','ave_freq','ave_cont_to_base_stress','condname_str','NumCond','cond_n','er_freq','er_cont_to_base_stress');
else
    [file,path_user]=uigetfile({'*.mat';'*.*'},'Select Summary File...','G:\Anya\Microscopy_Images\');
    filename = [path_user file];
    disp(filename)
    load(filename);
    filename_user = filename;
end
%close all figures assume the filters were OK
close all
%Plot a histogram with error bars
figure(1)
%frequency
bars_to_plot_freq= ave_freq;
n=cond_n;
bar_xaxis = char(condname_str);
subplot(2,1,1)
bar(bars_to_plot_freq,'FaceColor',[0.8,0.8,0.8])
error_bars_freq=er_freq;
hold on
%%change to standard error
%error_bars=error_bars./sqrt(n);
errorbar(bars_to_plot_freq,error_bars_freq,'k','LineStyle','none','Marker','none','LineWidth',2);
set(gca,'FontName','Arial','FontSize',9,'xticklabel',bar_xaxis);
max_y = ceil(11.*max(ave_freq+er_freq))/10;
axis([0 NumCond+1 0 max_y]);
ylabel('Frequency (Hz)','FontName','Arial','FontSize',6,'FontWeight','bold');
for i=1:NumCond
    text(i,max_y/20,['n=',num2str(cond_n(i))],'FontName','Arial','FontSize',9,'HorizontalAlignment','center')
end
title(path_user(27:length(path_user)),'Interpreter','none');
%stress
bars_to_plot_stress= ave_cont_to_base_stress./1000;
n=cond_n;
bar_xaxis = char(condname_str);
subplot(2,1,2)
bar(bars_to_plot_stress,'FaceColor',[0.8,0.8,0.8])
error_bars_stress=er_cont_to_base_stress./1000;
hold on
%%change to standard error
%error_bars=error_bars./sqrt(n);
errorbar(bars_to_plot_stress,error_bars_stress,'k','LineStyle','none','Marker','none','LineWidth',2);
set(gca,'FontName','Arial','FontSize',9,'xticklabel',bar_xaxis);
max_y = ceil(11.*max(bars_to_plot_stress+2.*error_bars_stress))/10;
axis([0 NumCond+1 0 max_y]);
ylabel('Peak Contraction Stress (kPa)','FontName','Arial','FontSize',6,'FontWeight','bold');
for i=1:NumCond
    text(i,max_y/20,['n=',num2str(cond_n(i))],'FontName','Arial','FontSize',9,'HorizontalAlignment','center')
end

%save figure
filename_fig = [filename_user(1:(length(filename_user)-4)) 'bar_plot.jpg'];
set(gcf,'Color',[1 1 1]);
saveas(gcf,filename_fig)