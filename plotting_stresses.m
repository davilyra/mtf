clear all;
data(3) = load('G:\Anya\Microscopy_Images\2010_02_16\2010-02-16 plate1well2\2010-02-16 plate1well2\001_2Hz8V_bottom_xProjDatafile_StressDatafile_analyzed.mat');
data(1) = load('G:\Anya\Microscopy_Images\2010_02_16\2010-02-16 plate1well2\2010-02-16 plate1well2\02_2Hz10V_epi-11_bottom_xProjDatafile_StressDatafile2_analyzed.mat');
data(2) = load('G:\Anya\Microscopy_Images\2010_02_16\2010-02-16 plate1well2\2010-02-16 plate1well2\03_2Hz10V_epi-10_bottom_xProjDatafile_StressDatafile2_analyzed.mat');
data(4) = load('G:\Anya\Microscopy_Images\2010_02_16\2010-02-16 plate1well2\2010-02-16 plate1well2\04_2Hz10V_epi-9_bottom_xProjDatafile_StressDatafile2_analyzed.mat');
data(5) = load('G:\Anya\Microscopy_Images\2010_02_16\2010-02-16 plate1well2\2010-02-16 plate1well2\05_2Hz12V_epi-8_bottom_xProjDatafile_StressDatafile2_analyzed.mat');
data(6) = load('G:\Anya\Microscopy_Images\2010_02_16\2010-02-16 plate1well2\2010-02-16 plate1well2\06_2Hz12V_epi-7_bottom_xProjDatafile_StressDatafile2_analyzed.mat');
data(7) = load('G:\Anya\Microscopy_Images\2010_02_16\2010-02-16 plate1well2\2010-02-16 plate1well2\08_2Hz26V_epi-6_bottom_xProjDatafile_StressDatafile2_analyzed.mat');
data(8) = load('G:\Anya\Microscopy_Images\2010_02_16\2010-02-16 plate1well2\2010-02-16 plate1well2\09_2Hz16V_washout_bottom_xProjDatafile_StressDatafile2_analyzed.mat');
data(1).cond = '0mM ct 8V';
data(2).cond = '1e-11mM 10V';
data(3).cond = '1e-10mM 10V';
data(4).cond = '1e-9mM 10V';
data(5).cond = '1e-8mM 12V';
data(6).cond = '1e-7mM 12V';
data(7).cond = '1e-6mM 26V';
data(8).cond = '0mM w/o 16V';
figure(2)
hold on
for i=1:8
    subplot(2,4,i)
    name = data(i).cond;
    x = data(i).time;
    y = data(i).FilmStress(1:(length(x)),2)/1000.;
    max_y = 8;
    max_x = max(x);
    plot(x,y,'k');
    xlabel('time (sec)','FontName','Arial','FontSize',10);
    ylabel('Stress Trace (kPa)','FontName','Arial','FontSize',10,'FontWeight','bold');
    title(name,'Interpreter','none','FontName','Arial','FontSize',10,'FontWeight','bold');
    axis([0 max_x 0 max_y]);
    
end