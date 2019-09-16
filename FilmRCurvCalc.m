%{
FilmRCurvCalc.m

Last updated: 04/15/2010
Written: 07/01/2009

written by Anya Grosberg
Disease Biophysics Group
School of Engineering and Applied Sciences
Havard University, Cambridge, MA 02138

The purpose of this code is to calculate the radius of curvature of hMTF


Input: 
        Automatic input of:
        1. The "x" projection in meters (which is the y coordinate on the picture)
        2. The initial length of the film in meters (scaling factor)
        
Output: Radius of curvature in meters
        FilmEdgeMet - the distance from the bottom of the film to the film edge in meters
%}

function [RCurve,FilmEdgeMet] = FilmRCurvCalc(xProjMet,Film_Length,frames,num_films)

%Films lengths are turned into an array
Film_Length_Mat = reshape(repmat(Film_Length,1,frames),num_films,frames);
%scale the x projection by the length of the film
xProjScaled = (xProjMet./Film_Length_Mat);

%This is the scaled radius of curvature at 90 degree bending - this acts as
%a limit for the x projection. If x-proj is larger it is calculated using
%x=r*sin(a/r), if it is smaller then xproj = r
rcurve_scaled_90 = 1./(pi()/2); 

%Load the file with the tables for radius of curvature
load('RadiusOfCurvature_Table.mat');

%Create an array of corresponding radii of curvature (scaled)
RCurve_Scaled = interp1(x_proj_table,rcurve_table,xProjScaled);
RCurve_Scaled(xProjScaled <= rcurve_scaled_90) = xProjScaled(xProjScaled <= rcurve_scaled_90);

RCurve = RCurve_Scaled.*Film_Length_Mat;

%Find the film edge distance from the bottom of the film to the edge of the
%film
FilmEdgeMet = xProjMet;
FilmEdgeMet(xProjScaled <= rcurve_scaled_90) = RCurve(xProjScaled <= rcurve_scaled_90).*sin(Film_Length_Mat(xProjScaled <= rcurve_scaled_90)./RCurve(xProjScaled <= rcurve_scaled_90));

end