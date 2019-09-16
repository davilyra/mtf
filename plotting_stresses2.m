clear all;
data1 = load('G:\Anya\Microscopy_Images\2010_03_09\2010-03-09 plate1well2\009_2hz15V_mtf_clean.tifcalcs.matcalcs_newthick.mat');
data2 = load('G:\Anya\Microscopy_Images\2010_03_09\2010-03-09 plate1well2\006_2hz15V_bottom_xProjDatafile_StressDatafile_analyzed.mat');
data(1).cond = 'mtf';
data(2).cond = 'hmtf';
data(2).time = data2.time;
data(1).yy = -data1.cell_stress';
data(2).yy = data2.FilmStress;

data(1).time = (1:1:length(data(1).yy))./120;
figure(2)
hold on
for i=1:2
    subplot(1,2,i)
    name = data(i).cond;
    x = data(i).time;
    y = data(i).yy(1:(length(x)),1)/1000.;
    max_y = 15;
    max_x = max(x);
    plot(x,y,'k');
    xlabel('time (sec)','FontName','Arial','FontSize',10);
    ylabel('Stress Trace (kPa)','FontName','Arial','FontSize',10,'FontWeight','bold');
    title(name,'Interpreter','none','FontName','Arial','FontSize',10,'FontWeight','bold');
    axis([0 max_x 0 max_y]);
    hold on;
    hor_line = ones(size(x)).*8.699;
    plot(x,hor_line,'r')
    
end