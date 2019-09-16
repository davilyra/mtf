%{
FilmRCurvCalc.m

Last updated: 08/01/2009

written by Anya Grosberg
Disease Biophysics Group
School of Engineering and Applied Sciences
Havard University, Cambridge, MA 02138

The purpose of this code is to calculate stress from the radius of curvature of hMTF


Input:
        Automatic input of:
        1. radius of curvature
        2. Film length in meters
        3. Number of films
        4. Number of frames
        5. complete filename of the image stack
        
Output: Radius of curvature in meters
%}

function FilmStress = FilmStressCalcMulti(RCurve,FilmLengthMet,num_films,frames,filename2,pdms_thick,cell_thick_mod)

global Cloc cell_thick bound thick

%Material property of the cell (chosen), not needed if using
%modified stoney's equation

Ecell=30e3;
Ccell=Ecell./6;

%Material property of PDMS (chosen)
% Epdms=1.5e6; % PDMS from Harvard
Epdms = 2.6868e6; % Compressive elastic modulus, DLL 2017
% Epdms=24000; %gelatin
Cpdms=Epdms./6;


% chose one of the following two methods by commenting out the other one
% method = 'Pat and Anya model' OR 'Modified Stoney equation' depending on what you want to use;
method = 'Modified Stoney equation';

switch method
    
    case 'Pat and Anya model'
        %Specify the number of points in the xpts
        xpts_length = 20;
        %Specify the number of points in the Y
        Y_length = 20;
        
        %initilize the time variable in units of frames
        t=1:1:frames;
        %initialize film stress
        FilmStress = ones(frames,num_films);
        %Cycle through each film
        for filmcount=1:num_films
            tic %Start the stopwatch
            %Display current film
            filmcounter=['film # ' num2str(filmcount) ' of ' num2str(num_films)];
            disp(filmcounter)
            
            %=============================================
            % Preallocating tracking matrices
            %=============================================
            lam_a_track=ones(frames);
            h_track=zeros(frames);
            lamr_track=ones(xpts_length,Y_length,frames);
            lamt_track=ones(xpts_length,Y_length,frames);
            lamz_track=ones(xpts_length,Y_length,frames);
            lamr_star_track=ones(xpts_length,Y_length,frames);
            lamt_star_track=ones(xpts_length,Y_length,frames);
            lamz_star_track=ones(xpts_length,Y_length,frames);
            X_track=ones(frames,xpts_length);
            r_track=ones(xpts_length,Y_length,frames);
            sigr_track=zeros(xpts_length,Y_length,frames);
            sigt_track=zeros(xpts_length,Y_length,frames);
            sigz_track=zeros(xpts_length,Y_length,frames);
            cell_stress=ones(frames,1);
            %=============================================
            
            %set up variables for each film
            film_length = FilmLengthMet(filmcount);
            
            %create a xpts_length point coordinate system for the film length
            xpts=0:(film_length/(xpts_length-1)):film_length;
            %a non dimensional scale with the same number of points
            %xpts_nondim=0:(1/(xpts_length-1)):1;
            
            %Total thickness is the pdms + the cells
            cell_thick=cell_thick_mod;
            thick=pdms_thick+cell_thick;
            
            %Create a coordinate of Y_length points for the thickness
            Y=0:thick/(Y_length-1):thick;
            lamz=1;
            
            %Material parameters as a function on location of thickness
            Cloc=(Ccell+(Cpdms-Ccell)./(1+exp(-bound.*((Y-cell_thick)./Y(end)))));
            %Is the material a cell or a pdms
            Cell_yes=(1-1./(1+exp(-bound.*((Y-cell_thick)./Y(end)))));
            %active stretch (lambda assumes 10% cotnraction initialy)
            lam_a_guess=.99;
            h_guess=thick;
            
            lamz=1;
            
            %Cycle trhough each time point (i.e. frame)
            for j=1:length(t)-1
                %Every one hundered frames display the frame number
                if mod(j,100)==0
                    timecounter=['timepoint ' num2str(t(j)) ' of ' num2str(length(t)-1)];
                    disp(timecounter)
                end
                %track the x coordinates
                X_track(j,:)=xpts;
                %the radius of curvature
                r_mid = RCurve(filmcount,j);
                
                options = optimset('MaxFunEvals',1e30,'MaxIter',1e30,'TolFun',1e-13);
                [x]=fminsearch('mtf_config',[lam_a_guess,h_guess],options,r_mid,Y,lamz);
                
                lam_a=x(1);
                h=x(2);
                lam_a_track(j)=x(1);
                h_track(j)=x(2);
                lam_a_guess=lam_a;
                h_guess=h;
                
                %         Yprime_track(:,j)=Yprime;
                
                lam_a_dist=(lam_a+(1-lam_a)./(1+exp(-bound.*((Y-cell_thick)./Y(end)))));
                
                [lamr,lamt,lamz,lamrstar,lamtstar,lamzstar,r]=config(r_mid,h,Y,lamz,lam_a_dist);
                
                lamr_track(:,j)=lamr;
                lamt_track(:,j)=lamt;
                lamz_track(:,j)=lamz;
                lamr_star_track(:,j)=lamrstar;
                lamt_star_track(:,j)=lamtstar;
                lamz_star_track(:,j)=lamzstar;
                r_track(:,j)=r;
                
                [sigr,sigt,sigz]=stress(lam_a_dist,h,r,Y,lamrstar,lamtstar,lamzstar);
                
                sigr_track(:,j)=sigr;
                sigt_track(:,j)=sigt;
                sigz_track(:,j)=sigz;
                
                cell_stress(j)=trapz(r,Cell_yes.*sigt)./trapz(r,Cell_yes);
            end
            
            [b,a]=butter(10,.25);
            new_stress=filtfilt(b,a,cell_stress);
            
            stress_max_track=max(new_stress);
            stress_min_track=min(new_stress);
            stress_mid_track=mean(new_stress);
            
            %     save data
            savefile=[filename2 '_calcs_film' num2str(filmcount) '.mat'];
            save(savefile);
            FilmStress(:,filmcount) = cell_stress;
            toc
            keep filename2 RCurve FilmLengthMet num_films frames filmcount pdms_thick xpts_length Y_length t Cloc cell_thick bound thick FilmStress cell_thick_mod;
        end
        
    case 'Modified Stoney equation'
        Poisson_ratio = 0.5;
%         FilmStress = Epdms*pdms_thick^3/6./RCurve'/(1-Poisson_ratio^2)/cell_thick_mod^2/(1+pdms_thick/cell_thick_mod);
        FilmStress = (Epdms*pdms_thick^2)./(6*cell_thick_mod*(1-Poisson_ratio^2)*(1+(cell_thick_mod/pdms_thick)).*RCurve'); % From Nature Medicine Paper
end

end