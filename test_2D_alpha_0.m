%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FDTD Method applied in EM
% 
% Yu LIU, X.J MAO, Hao QIN
% ULB EIT Communication Channel Class Project
% 2015-2016 Spring
% 
% 2D-TM EM wave transmitting power distribution iteration with time
% 
% Content and Requirements:
% 1) Inhomogenous dieletric
% 2) Reflective boarder / Abosortion Border Condition*
% 3) Losy
% 4) additive source/ hardwriting source/ TFSF*
% 
% MATLAB GUI is realized based on test script
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Clearing variables in memory and Matlab command screen
clear all;
clc;

% Grid Dimension in x (xdim) and y (ydim) directions
xdim=100;
ydim=100;

% Total no of time steps
time_tot=200;

% Position of the source (center of the field domain)
xsource=50;
ysource=50;

% Courant stability factor
S=1/(2^0.5);

% Parameters of free space (permittivity and permeability and speed of
% light) are all 1 since the domain is unitless
epsilon0=1;
mu0=1;
c=1;

% Spatial and temporal grid step lengths
delta=1;
deltat=S*delta/c;

% Initialization of field matrices
Ez=zeros(xdim,ydim);
Hy=zeros(xdim,ydim);
Hx=zeros(xdim,ydim);

% Initialization of permittivity and permeability matrices
epsilon=epsilon0*ones(xdim,ydim);
mu=mu0*ones(xdim,ydim);

% Choice of form of source
gaussian=0;
sine=0;
impulse=1;
% Choose any one as 1 and rest as 0. The variable names for forms are self-
% explanatory.
% Default form (i.e when all above variables are 0) is Unit time step

% Temporal update loop begins
for n=1:1:time_tot
    
    % Condition if source is impulse or unit-time step 
    if gaussian==0 && sine==0 && n==1
        Ez(xsource,ysource)=1;
    end
    
    % Spatial update loops for Hy and Hx fields begin
    % Here we assume that at the boarder, it is always(Hy=0 Hx=0), which 
    % indicates a PMC. Which would result in reflection of E.
    for i=1:1:xdim-1
        for j=1:1:ydim-1
            Hy(i,j)=Hy(i,j)+(deltat/(delta*mu(i,j)))*(Ez(i+1,j)-Ez(i,j));
            Hx(i,j)=Hx(i,j)-(deltat/(delta*mu(i,j)))*(Ez(i,j+1)-Ez(i,j));
        end
    end
    % Spatial update loops for Hy and Hx fields end
    
    % Spatial update loop for Ez field begins
    for i=2:1:xdim
        for j=2:1:ydim
            Ez(i,j)=Ez(i,j)+(deltat/(delta*epsilon(i,j)))*(Hy(i,j)-Hy(i-1,j)-Hx(i,j)+Hx(i,j-1));
        end
    end
    % Spatial update loop for Ez field ends
    
    % Source conditions
    if impulse==0
        % If unit-time step
        if gaussian==0 && sine==0
            Ez(xsource,ysource)=1;
        end
        % If sinusoidal
        if sine==1
            tstart=1;
            N_lambda=20;
            Ez(xsource,ysource)=sin(((2*pi*(1/N_lambda)*(n-tstart)*deltat)));
        end
        % If gaussian
        if gaussian==1
            if n<=42
                Ez(xsource,ysource)=(10-15*cos(n*pi/20)+6*cos(2*n*pi/20)-cos(3*n*pi/20))/32;
            else
                Ez(xsource,ysource)=0;
            end
        end
    else
        % If impulse
        Ez(xsource,ysource)=0;
    end
%     figure(1)
%     % Movie type colour scaled image plot of Ez
%     imagesc(Ez',[-1,1]);colorbar;
%     title(['\fontsize{20}Colour-scaled image plot of Ez for 2D FDTD (TM) in a unitless domain at timestep = ',num2str(n)]);
%     xlabel('x (in spacesteps)','FontSize',20);
%     ylabel('y (in spacesteps)','FontSize',20);
%     set(gca,'FontSize',20);
%     getframe;
%     figure(2)
    % Movie type colour scaled image plot of Ez
    imagesc(Ez',[-1,1]);colorbar;
    title(['\fontsize{20}Colour-scaled image plot of Ez for 2D FDTD (TM) in a unitless domain at timestep = ',num2str(n)]);
    xlabel('x (in spacesteps)','FontSize',20);
    ylabel('y (in spacesteps)','FontSize',20);
    set(gca,'FontSize',20);
    getframe;
    
end

