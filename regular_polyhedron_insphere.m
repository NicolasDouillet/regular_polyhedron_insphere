function [I, r, S] = regular_polyhedron_insphere(P, F, nb_samples, option_display)
%% Function to compute and display the insphere of a regular polyhedron.
%
% Author : nicolas.douillet9 (at) gmail.com, 2023-2024.
%
%
% Syntax
%
% regular_polyhedron_insphere(P, F);
% regular_polyhedron_insphere(P, F, nb_samples);
% regular_polyhedron_insphere(P, F, nb_samples, option_display);
% [I, r, S] = regular_polyhedron_insphere(P, F, nb_samples, option_display);
%
%
% Description
%
%
% regular_polyhedron_insphere(P, F) computes and displays the insphere of polyhedron (P,F).
% regular_polyhedron_insphere(P, F, nb_samples) uses nb_samples to mesh the
% sphere.
% regular_polyhedron_insphere(P, F, nb_samples, option_display) displays the
% sphere when option_display is set either to logical true or real numeric 1, and
% doesn't when it is set to logical false or real numeric 0.
% [I, r, S] = regular_polyhedron_insphere(P, F, nb_samples, option_display) stores
% the results in [I, r, S] vector.
%
%
% Input arguments
%
%       [ | |  |]
% - P = [Py Py Pz] : real matrix double. size(P,1) € {4,6,8,12,20}. size(P,2) = 3. The polyhedron vertex coordinates.
%       [ | |  |]
%
%       [|  |  | ]
% - F = [i1 i2 i3], positive integer matrix double, the face set. size(T) = [nb_faces,nb_vertex_per_faces].
%       [|  |  | ]
%
% - nb_samples : integer scalar double. The number of samples to mesh the
%                insphere. nb_samples >= 3.
%
% - option_display : logical *true(1) / false(0), to enable/disable the display mode.
%
%
% Output arguments
%
%       [|  |  | ]
% - I = [Ix Iy Iz] : real column vector double. numel(I) = 3. The insphere centre coordinates.       
%       [|  |  | ]
%
% - r : real scalar double. The insphere radius.
%
%       [   |    ]     [   |    ]     [   |    ]
% - S = [ - Sx - ] /// [ - Sy - ] /// [ - Sz - ] : real matrix double. The insphere sample coordinates. size(S) = [nb_samples, nb_samples, 3].
%       [   |    ]     [   |    ]     [   |    ]
%
%
% Example #1 : regular tetrahedron
% P = [0            0          1;...
%      2*sqrt(2)/3  0         -1/3;...
%       -sqrt(2)/3  sqrt(6)/3 -1/3;...
%       -sqrt(2)/3 -sqrt(6)/3 -1/3];
%
% F = [1 2 3; 1 3 4; 1 4 2; 2 4 3];
% nb_samples = 60;
% [I,r] = regular_polyhedron_insphere(P,F,nb_samples,true); % expected : I = [0 0 0]; r = 1/3;
%
%
% Example #2 : cube / hexahedron
% P = [ 1  1  1;...
%      -1  1  1;...
%      -1 -1  1;...
%       1 -1  1;...
%       1  1 -1;...
%      -1  1 -1;...
%      -1 -1 -1;...
%      1 -1 -1];
%
% F = [1 2 3 4;...
%      8 7 6 5;...
%      1 4 8 5;...
%      2 1 5 6;...
%      3 2 6 7;...
%      4 3 7 8];
%
% nb_samples = 60;
% [I,r] = regular_polyhedron_insphere(P,F,nb_samples,true); % expected : I = [0 0 0]; r = 1
%
%
% Example #3 : regular octahedron
% P = [ 1  0  0;...
%       0  1  0;...
%      -1  0  0;
%       0 -1  0;...
%       0  0  1;...
%       0  0 -1];
% 
% F = [1 2 5;...
%      2 3 5;...
%      3 4 5;...
%      4 1 5;...
%      1 6 2;...
%      2 6 3;...
%      3 6 4;...
%      4 6 1];
%
% nb_samples = 60;
% [I,r] = regular_polyhedron_insphere(P,F,nb_samples,true); % expected : I = [0 0 0]; r = sqrt(3)/3


%% Input parsing
assert(nargin > 0, 'Not enought input arguments.');
assert(nargin < 5, 'Too many input arguments.');

if nargin < 4
    
    option_display = true;
    
end

nb_vtx = size(P,1);
assert(nb_vtx == 4 || nb_vtx == 6 || nb_vtx == 8 || nb_vtx == 12 || nb_vtx == 20,...
       'Input polyhedron must be a platonic solid (4, 6, 8, 12, or 20 vertices)');


%% Body
% Polyhedron centre
I = mean(P,1);

% Polyhedron circumsphere radius
R = sqrt(sum((P(1,:)-I).^2,2));


switch nb_vtx
    
    case 4 % tetrahedron
        a = 2*sqrt(2)*R/sqrt(3);
        r0 = a/sqrt(3); % radius of the facet insphere
        
    case 6 % octahedron
        a = sqrt(2)*R;
        r0 = a/sqrt(3);
        
    case 8 % cube
        a = 2*R/sqrt(3);
        r0 = a/sqrt(2);
        
    case 12 % icosahedron
        phi = 0.5*(1+sqrt(5));
        a = 2*R/sqrt(2 + phi);
        r0 = a/sqrt(3);
        
    case 20 % dodecahedron
        phi = 0.5*(1+sqrt(5));
        a = 2*R/sqrt(3)/phi;
        r0 = a/2/sin(0.2*pi);
        
    otherwise
        error('Input polyhedron P must be a platonic solid (size(P,1) € {4, 6, 8, 12, or 20}.');
        
end

% Insphere radius
r = sqrt(R^2 - r0^2);

% Insphere surface
[Sx,Sy,Sz] = sphere(nb_samples);
S = cat(3,r*Sx+I(1),r*Sy+I(2),r*Sz+I(3));


% Display
if option_display
        
    cmap_tetra = cat(3,ones(size(Sx)),zeros(size(Sy)),zeros(size(Sz)));
        
    figure;
    plot3(I(1),I(2),I(3),'ko','Linewidth',4), hold on;
    s = surf(S(:,:,1),S(:,:,2),S(:,:,3),cmap_tetra); shading interp;
    alpha(s,0.4);
    
    for k = 1:size(F,1)
        f = fill3(P(F(k,:),1),P(F(k,:),2),P(F(k,:),3),'b','EdgeColor','b'); hold on;
        alpha(f,0.2);
    end
    
    axis equal, axis tight;
    ax = gca;
    ax.Clipping = 'off';
    [az,el] = view(3);
    camlight(az,el);
    
end


end % regular_polyhedron_insphere