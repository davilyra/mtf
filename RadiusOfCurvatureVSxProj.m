%{
RadiusOfCurvatureVSxProj.m

Last updated: 07/01/2009

written by Anya Grosberg
Disease Biophysics Group
School of Engineering and Applied Sciences
Havard University, Cambridge, MA 02138

The purpose of this code is to generate a table of the radius of curvature

Assumptions: The code assumes that the length of the film is 1000

Input: None
        
Output: .mat file containing two vectors 
            1. x-projection for 0<\theta<\pi/2
            2. corresponding radius of curvature
%}
clear
%the radius is bound at 10000*length for calculation purposes --> this is to
%prevent issues with the infinite radius of curvature
fl = 1; %film length (arbitrary)
r_bound = 100000*fl; %maximum
r_mid = 100*fl; %this is only needed to make an even step size for r that covers the smaller x in more detail;

%Generate the x-projection lengths for angles from 0 to pi/2
%delta_theta = pi()/2000; %this controls the accuracy of the table look up
%theta = (0:delta_theta:pi()/2)';
num_points = 50000; %specify the accuracy of the table - which will have twice this number of points
min_rcurve = fl./(pi()/2); %minimum radius of curvature
%rcurve_table = min(r_bound,1./(theta));
rcurve_table(1:num_points) = linspace(min_rcurve,r_mid,num_points);
rcurve_table(num_points:2*num_points-1) = linspace(r_mid,r_bound,num_points);
x_proj_table = rcurve_table.*sin(fl.*(1./rcurve_table));
x_proj_table(num_points*2-1)=fl;

filename_table = 'RadiusOfCurvature_Table.mat';
save(filename_table,'x_proj_table','rcurve_table');
