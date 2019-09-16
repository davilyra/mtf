%{
MakeStressPlotMovie.m

Last updated: 11/14/2009

written by Anya Grosberg
Disease Biophysics Group
School of Engineering and Applied Sciences
Havard University, Cambridge, MA 02138

The purpose of this code is to create a movie from the evolution of stress with time.


Input: Automatic input of:
        1. The Film Stress for each film
        2. number of films
        3. height and width of the plot figure window
        4. number of frames
        5. time vector
        6. complete filename 
        
Output: .avi movie of combined images
%}

function MakeStressPlotMovie(FilmStress,frames,num_films,time,filename_stress,PlFH,PlFW,frame_rate,frame_step,start_frame,end_frame)

filename6 = '_Stress_Movie';
%filename6 = 'Stress_Movie.tif';
filename7 = [filename_stress(1:(length(filename_stress)-4)) filename6];

%set colormap value (only useful if I could get the tif stack working)
%cmp = colormap;
%The plot will have the same width as the images but the height should make
%the plots look proportional.
figpostion = [250, 250, PlFW, PlFH];

%Specify the invisible figure preferences
h_pl = figure('Position',figpostion,'Visible','off','NextPlot','replacechildren','Color',[1 1 1]);

%Change the units of the stress to kPa
FilmStresskPa = FilmStress./1000;

%Find the axis limits
x_axis_min = 0;
x_axis_max = time(end_frame)-time(start_frame);
y_axis_min = floor(min(min(FilmStresskPa(1:frames-1,:))));
y_axis_max = ceil(max(max(FilmStresskPa(1:frames-1,:)))+(max(max(FilmStresskPa(1:frames-1,:)))/50));
x_step = round(x_axis_max/4);
x_tick_vec = 0:x_step:x_axis_max;

%cycle through the number of films except the first to specify the axis
%handles, the first is set separately so that the y axis is displayed only
%on the left
subplot(1,num_films,1);
axis([x_axis_min,x_axis_max,y_axis_min,y_axis_max]);
xlabel('time (s)','FontName','Arial');
ylabel('Stress (kPa)','FontName','Arial');
set(gca,'FontName','Arial','NextPlot','replacechildren','XTickMode','manual','XTick',x_tick_vec,'YTickMode','auto');
for film=2:num_films
    subplot(1,num_films,film);
    axis([x_axis_min,x_axis_max,y_axis_min,y_axis_max]);
    xlabel('time (s)','FontName','Arial');
    set(gca,'FontName','Arial','NextPlot','replacechildren','XTickMode','manual','XTick',x_tick_vec,'YTickMode','auto');
    %'ytick',[],
end

if frame_rate < 1
        apperent_frame_rate = 10; %this is done so that the VSM data that has a frame rate of less than 1 can be made into a movie
        filename7afr = [filename7 '_VSM'];
        disp(filename7afr);
        mov_plot = avifile(filename7afr,'fps',apperent_frame_rate,'compression','none');
    else
        %for each frame and for each film plot the stress
        apperent_frame_rate = frame_rate/frame_step;
        filename7afr = [filename7 '_fps_' num2str(apperent_frame_rate) '.avi'];
        mov_plot = avifile(filename7afr,'fps',apperent_frame_rate,'compression','none');
        disp(['The apperent frame rate is: ', num2str(apperent_frame_rate)]);
end
aviobj.quality = 100; %set the highest quality
%aviobj.compression = 'Indeo3';

for i=start_frame:frame_step:end_frame    
    for j=1:num_films
        subplot(1,num_films,j);
        plot((time(start_frame:i)-time(start_frame)),FilmStresskPa(start_frame:i,j),'k','LineWidth',2);
    end
    %X=getframe(h_pl);
    %imwrite(X.cdata,cmp,filename7,'tif','Compression','none','WriteMode','append','Compression','packbits','ColorSpace','rgb');

    mov_plot = addframe(mov_plot,h_pl);
end

mov_plot=close(mov_plot);
close(h_pl)

end